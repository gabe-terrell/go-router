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
 * @description Test class for GoController.
 */
@IsTest(isParallel=true)
private without sharing class GoControllerTest {
  private static GoController objectUnderTest = new GoController();

  private static Go_Router__mdt defaultRouter = null;
  private static Go_Router__mdt[] allRouters = new List<Go_Router__mdt>{};
  private static boolean hasDeveloperPermission = false;
  private static Go_Router_Log__c loggedResult = null;

  static {
    GoController.selector = new GoControllerTest.Selector();
    GoRouter.configSelector = new GoControllerTest.GoRouterSelector();
  }

  /**
   * @description Check that routers are properly converted and returned to VF page.
   */
  @IsTest
  private static void routesShouldFetchAndReturnSerializedRoutes() {
    Go_Router__mdt router = new Go_Router__mdt(
      Key__c = 'key',
      Input__c = 'input',
      Usage__c = 'usage'
    );
    allRouters.add(router);

    GoController.Route[] routes = objectUnderTest.routes;

    System.assertEquals(1, routes.size(), 'Expected to get one route');
    System.assertEquals(
      router.Key__c,
      routes[0].key,
      'Expected route to properly store the key'
    );
    System.assertEquals(
      router.Input__c,
      routes[0].input,
      'Expected route to properly store the input'
    );
    System.assertEquals(
      router.Usage__c,
      routes[0].usage,
      'Expected route to properly store the usage'
    );
  }

  /**
   * @description If the URL param is included, route straight to the value.
   */
  @IsTest
  private static void urlParamWithValidUrlShouldRouteToValue() {
    String key = 'url';
    String param = '/relative/url/';

    objectUnderTest.query = key + ' ' + param;
    String result = objectUnderTest.goInput().getUrl();

    System.assertEquals(param, result, 'Expected to route to param value');
    System.assertEquals(
      null,
      loggedResult,
      'No logging expected for a redirect'
    );
  }

  /**
   * @description If the URL param is invalid, reroute to help page.
   */
  @IsTest
  private static void urlParamWithInvalidUrlShouldRouteToHelpPage() {
    String key = 'url';
    String param = 'invalidRelativeUrl';

    objectUnderTest.query = key + ' ' + param;
    String result = objectUnderTest.goInput().getUrl();

    System.assertEquals(
      GoController.TAB_URL,
      result,
      'Expected to route to tab help page'
    );
    System.assertEquals(
      null,
      loggedResult,
      'No logging expected for a redirect'
    );
  }

  /**
   * @description If no param is included, route to the help page.
   */
  @IsTest
  private static void emptyParamShouldRouteToHelpPage() {
    String result = objectUnderTest.route(new Map<String, String>());

    System.assertEquals(
      GoController.TAB_URL,
      result,
      'Expected to route to tab help page'
    );
    System.assertEquals(
      null,
      loggedResult,
      'No logging expected for a redirect'
    );
  }

  /**
   * @description If no param is included, route to the help page.
   */
  @IsTest
  private static void emptyParamAfterSanitizingShouldRouteToHelpPage() {
    String result = objectUnderTest.route('/++  ++/');

    System.assertEquals(
      GoController.TAB_URL,
      result,
      'Expected to route to tab help page'
    );
    System.assertEquals(
      null,
      loggedResult,
      'No logging expected for a redirect'
    );
  }

  /**
   * @description If the help param is included, route to the help page.
   */
  @IsTest
  private static void helpParamShouldRouteToHelpPage() {
    String key = 'help';

    String result = objectUnderTest.route(key);

    System.assertEquals(
      GoController.TAB_URL,
      result,
      'Expected to route to tab help page'
    );
    System.assertEquals(
      null,
      loggedResult,
      'No logging expected for a redirect'
    );
  }

  /**
   * @description If the tab param is included, route to nothing, rendering the VF page.
   */
  @IsTest
  private static void tabParamShouldRouteToNothing() {
    String key = GoController.TAB_PARAM;

    String result = objectUnderTest.route(key);

    System.assertEquals(null, result, 'Expected to route to nothing');
    System.assertEquals(
      'help',
      loggedResult.Key__c,
      'Expected "help" usage to be logged'
    );
  }

  /**
   * @description If an SF ID is passed as the query, it should route straight to the record page.
   */
  @IsTest
  private static void routingSFDCIdShouldRouteToPage() {
    Id recordId = '005000000000001';

    String result = objectUnderTest.route(String.valueOf(recordId));

    System.assertEquals(
      '/' + recordId,
      result,
      'Expected SFDC Id to auto route to record page'
    );
    System.assertEquals(
      'id',
      loggedResult.Key__c,
      'Expected "id" usage to be logged'
    );
  }

  /**
   * @description Test that the raw query param recursively reads the query.
   */
  @IsTest
  private static void rawQueryShouldBeProperlyDeconstructed() {
    String input = 'query query query query help';

    String result = objectUnderTest.route(input);

    System.assertEquals(
      GoController.TAB_URL,
      result,
      'Expected to route to tab help page after deconstructing raw query'
    );
    System.assertEquals(
      null,
      loggedResult,
      'No logging expected for a redirect'
    );
  }

  /**
   * @description Test that query matching a router definition properly routes.
   */
  @IsTest
  private static void keyMatchingRouterShouldProperlyRoute() {
    String key = 'mock';
    String param = 'value';
    allRouters.add(
      new Go_Router__mdt(
        Type__c = 'Apex',
        Apex_Class__c = 'GoControllerTest.MockRouter'
      )
    );

    String result = objectUnderTest.route(key + ' ' + param);

    System.assertEquals(param, result, 'Expected mock router to return param');
    System.assertEquals(
      key,
      loggedResult.Key__c,
      'Logger should properly log key'
    );
    System.assertEquals(
      param,
      loggedResult.Input__c,
      'Logger should properly log param'
    );
    System.assertEquals(
      true,
      loggedResult.Matched_On_Input__c,
      'Logger should properly log result'
    );
  }

  /**
   * @description Test that falling back to the default router properly routes.
   */
  @IsTest
  private static void defaultRouterShouldProperlyRoute() {
    String input = 'inputForDefault';
    defaultRouter = new Go_Router__mdt(
      Type__c = 'Apex',
      Apex_Class__c = 'GoControllerTest.MockRouter'
    );

    String result = objectUnderTest.route(input);

    System.assertEquals(
      input.toLowerCase(),
      result,
      'Expected mock router to return input'
    );
    System.assertEquals(
      'default',
      loggedResult.Key__c,
      'Logger should properly log use of default router'
    );
    System.assertEquals(
      input.toLowerCase(),
      loggedResult.Input__c,
      'Logger should properly log param'
    );
    System.assertEquals(
      true,
      loggedResult.Matched_On_Input__c,
      'Logger should properly log result'
    );
  }

  /**
   * @description Test that no default router found routes to the help page.
   */
  @IsTest
  private static void noDefaultRouterShouldProperlyRouteToHelp() {
    String input = 'input matching no router';

    String result = objectUnderTest.route(input);

    System.assertEquals(
      GoController.TAB_URL,
      result,
      'Expected to route to tab help page after deconstructing raw query'
    );
    System.assertEquals(
      null,
      loggedResult,
      'No logging expected for a redirect'
    );
  }

  private with sharing class Selector extends GoController.Selector {
    public override Go_Router__mdt[] getAllRouters() {
      return allRouters;
    }

    public override Go_Router__mdt[] getDefaultRouter() {
      return defaultRouter == null
        ? new List<Go_Router__mdt>{}
        : new List<Go_Router__mdt>{ defaultRouter };
    }

    public override boolean hasCustomPermission(String permission) {
      return hasDeveloperPermission;
    }

    public override void insertLog(Go_Router_Log__c log) {
      loggedResult = log;
    }
  }

  private with sharing class GoRouterSelector extends GoRouter.Selector {
    Integer calls = 0;
    public override Go_Router__mdt[] getRoutersWithKeys(Set<String> keys) {
      calls += 1;
      if (calls == 1) {
        return allRouters;
      } else {
        return GoController.selector.getDefaultRouter();
      }
    }
  }

  public without sharing class MockRouter extends GoRouter {
    public override String route(String param) {
      super.matchedOnInput = true;
      return param;
    }
  }
}
