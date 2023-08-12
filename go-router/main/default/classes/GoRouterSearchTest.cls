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
 * @description Test Class for GoRouterSearch.
 */
@IsTest(isParallel=true)
private without sharing class GoRouterSearchTest {
  private static final String TERM = 'searchTerm';
  private static final GoRouterSearch ROUTER = new GoRouterSearch();

  /*
   * @description A generic search builds properly for Lightning.
   */
  @IsTest
  private static void genericSearchShouldBuildCorrectly() {
    String result = ROUTER.route(TERM);
    String searchEncoding = result.substring(
      GoRouterSearch.SEARCH_PATH.length()
    );
    String search = EncodingUtil.base64Decode(searchEncoding).toString();

    System.assert(
      search.contains(TERM),
      'Expected search to contain search term'
    );
  }

  /*
   * @description An object-scoped search builds properly for Lightning.
   */
  @IsTest
  private static void scopedSearchShouldBuildCorrectly() {
    DescribeSObjectResult objectType = Contact.getSObjectType().getDescribe();

    String result = ROUTER.route(TERM, objectType, false);
    String searchEncoding = result.substring(
      GoRouterSearch.SEARCH_PATH.length()
    );
    String search = EncodingUtil.base64Decode(searchEncoding).toString();

    System.assert(
      search.contains(TERM),
      'Expected search to contain search term'
    );
    System.assert(
      search.contains(objectType.getName()),
      'Expected search to contain object scope'
    );
  }
}
