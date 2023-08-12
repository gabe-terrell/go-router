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
 * @description Utility methods that can be integrated into the test suite of
 * an instance.
 */
@IsTest
private with sharing class GoRouterTestUtility {
  /*
   * @description Verify that all Go_Router__mdt records correctly instantiate.
   * @return String error message if a router failed to instantiate. Otherwise, null.
   */
  public static String verifyAllRouters() {
    Go_Router__mdt[] routers = [SELECT Key__c FROM Go_Router__mdt];

    for (Go_Router__mdt router : routers) {
      try {
        GoRouter.forKey(router.Key__c);
      } catch (Exception e) {
        return 'Go_Router__mdt with key "' +
          router.Key__c +
          '" failed to instantiate for reason: ' +
          e.getMessage();
      }
    }

    return null;
  }

  private GoRouterTestUtility() {
  }
}
