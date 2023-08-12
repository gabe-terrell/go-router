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
 * @description Test class for GoRouter.
 */
@IsTest(isParallel=true)
private with sharing class GoRouterTest {
  private static final String KEY_NAME = 'key';
  private static final String KEY_NAME_2 = 'key2';
  private static final String PARAM_VALUE = 'param';

  private static List<Go_Router__mdt> configsToReturn = new List<Go_Router__mdt>();
  private static Boolean hasCustomPermissionForRouter;

  static {
    GoRouter.configSelector = new GoRouterTest.GoRouterSelector();
  }

  @IsTest
  private static void redirectConfigShouldCreateRedirectRouter() {
    configsToReturn.add(
      new Go_Router__mdt(
        Key__c = KEY_NAME,
        Type__c = GoRouter.GOROUTER_TYPE_REDIRECT
      )
    );

    GoRouter router = GoRouter.forKey(KEY_NAME);

    Assert.isInstanceOfType(
      router,
      GoRouterRedirect.class,
      'Expected config to produce a RedirectRouter'
    );
  }

  @IsTest
  private static void recordConfigShouldCreateRecordRouter() {
    configsToReturn.add(
      new Go_Router__mdt(
        Key__c = KEY_NAME,
        Type__c = GoRouter.GOROUTER_TYPE_RECORD,
        Entity__c = 'Go_Router__mdt'
      )
    );

    GoRouter router = GoRouter.forKey(KEY_NAME);

    Assert.isInstanceOfType(
      router,
      GoRouterRecord.class,
      'Expected config to produce a RedirectRouter'
    );
  }

  @IsTest
  private static void apexConfigShouldCreateApexRouter() {
    configsToReturn.add(
      new Go_Router__mdt(
        Key__c = KEY_NAME,
        Type__c = GoRouter.GOROUTER_TYPE_APEX,
        Apex_Class__c = 'GoRouterTest.SuccessRouter'
      )
    );

    GoRouter router = GoRouter.forKey(KEY_NAME);

    Assert.isInstanceOfType(
      router,
      GoRouterTest.SuccessRouter.class,
      'Expected config to produce a RedirectRouter'
    );
  }

  @IsTest
  private static void configWithCustomPermissionShouldCreateRouterForPermittedUser() {
    hasCustomPermissionForRouter = true;
    configsToReturn.add(
      new Go_Router__mdt(
        Key__c = KEY_NAME,
        Type__c = GoRouter.GOROUTER_TYPE_REDIRECT,
        Custom_Permission__c = KEY_NAME
      )
    );

    GoRouter router = GoRouter.forKey(KEY_NAME);

    Assert.isNotNull(router, 'Expected permitted user to receive a router');
  }

  @IsTest
  private static void configWithCustomPermissionShouldNotCreateRouterForNonPermittedUser() {
    hasCustomPermissionForRouter = false;
    configsToReturn.add(
      new Go_Router__mdt(
        Key__c = KEY_NAME,
        Type__c = GoRouter.GOROUTER_TYPE_REDIRECT,
        Custom_Permission__c = KEY_NAME
      )
    );

    GoRouter router = GoRouter.forKey(KEY_NAME);

    Assert.isNull(
      router,
      'Expected non-permitted user to not receive a router'
    );
  }

  @IsTest
  private static void delegateRouterToFailureRouterShouldReflectFailure() {
    GoRouter delegateRouter = new GoRouterTest.DelegateRouter(
      new List<GoRouter>{ new GoRouterTest.FailureRouter() }
    );

    String result = delegateRouter.route(PARAM_VALUE);

    Assert.isFalse(
      delegateRouter.matchedOnInput,
      'Expected delegate with failure router to not match on input'
    );
    Assert.areEqual('', result, 'Expected failure router to return nothing');
  }

  @IsTest
  private static void delegateRouterToSuccessRouterShouldYieldSuccess() {
    GoRouter delegateRouter = new GoRouterTest.DelegateRouter(
      new List<GoRouter>{ new GoRouterTest.SuccessRouter() }
    );

    String result = delegateRouter.route(PARAM_VALUE);

    Assert.isTrue(
      delegateRouter.matchedOnInput,
      'Expected delegate with success router to match on input'
    );
    Assert.areEqual(
      PARAM_VALUE,
      result,
      'Expected success router to parrot input'
    );
  }

  @IsTest
  private static void delegateRouterForMultipleKeysShouldReturnFirstSuccessfulResult() {
    configsToReturn.addAll(
      new List<Go_Router__mdt>{
        new Go_Router__mdt(
          Key__c = KEY_NAME,
          Type__c = GoRouter.GOROUTER_TYPE_APEX,
          Apex_Class__c = 'GoRouterTest.FailureRouter'
        ),
        new Go_Router__mdt(
          Key__c = KEY_NAME_2,
          Type__c = GoRouter.GOROUTER_TYPE_APEX,
          Apex_Class__c = 'GoRouterTest.SuccessRouter'
        )
      }
    );
    GoRouter delegateRouter = new GoRouterTest.DelegateRouter(
      GoRouter.forKeys(new Set<String>{ KEY_NAME, KEY_NAME_2 })
    );

    String result = delegateRouter.route(PARAM_VALUE);

    Assert.isTrue(
      delegateRouter.matchedOnInput,
      'Expected delegate with one successful router to match on input'
    );
    Assert.areEqual(
      PARAM_VALUE,
      result,
      'Expected mock success router to parrot input'
    );
  }

  private inherited sharing class GoRouterSelector extends GoRouter.Selector {
    public override boolean hasCustomPermission(String permission) {
      return hasCustomPermissionForRouter;
    }

    public override Go_Router__mdt[] getRoutersWithKeys(Set<String> keys) {
      return configsToReturn;
    }
  }

  public inherited sharing class FailureRouter extends GoRouter {
    public override String route(String param) {
      super.matchedOnInput = false;
      return '';
    }
  }

  public inherited sharing class SuccessRouter extends GoRouter {
    public override String route(String param) {
      super.matchedOnInput = true;
      return param;
    }
  }

  public inherited sharing class DelegateRouter extends GoRouter {
    private final GoRouter[] delegates;

    public DelegateRouter(GoRouter[] delegates) {
      this.delegates = delegates;
    }

    public override String route(String param) {
      return delegateTo(param, delegates);
    }
  }
}
