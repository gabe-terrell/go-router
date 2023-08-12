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
 * @description Test class for GoRouterRecord.
 */
@IsTest(isParallel=true)
private without sharing class GoRouterRecordTest {
  private static final String KEY = GoRouterRecordTest.class.toString();

  private static GoRouter router = GoRouter.createInstanceOf(
    new Go_Router__mdt(
      Type__c = 'Record',
      Entity__c = Go_Router_Log__c.class.toString(),
      Query__c = 'Key__c = :param',
      Like_Query__c = 'Key__c LIKE :likeParam'
    )
  );

  private static Go_Router_Log__c record {
    get {
      return [SELECT Id FROM Go_Router_Log__c WHERE Key__c = :KEY LIMIT 1];
    }
    set;
  }

  @TestSetup
  static void makeData() {
    insert new Go_Router_Log__c(Key__c = KEY);
  }

  /*
   * @description Using a query with an exact match succeeds.
   */
  @IsTest
  private static void standardObjectExactQueryShouldFindRecord() {
    String result = router.route(KEY);
    String recordId = String.valueOf(record.Id).substring(0, 15);

    System.assert(
      result.contains(recordId),
      'Expected router to route to record from standard query.'
    );
  }

  /*
   * @description Using a query with a LIKE query succeeds.
   */
  @IsTest
  private static void standardObjectLikeQueryShouldFindRecord() {
    String result = router.route(KEY.substring(0, 2));
    String recordId = String.valueOf(record.Id).substring(0, 15);

    System.assert(
      result.contains(recordId),
      'Expected router to route to record from LIKE query.'
    );
  }

  /*
   * @description Supplying no query routes to the Object's List View Page.
   */
  @IsTest
  private static void standardObjectNoInputShouldRouteToListView() {
    String result = router.route('');

    System.assert(
      result.contains(Go_Router_Log__c.class.toString()),
      'Expected router to route to Object List View with no input'
    );
  }

  /*
   * @description Supplying a query without an exact match routes to a scoped
   * search for the object.
   */
  @IsTest
  private static void standardObjectNoMatchOnInputShouldRouteToSearch() {
    String input = 'InputThatDoesNotMatch';

    String result = router.route(input);

    System.assert(
      result.contains('/one/one.app'),
      'Expected router to route to Search'
    );
    System.assertEquals(
      false,
      router.matchedOnInput,
      'Expected router to properly report missing on input.'
    );
  }
}
