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
 * @description Test Class for GoRouterSetup.
 */
@IsTest(isParallel=true)
private without sharing class GoRouterSetupTest {
  private static final GoRouterSetup ROUTER = new GoRouterSetup();

  /*
   * @description Test routing logic for different types of key input.
   */
  @IsTest
  private static void routingDifferentKeyInputsShouldSucceed() {
    String notFoundRoute = ROUTER.route('');
    String nonPluralRoute = ROUTER.route('app');
    String pluralRoute = ROUTER.route('apps');

    System.assertNotEquals(
      notFoundRoute,
      nonPluralRoute,
      'Expected setup route to be found'
    );
    System.assertEquals(
      pluralRoute,
      nonPluralRoute,
      'Expected synonymous routes to be identical'
    );
  }

  /*
   * @description Test the Setup Help page getAllInputs() initial creation and further get
   */
  @IsTest
  private static void getAllInputsSuccessfullyLoads() {
    Map<String, String> initialInputs = ROUTER.getAllInputs;
    System.assertNotEquals(
      initialInputs.size(),
      0,
      'Expected Setup Inputs to be loaded'
    );
    Map<String, String> regotInputs = ROUTER.getAllInputs;
    System.assertEquals(
      regotInputs,
      initialInputs,
      'Expected second getAllInputs to match first one'
    );
  }
}
