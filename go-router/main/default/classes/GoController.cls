/**
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * @group GoRouter
 * @description VF Controller that handles logic for taking input and
 * re-routing to resulting page.
 */
public with sharing class GoController {
  // Reserved Query Params used for special routing rules.
  // Using a key with one of these values will not work as expected.
  private static final String DEFAULT_PARAM = 'default';
  private static final String HELP_PARAM = 'help';
  private static final String ID_PARAM = 'id';
  private static final String RAW_QUERY_PARAM = 'query';
  private static final String URL_PARAM = 'url';

  @TestVisible
  private static final String TAB_PARAM = 'sfdc.tabName';
  @TestVisible
  private static final String TAB_URL = '/lightning/n/go';

  /*
   * @description private subclass for query operations. Can be overridden
   * for unit tests.
   */
  @TestVisible
  private static GoController.Selector selector = new GoController.Selector();

  /**
   * @description Query Param exposed on VF Page as Input.
   */
  public String query { get; set; }

  /**
   * @description Used by VF Page to render all routes. Filters out routers
   * by Custom_Permission__c if it is specified in metadata.
   */
  public Route[] routes {
    get {
      List<Route> routes = new List<Route>();
      Go_Router__mdt[] routers = selector.getAllRouters();
      for (Go_Router__mdt router : routers) {
        if (
          router.Custom_Permission__c == null ||
          selector.hasCustomPermission(router.Custom_Permission__c)
        ) {
          routes.add(new Route(router));
        }
      }
      return routes;
    }
    private set;
  }

  /**
   * @description Action invoked by VF page to route to query passed by URL.
   * @return The PageReference to redirect to.
   */
  public PageReference go() {
    String path = route(ApexPages.currentPage().getParameters());
    return routeTo(path);
  }

  /**
   * @description Action by VF Page to route to query passed by on-page form.
   * @return The PageReference to redirect to.
   */
  public PageReference goInput() {
    String path = route(this.query);
    return routeTo(path);
  }

  /*
   * @description Helper method to convert a URL path into a PageReference that
   * will redirect.
   * @param path - String URL Path.
   * @returns PageReference that VF can use to redirect.
   */
  public PageReference routeTo(String path) {
    if (path == null) {
      return null;
    }
    // Redirect malformed paths to the help page; otherwise it will error out.
    if (!path.startsWith('/')) {
      path = TAB_URL;
    }
    PageReference ref = new PageReference(path);
    ref.setRedirect(true);
    return ref;
  }

  /*
   * @description Executes the routing rules from the input to determine where
   * to route to.
   * @param params - List of Key/Value pairs mapping to routing rules
   * @return String relative URL path to redirect to
   */
  public String route(Map<String, String> params) {
    // Check for special routing rules first.

    // 1. Params contains a redirect URL.
    // Necessary workaround for redirecting off SSO login.
    // Will essentially route back to this page and then route correctly.
    if (params.containsKey(URL_PARAM)) {
      return params.get(URL_PARAM);
    }

    // 2. Params contains special param to list all routes.
    if (params.isEmpty() || params.containsKey(HELP_PARAM)) {
      // Redirect to Lightning tab instead of isolated VF page.
      return TAB_URL;
    }

    // 3. User has navigated to the Lightning Tab version of this VF page.
    // If the user is directed here (usually from #2), always render the page.
    if (params.containsKey(TAB_PARAM)) {
      createLog(HELP_PARAM, null);
      return null;
    }

    // Otherwise, route based on registered routers.
    // Acceptable non-deterministic behavior with multiple keys.
    String key = new List<String>(params.keySet())[0];
    String param = params.get(key);

    // If an SFDC Id was passed, directly route to it instead.
    if (key instanceof Id) {
      createLog(ID_PARAM, key);
      return new GoRouterId().route(key);
    }

    // Sanitize input and check if the raw query was used instead.
    key = key.toLowerCase();
    if (key == RAW_QUERY_PARAM) {
      return route(param);
    }

    // Otherwise, pull specified router and route using input provided.
    GoRouter router = GoRouter.forKey(key);
    if (router != null) {
      String result = router.route(param);
      createLog(key, param, router.matchedOnInput);
      return result;
    }

    // If no router was specified or found, route using the default router.
    router = getDefaultRouter();
    if (router != null) {
      String input = key;
      if (!String.isBlank(param)) {
        input += ' ' + param;
      }
      String result = router.route(input);
      createLog(DEFAULT_PARAM, input, router.matchedOnInput);
      return result;
    }

    // If no default router specified, route to help page.
    return TAB_URL;
  }

  /*
   * @description If the query was passed in as raw input (e.g. the URL is
   * /apex/go?query=case+00123456), break the input into its corresponding
   * key-value pair ({case => 00123456}) and then re-route.
   * @param rawInput - the rawInput String (e.g. 'case 00123456').
   * @return String relative URL path to redirect to.
   */
  public String route(String rawInput) {
    final String param;
    final String query;

    String input = rawInput.replaceAll('[/+]', ' ').trim();
    if (String.isBlank(input)) {
      return TAB_URL;
    }
    if (input.startsWith(URL_PARAM)) {
      return rawInput.substringAfter(URL_PARAM).trim();
    }

    Integer split = input.indexOf(' ');
    if (split < 0 || split >= input.length()) {
      param = input;
      query = '';
    } else {
      param = input.substring(0, split);
      query = input.substring(split + 1);
    }

    return route(new Map<String, String>{ param => query });
  }

  /*
   * @description Gets the default router specified in the Metadata config.
   * @return GoRouter the default router or null if nothing is found.
   */
  private GoRouter getDefaultRouter() {
    Go_Router__mdt[] routers = selector.getDefaultRouter();
    return routers.isEmpty() ? null : GoRouter.forKey(routers[0].Key__c);
  }

  /*
   * @description Record a Go_Router_Log__c routing result assuming routing
   * succeeded.
   * @param key - key used to match to a router.
   * @param input - input passed to router.
   */
  private void createLog(String key, String input) {
    createLog(key, input, true);
  }

  /*
   * @description Record a Go_Router_Log__c routing result.
   * @param key - key used to match to a router.
   * @param input - input passed to router.
   * @param matched - boolean indicating if routing succeeded.
   */
  private void createLog(String key, String input, Boolean matched) {
    Go_Router_Log__c log = new Go_Router_Log__c(
      Key__c = key,
      Input__c = input,
      Matched_On_Input__c = matched
    );
    selector.insertLog(log);
  }

  /*
   * @description Wrapper class for Go_Router__mdt. Used by the VF Page to
   * easily render available routes to the user.
   */
  public class Route {
    public String key { get; set; }
    public String input { get; set; }
    public String usage { get; set; }

    public Route(Go_Router__mdt router) {
      this.key = router.Key__c;
      this.input = router.Input__c;
      this.usage = router.Usage__c;
    }
  }

  /*
   * @description private subclass for query operations. Can be overridden for
   * unit tests.
   */
  @TestVisible
  private without sharing virtual class Selector {
    private Map<String, Boolean> permissionMap = new Map<String, Boolean>();

    public virtual Go_Router__mdt[] getAllRouters() {
      return [
        SELECT Custom_Permission__c, Input__c, Key__c, Usage__c
        FROM Go_Router__mdt
        ORDER BY Key__c
      ];
    }

    public virtual Go_Router__mdt[] getDefaultRouter() {
      return [
        SELECT Key__c
        FROM Go_Router__mdt
        WHERE Is_Default_Router__c = TRUE
        LIMIT 1
      ];
    }

    public virtual boolean hasCustomPermission(String permission) {
      if (!permissionMap.containsKey(permission)) {
        Boolean hasPermission = FeatureManagement.checkPermission(permission);
        permissionMap.put(permission, hasPermission);
      }
      return permissionMap.get(permission);
    }

    public virtual void insertLog(Go_Router_Log__c log) {
      Go_Router_Settings__c settings = Go_Router_Settings__c.getInstance();
      if (settings.Enable_Logging__c) {
        insert log;
      }
    }
  }
}
