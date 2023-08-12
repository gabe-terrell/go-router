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
 * @description Implementation of GoRouter for 'Redirect' type routing. Given an
 * optional input, will redirect to a specific path.
 */
public without sharing class GoRouterRedirect extends GoRouter {
  public GoRouterRedirect(Go_Router__mdt config) {
    super(config);
    matchedOnInput = true;
  }

  /*
   * @description Route to a specific Salesforce URL given the presence or lack
   * of input.
   * @param param - String the input passed in by the user.
   * @return String the relative URL to route to.
   */
  public override String route(String param) {
    if (!String.isEmpty(param)) {
      String path = getParamPath();
      return String.format(path, new List<String>{ param });
    }
    return super.config.Redirect_Path__c;
  }

  /*
   * @description Helper method to choose the appropriate URL from the
   * Go_Router__mdt definition.
   * @return String the relative URL to route to.
   */
  private String getParamPath() {
    return String.isEmpty(super.config.Redirect_Path_With_Param__c)
      ? super.config.Redirect_Path__c
      : super.config.Redirect_Path_With_Param__c;
  }
}
