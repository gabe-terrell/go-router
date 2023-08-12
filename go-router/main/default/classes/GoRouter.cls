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
 * @description Base definition of a GoRouter. Contains Utiltiy methods for
 * loading implementations.
 */
public with sharing abstract class GoRouter {
  /*
   * @description Static constants storing the different type of GoRouters.
   */
  @TestVisible
  private static final String GOROUTER_TYPE_REDIRECT = 'Redirect';
  @TestVisible
  private static final String GOROUTER_TYPE_RECORD = 'Record';
  @TestVisible
  private static final String GOROUTER_TYPE_APEX = 'Apex';

  /*
   * @description private subclass for query operations. Can be overridden for
   * unit tests.
   */
  @TestVisible
  private static GoRouter.Selector configSelector = new GoRouter.Selector();

  /*
   * @description The routing rules defined for this router.
   */
  @TestVisible
  public final Go_Router__mdt config;

  /*
   * @description Boolean indicating if the router matched based on the input.
   */
  public boolean matchedOnInput = false;

  /*
   * @description Initializer used for native GoRouter implementations (Redirect
   * & Record).
   */
  public GoRouter(Go_Router__mdt config) {
    this.config = config;
  }

  /*
   * @description Initialized used for Apex GoRouter extension implementations.
   */
  public GoRouter() {
  }

  /*
   * @description Abstract method all GoRouters implement to define routing
   * rules based on input provided.
   * @param param - String input used for routing to a path.
   * @return String relative URL path to redirect to.
   */
  public abstract String route(String param);

  /*
   * @description Helper method to delegate routing work to another router.
   * The outcome of this router's matchedOnInput is updated based on the result of the delegate.
   * @param param - String input passed to delegate router.
   * @param router - Delegate GoRouter to which query is passed to.
   * @return String result of router.
   */
  protected String delegateTo(String param, GoRouter router) {
    return delegateTo(param, new List<GoRouter>{ router });
  }

  /*
   * @description Helper method to delegate routing work to list of other routers.
   * The first router that successfully matchedOnInput will return its result.
   * If no router matches on the input, then no result is returned.
   * The outcome of this router's matchedOnInput is updated based on the result of the delegates.
   * @param param - String input passed to delegate router.
   * @param routers - Delegate GoRouters to which query is passed to.
   * @return String result of first successful router.
   */
  protected String delegateTo(String param, GoRouter[] routers) {
    for (GoRouter router : routers) {
      String result = router?.route(param);
      if (router?.matchedOnInput == true) {
        matchedOnInput = true;
        return result;
      }
    }
    matchedOnInput = false;
    return '';
  }

  /*
   * @description Helper method to fetch Go_Router__mdt and create the
   * associated GoRouter implementation defined by the metadata.
   * @param key - String mapping to a specific Go_Router__mdt key.
   * @return GoRouter class instantiation matching key.
   */
  public static GoRouter forKey(String key) {
    GoRouter[] routers = GoRouter.forKeys(new Set<String>{ key });
    return routers.isEmpty() ? null : routers[0];
  }

  /*
   * @description Helper method to fetch Go_Router__mdt and create the
   * associated GoRouter implementation defined by the metadata.
   * @param keys - Set<String> mapping to specific Go_Router__mdt keys.
   * @return GoRouter[] list of implementations matching key.
   */
  public static GoRouter[] forKeys(Set<String> keys) {
    Go_Router__mdt[] configs = configSelector.getRoutersWithKeys(keys);

    List<GoRouter> routers = new List<GoRouter>();
    for (Go_Router__mdt config : configs) {
      GoRouter router = createInstanceOf(config);
      if (router != null) {
        routers.add(router);
      }
    }
    return routers;
  }

  /*
   * @description Instantiate a GoRouter based on the router configuration.
   * Will return null if the user does not have the associated custom permission.
   * @param router - Go_Router__mdt defining the Router configuration.
   * @returns GoRouter instance of that class.
   */
  @TestVisible
  private static GoRouter createInstanceOf(Go_Router__mdt router) {
    if (
      !String.isBlank(router.Custom_Permission__c) &&
      !configSelector.hasCustomPermission(router.Custom_Permission__c)
    ) {
      return null;
    }
    if (router.Type__c == GOROUTER_TYPE_REDIRECT) {
      return new GoRouterRedirect(router);
    }
    if (router.Type__c == GOROUTER_TYPE_RECORD) {
      return new GoRouterRecord(router);
    }
    if (router.Type__c == GOROUTER_TYPE_APEX) {
      return GoRouter.createInstanceOf(router.Apex_Class__c);
    }
    return null;
  }

  /*
   * @description Uses Apex Reflection to create a GoRouter instance from a
   * class name. Will fail if the passed class name does not conform to GoRouter.
   * @param routerClass - String name of Apex class.
   * @returns GoRouter instance of that class.
   */
  private static GoRouter createInstanceOf(String routerClass) {
    Type t = Type.forName(routerClass);
    if (t == null || !GoRouter.class.isAssignableFrom(t)) {
      throw new GoRoutingException('Invalid Apex Class: ' + routerClass);
    }
    return (GoRouter) t.newInstance();
  }

  public class GoRoutingException extends Exception {
  }

  /*
   * @description private subclass for query operations. Can be overridden for
   * unit tests.
   */
  @TestVisible
  private without sharing virtual class Selector {
    Map<String, Boolean> permissionMap = new Map<String, Boolean>();

    public virtual boolean hasCustomPermission(String permission) {
      if (!permissionMap.containsKey(permission)) {
        Boolean hasPermission = FeatureManagement.checkPermission(permission);
        permissionMap.put(permission, hasPermission);
      }
      return permissionMap.get(permission);
    }

    public virtual Go_Router__mdt[] getRoutersWithKeys(Set<String> keys) {
      return [
        SELECT
          Apex_Class__c,
          Custom_Permission__c,
          Entity__c,
          Input__c,
          Is_Default_Router__c,
          Is_Setup_Record__c,
          Key__c,
          Record_Page__c,
          Redirect_Path__c,
          Redirect_Path_With_Param__c,
          Like_Query__c,
          Query__c,
          Type__c,
          Usage__c
        FROM Go_Router__mdt
        WHERE Key__c IN :keys
      ];
    }
  }
}
