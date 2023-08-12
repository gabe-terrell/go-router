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
 * @description Test class for GoRouterObjectManager, GoRouterEntityDefinition,
 * and GoRouterFieldDefinition.
 */
@IsTest(isParallel=true)
public without sharing class GoRouterObjectManagerTest {
  private static final GoRouter ROUTER = new GoRouterObjectManager();

  private static final String REDIRECT_PATH = GoRouterEntityDefinition.REDIRECT_PATH;

  private static final String SEARCH_SUCCESS_ERROR = 'Expected Object Manager search to fail for term: ';

  private static final String SEARCH_FAILURE_ERROR = 'Expected Object Manager search to succeed for term: ';

  private static Boolean didSearchSucceed(String term) {
    String result = ROUTER.route(term);
    return ROUTER.matchedOnInput && result != REDIRECT_PATH;
  }

  /*
   * @description If a search fails, redirect to the Object Manager home page.
   */
  @IsTest
  private static void searchingFakeObjectShouldRedirect() {
    String term = 'FakeObject___';

    Boolean searchSucceeded = didSearchSucceed(term);

    System.assertEquals(false, searchSucceeded, SEARCH_SUCCESS_ERROR + term);
  }

  /*
   * @description Searching for a standard object should route to its record
   * page.
   */
  @IsTest
  private static void searchStandardObjectShouldSucceed() {
    String term = Contact.class.toString();

    Boolean searchSucceeded = didSearchSucceed(term);

    System.assertEquals(true, searchSucceeded, SEARCH_FAILURE_ERROR + term);
  }

  /*
   * @description Searching for a custom metadata object should route to its
   * record page.
   */
  @IsTest
  private static void searchingMetadataObjectShouldSucceed() {
    String term = Go_Router__mdt.class.toString();

    Boolean searchSucceeded = didSearchSucceed(term);

    System.assertEquals(true, searchSucceeded, SEARCH_FAILURE_ERROR + term);
  }

  /*
   * @description Searching for an object using spaces instead of underscores
   * should still route to its record page.
   */
  @IsTest
  private static void searchingObjectWithSpacesShouldSucceed() {
    String term = 'Go Router';

    Boolean searchSucceeded = didSearchSucceed(term);

    System.assertEquals(true, searchSucceeded, SEARCH_FAILURE_ERROR + term);
  }

  /*
   * @description Searching for a standard object field should route to its
   * field page.
   */
  @IsTest
  private static void searchingStandardObjectFieldShouldSucceed() {
    String term = 'Contact.Name';

    Boolean searchSucceeded = didSearchSucceed(term);

    System.assertEquals(true, searchSucceeded, SEARCH_FAILURE_ERROR + term);
  }

  /*
   * @description Searching for a custom metadata object field should route to
   * its field page.
   */
  @IsTest
  private static void searchingMetadataObjectFieldShouldSucceed() {
    String term = 'Go_Router__mdt.Key__c';

    Boolean searchSucceeded = didSearchSucceed(term);

    System.assertEquals(true, searchSucceeded, SEARCH_FAILURE_ERROR + term);
  }

  /*
   * @description Searching for a standard object field  using spaces instead of
   * underscores should still route to its field page.
   */
  @IsTest
  private static void searchingObjectFieldWithSpacesShouldSucceed() {
    String term = 'Go Router.Is Default';

    Boolean searchSucceeded = didSearchSucceed(term);

    System.assertEquals(true, searchSucceeded, SEARCH_FAILURE_ERROR + term);
  }
}
