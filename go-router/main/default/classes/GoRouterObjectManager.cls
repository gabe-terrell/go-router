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
 * @description Apex GoRouter for searching for Objects or Fields in Object
 * Manager.
 */
public without sharing class GoRouterObjectManager extends GoRouter {
  /*
   * @description Route to EntityDefinition or FieldDefinition page based on
   * search param.
   * @param term - String the search term (Object | Object.Field).
   * @return String the relative URL to route to.
   */
  public override String route(String param) {
    final GoRouter router;
    if (param.split('\\.').size() > 1) {
      router = new GoRouterFieldDefinition();
    } else {
      router = new GoRouterEntityDefinition();
    }
    String result = router.route(param);
    super.matchedOnInput = router.matchedOnInput;
    return result;
  }
}
