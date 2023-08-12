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
 * @description Test Class for GoRouterRedirect.
 */
@IsTest(isParallel=true)
private without sharing class GoRouterRedirectTest {
  private static final String PATH = '/path/';
  private static final String PATH_WITH_PARAM = '/path/{0}';
  private static final String INPUT = 'input';

  private static GoRouter router = GoRouter.createInstanceOf(
    new Go_Router__mdt(
      Type__c = 'Redirect',
      Redirect_Path__c = PATH,
      Redirect_Path_With_Param__c = PATH_WITH_PARAM
    )
  );

  /*
   * @description A redirect specifying no param succeeds.
   */
  @IsTest
  private static void redirectNoParamShouldSucceed() {
    String result = router.route(null);

    System.assertEquals(PATH, result, 'Expected to route to configured path');
  }

  /*
   * @description A redirect specifying a param succeeds.
   */
  @IsTest
  private static void redirectParamShouldSucceed() {
    String result = router.route(INPUT);

    System.assertEquals(
      PATH + INPUT,
      result,
      'Expected to route to path with injected parameter'
    );
  }

  /*
   * @description A redirect specifying a param but without a param route succeeds
   */
  @IsTest
  private static void redirectParamButNoParamRouteShouldSucceed() {
    ROUTER.config.Redirect_Path_With_Param__c = null;

    String result = router.route(INPUT);

    System.assertEquals(
      PATH,
      result,
      'Expected to route to default path since no param path exists.'
    );
  }
}
