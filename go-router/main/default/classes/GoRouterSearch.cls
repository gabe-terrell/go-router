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
 * @description Apex GoRouter for routing to Salesforce search. Supports generic
 * search or object-scoped search.
 */
public without sharing class GoRouterSearch extends GoRouter {
  @TestVisible
  private static final String SEARCH_PATH = '/one/one.app?source=aloha#';

  /*
   * @description Route to search page for generic search term.
   * @param term - String the search term.
   * @return String the relative URL to route to.
   */
  public override String route(String param) {
    SearchParams params = new SearchParams(param);
    Blob searchBlob = Blob.valueOf(params.toString());
    String encoding = EncodingUtil.base64Encode(searchBlob);
    return SEARCH_PATH + encoding;
  }

  /*
   * @description Route to search page scoped for a specific object type.
   * @param term - String the search term.
   * @param objectType - DescribeSObjectResult the object to scope search for.
   * @param isSetupObj - Boolean whether the sObject is used for Setup.
   * @return String the relative URL to route to.
   */
  public String route(
    String term,
    DescribeSObjectResult objectType,
    Boolean isSetupObj
  ) {
    SearchParams params = new SearchParams(term, objectType, isSetupObj);
    Blob searchBlob = Blob.valueOf(params.toString());
    String encoding = EncodingUtil.base64Encode(searchBlob);
    return SEARCH_PATH + encoding;
  }

  /*
   * @description Convenience classes used for JSON serializing to match
   * Lightning Aloha Search.
   */
  private class SearchParams {
    String componentDef = 'forceSearch:searchPage';
    SearchAttributes attributes;

    public SearchParams(String term) {
      this.attributes = new SearchAttributes(term);
    }

    public SearchParams(
      String term,
      DescribeSObjectResult objectType,
      Boolean isSetup
    ) {
      this.attributes = new SearchAttributes(term, objectType, isSetup);
    }

    public override String toString() {
      return Json.serialize(this);
    }
  }

  /*
   * @description Convenience classes used for JSON serializing to match
   * Lightning Aloha Search.
   */
  private class SearchAttributes {
    String groupId = 'DEFAULT';
    String term;
    SearchContext context = new SearchContext();
    Map<String, String> scopeMap;

    public SearchAttributes(String term) {
      this.term = term;
    }

    public SearchAttributes(
      String term,
      DescribeSObjectResult objectType,
      Boolean isSetup
    ) {
      this.term = term;
      this.scopeMap = new Map<String, String>{
        'entity' => objectType.getName(),
        'name' => objectType.getName(),
        'label' => objectType.getLabel(),
        'labelPlural' => objectType.getLabelPlural(),
        'id' => objectType.getName()
      };
      if (isSetup) {
        this.scopeMap.put('namespace', 'Setup');
        this.scopeMap.put('labelPlural', 'Setup');
      }
    }
  }

  /*
   * @description Convenience classes used for JSON serializing to match
   * Lightning Aloha Search.
   */
  private class SearchContext {
    Boolean disableSpellCorrection = false;
    Boolean disableIntentQuery = false;
    Map<String, Boolean> permsAndPrefs = new Map<String, Boolean>{};
  }
}
