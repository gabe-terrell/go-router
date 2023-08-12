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
 * @description Apex GoRouter for navigating to new page for an object.
 */
public without sharing class GoRouterObjectNew extends GoRouterEntityDefinition {
  @TestVisible
  private static final String NEW_PATH = '/lightning/o/{0}/new';
  @TestVisible
  private static final String NEW_PATH_METADATA = '/lightning/setup/CustomMetadata/page?address=%2F{0}%2Fe';
  @TestVisible
  private static final String NEW_PATH_CUSTOM_SETTING = '/lightning/setup/CustomSettings/page?address=%2Fsetup%2Fui%2FeditCustomSettingsData.apexp%3Fclc%3D1%26id%3D{0}';
  @TestVisible
  private static final Map<String, String> SETUP_PAGES = new Map<String, String>{
    'caseteam' => '/lightning/setup/CaseTeamTemplates/page?address=%2F0B4%2Fe%3Fkp%3D500',
    'cp' => '/lightning/setup/CustomPermissions/page?address=%2F0CP%2Fe',
    'custompermission' => '/lightning/setup/CustomPermissions/page?address=%2F0CP%2Fe',
    'flexipage' => '/visualEditor/appBuilder.app',
    'group' => '/lightning/setup/PublicGroups/page?address=%2Fsetup%2Fown%2Fgroupedit.jsp',
    'label' => '/lightning/setup/ExternalStrings/page?address=%2F101%2Fe%3FretURL%3D%252F101',
    'ps' => '/lightning/setup/PermSets/page?address=%2Fudd%2FPermissionSet%2FnewPermissionSet.apexp',
    'permissionset' => '/lightning/setup/PermSets/page?address=%2Fudd%2FPermissionSet%2FnewPermissionSet.apexp',
    'queue' => '/lightning/setup/Queues/page?address=%2Fp%2Fown%2FQueue%2Fe',
    'user' => '/lightning/setup/ManageUsers/page?address=%2F005%2Fe'
  };

  public override String route(String param) {
    // Hardcode pages for certain setup objects
    String key = param.replaceAll(' ', '').toLowerCase();

    if (SETUP_PAGES.containsKey(key)) {
      super.matchedOnInput = true;
      return SETUP_PAGES.get(key);
    }

    return super.route(param);
  }

  /*
   * @description Redirect to home if no matching object is found.
   */
  public override String redirect(String param) {
    return '/';
  }

  /*
   * @description Go to the corresponding object page based on the type of object found.
   */
  public override String route(Sobject obj) {
    EntityDefinition entity = (EntityDefinition) obj;
    if (entity.QualifiedApiName.endsWith('__mdt')) {
      return String.format(
        NEW_PATH_METADATA,
        new List<String>{ entity.KeyPrefix }
      );
    } else if (entity.IsCustomSetting) {
      return String.format(
        NEW_PATH_CUSTOM_SETTING,
        new List<String>{ entity.KeyPrefix }
      );
    } else {
      return String.format(
        NEW_PATH,
        new List<String>{ entity.QualifiedApiName }
      );
    }
  }
}
