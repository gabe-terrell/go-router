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
 * @description Apex GoRouter for navigating to object list views
 */
public without sharing class GoRouterObjectList extends GoRouterEntityDefinition {
  /*
   * @description Path to Lightning List View
   */
  @TestVisible
  private static final String LIST_VIEW_PATH = '/lightning/o/{0}/list';
  @TestVisible
  private static final String LIST_VIEW_PATH_METADATA = '/lightning/setup/CustomMetadata/page?address=%2F{0}%3Fsetupid%3DCustomMetadata';
  @TestVisible
  private static final String LIST_VIEW_PATH_CUSTOM_SETTING = '/lightning/setup/CustomSettings/page?address=%2Fsetup%2Fui%2FlistCustomSettingsData.apexp%3Fid%3D{0}';

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
        LIST_VIEW_PATH_METADATA,
        new List<String>{ entity.KeyPrefix }
      );
    } else if (entity.IsCustomSetting) {
      return String.format(
        LIST_VIEW_PATH_CUSTOM_SETTING,
        new List<String>{ entity.KeyPrefix }
      );
    } else {
      return String.format(
        LIST_VIEW_PATH,
        new List<String>{ entity.QualifiedApiName }
      );
    }
  }
}
