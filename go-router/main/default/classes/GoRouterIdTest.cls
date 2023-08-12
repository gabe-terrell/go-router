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
 * @description Test class for GoRouterId.
 */
@IsTest(isParallel=true)
private with sharing class GoRouterIdTest {
  private static GoRouter router = new GoRouterId();

  @SuppressWarnings('PMD.AvoidHardcodingId')
  private static Id mockId(Schema.SObjectType type) {
    return type.getDescribe().getKeyPrefix() + '000000000000000';
  }

  @IsTest
  private static void bogusParamShouldRouteToHomepage() {
    String result = router.route('blah');

    System.assertEquals('/', result, 'Expected router to route to homepage');
  }

  @IsTest
  private static void standardObjectShouldRouteToStandardId() {
    Id id = mockId(Case.getSObjectType());
    String result = router.route(id);

    System.assertEquals(
      '/' + id,
      result,
      'Expected router to route to standard Id path'
    );
  }

  @IsTest
  private static void customSettingShouldRouteToCorrectUrl() {
    Id id = mockId(Go_Router_Settings__c.getSObjectType());
    String result = router.route(id);

    System.assertEquals(
      '/lightning/setup/CustomSettings/page?address=%2F' + id,
      result,
      'Expected router to route to custom path'
    );
  }

  @IsTest
  private static void customMetadataShouldRouteToCorrectUrl() {
    Id id = mockId(Go_Router__mdt.getSObjectType());
    String result = router.route(id);

    System.assertEquals(
      '/lightning/setup/CustomMetadata/page?address=%2F' + id,
      result,
      'Expected router to route to custom path'
    );
  }

  @IsTest
  private static void hardcodedSetupObjectShouldRouteToCorrectUrl() {
    Id id = mockId(PermissionSet.getSObjectType());
    String result = router.route(id);

    System.assertEquals(
      '/lightning/setup/PermSets/page?address=%2F' + id,
      result,
      'Expected router to route to custom path'
    );
  }
}
