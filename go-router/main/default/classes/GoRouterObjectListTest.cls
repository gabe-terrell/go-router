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
 * @description Test class for GoRouterObjectList.
 */
@IsTest(isParallel=true)
private with sharing class GoRouterObjectListTest {
  private static final GoRouter ROUTER = new GoRouterObjectList();

  private static final String REDIRECT_PATH = '/';

  private static Boolean didSearchShouldSucceed(String term, String path) {
    String result = ROUTER.route(term);
    return ROUTER.matchedOnInput && result != REDIRECT_PATH;
  }

  @IsTest
  private static void searchingFakeObjectShouldRedirectToHome() {
    String term = 'FakeObject___';

    String result = ROUTER.route(term);

    System.assertEquals(
      false,
      ROUTER.matchedOnInput,
      'Expected non-existent object to route to not match on input.'
    );
    System.assertEquals(
      '/',
      result,
      'Expected routing failure to redirect to home.'
    );
  }

  @IsTest
  private static void searchStandardObjectShouldRouteToProperListPage() {
    Schema.DescribeSObjectResult sObjectSearch = Contact.sObjectType.getDescribe();
    String term = sObjectSearch.getName();

    String result = ROUTER.route(term);

    System.assertEquals(
      true,
      ROUTER.matchedOnInput,
      'Expected object to route to match on the input.'
    );
    System.assertEquals(
      String.format(
        GoRouterObjectList.LIST_VIEW_PATH,
        new List<String>{ sObjectSearch.getName() }
      ),
      result,
      'Expected to route to standard list view.'
    );
  }

  @IsTest
  private static void searchCustomSettingShouldRouteToProperListPage() {
    Schema.DescribeSObjectResult sObjectSearch = Go_Router_Settings__c.sObjectType.getDescribe();
    String term = sObjectSearch.getName();

    String result = ROUTER.route(term);

    System.assertEquals(
      true,
      ROUTER.matchedOnInput,
      'Expected object to route to match on the input.'
    );
    System.assertEquals(
      String.format(
        GoRouterObjectList.LIST_VIEW_PATH_CUSTOM_SETTING,
        new List<String>{ sObjectSearch.getKeyPrefix() }
      ),
      result,
      'Expected to route to custom setting list view.'
    );
  }

  @IsTest
  private static void searchCustomMetadataShouldRouteToProperListPage() {
    Schema.DescribeSObjectResult sObjectSearch = Go_Router__mdt.sObjectType.getDescribe();
    String term = sObjectSearch.getName();

    String result = ROUTER.route(term);

    System.assertEquals(
      true,
      ROUTER.matchedOnInput,
      'Expected object to route to match on the input.'
    );
    System.assertEquals(
      String.format(
        GoRouterObjectList.LIST_VIEW_PATH_METADATA,
        new List<String>{ sObjectSearch.getKeyPrefix() }
      ),
      result,
      'Expected to route to custom metadata list view.'
    );
  }
}
