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
 * @description Test class for GoRouterCustomMetadata.
 */
@IsTest(isParallel=true)
private with sharing class GoRouterCustomMetadataTest {
  private static final GoRouter ROUTER = new GoRouterCustomMetadata();

  private static final String REDIRECT_PATH = '/';

  @IsTest
  private static void searchingNoQueryShouldRedirectToCustomMeadataSetup() {
    String term = '';

    String result = ROUTER.route(term);

    System.assertEquals(
      true,
      ROUTER.matchedOnInput,
      'Expected no input to route to "match" on input.'
    );
    System.assertEquals(
      new GoRouterSetup().route('mdts'),
      result,
      'Expected to redirect to Setup page for mdts.'
    );
  }

  @IsTest
  private static void searchingFakeObjectShouldRedirectToCustomMeadataSetup() {
    String term = 'FakeObject___';

    String result = ROUTER.route(term);

    System.assertEquals(
      false,
      ROUTER.matchedOnInput,
      'Expected non-existent object to route to not match on input.'
    );
    System.assertEquals(
      new GoRouterSetup().route('mdts'),
      result,
      'Expected routing failure to redirect to Setup page for mdts.'
    );
  }

  @IsTest
  private static void searchStandardObjectShouldRedirectToCustomMetadataSetup() {
    Schema.DescribeSObjectResult sObjectSearch = Contact.sObjectType.getDescribe();
    String term = sObjectSearch.getName();

    String result = ROUTER.route(term);

    System.assertEquals(
      false,
      ROUTER.matchedOnInput,
      'Expected non-metadata object to route to not match on input.'
    );
    System.assertEquals(
      new GoRouterSetup().route('mdts'),
      result,
      'Expected routing failure to redirect to Setup page for mdts.'
    );
  }

  @IsTest
  private static void searchCustomMetadataTypeShouldRouteToProperSetupPage() {
    Schema.DescribeSObjectResult sObjectSearch = Go_Router__mdt.sObjectType.getDescribe();
    String term = sObjectSearch.getName();

    String result = ROUTER.route(term);

    System.assertEquals(
      true,
      ROUTER.matchedOnInput,
      'Expected object to route to match on the input.'
    );
    System.assertEquals(
      new GoRouterObjectManager().route(term),
      result,
      'Expected to route to custom metadata setup view.'
    );
  }

  @IsTest
  private static void searchCustomMetadataRecordShouldRouteToProperRecordPage() {
    Schema.DescribeSObjectResult sObjectSearch = Go_Router__mdt.sObjectType.getDescribe();
    String term = sObjectSearch.getName() + '.Custom_Metadata';

    String result = ROUTER.route(term);

    System.assertEquals(
      true,
      ROUTER.matchedOnInput,
      'Expected object to route to match on the input.'
    );
    System.assertEquals(
      new GoRouterRecord(
          new Go_Router__mdt(
            Entity__c = sObjectSearch.getName(),
            Query__c = 'DeveloperName = \'Custom_Metadata\''
          )
        )
        .route(term),
      result,
      'Expected to route to custom metadata record view.'
    );
  }
}
