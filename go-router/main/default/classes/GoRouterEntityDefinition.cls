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
 * @description Apex GoRouter for searching for Objects in the Object Manager.
 */
public without sharing virtual class GoRouterEntityDefinition extends GoRouterRecord {
  /*
   * @description Static constants to redirect to ObjectManager home if no match.
   */
  @TestVisible
  private static final String REDIRECT_PATH = '/lightning/setup/ObjectManager/home';

  /*
   * @description Static constants to route record to corresponding page.
   */
  @TestVisible
  private static final String RECORD_PATH_LIGHTNING = '/lightning/setup/ObjectManager/{0}/FieldsAndRelationships/view';
  @TestVisible
  private static final String RECORD_PATH_LIGHTNING_METADATA = '/lightning/setup/CustomMetadata/page?address=%2F{0}%3Fsetupid%3DCustomMetadata';
  @TestVisible
  private static final String RECORD_PATH_LIGHTNING_CUSTOM_SETTING = '/lightning/setup/CustomSettings/page?address=%2Fsetup%2Fui%2FviewCustomSettings.apexp%3Fid%3D{0}';
  @TestVisible
  private static final String RECORD_PATH_LIGHTNING_PLATFORM_EVENT = '/lightning/setup/EventObjects/page?address=%2F01I5w000000kGgA';

  /*
   * @description Since this subclasses GoRouterRecord, spoof a Go_Router__mdt
   * config for binding an SObjectType.
   */
  public GoRouterEntityDefinition() {
    super(new Go_Router__mdt(Entity__c = EntityDefinition.class.toString()));
  }

  /*
   * @description Override query() to match against standard, custom, and MDT
   * objects.
   */
  public override String query(String param) {
    String standardTerm = param.replaceAll(' ', '');
    String customTerm = param.replaceAll(' ', '_');
    String format =
      'QualifiedApiName  = \'\'{0}\'\'' +
      ' OR QualifiedApiName = \'\'{1}__c\'\'' +
      ' OR QualifiedApiName = \'\'{1}__mdt\'\'';
    return String.format(format, new List<String>{ standardTerm, customTerm });
  }

  /*
   * @description Override likeQuery() to broadly match against standard,
   * custom, and MDT objects.
   */
  public override String likeQuery(String param) {
    String likeTerm = param.replaceAll(' ', '_');
    String standardTerm = param.replaceAll(' ', '');
    String format =
      'QualifiedApiName LIKE \'\'%{0}%\'\'' +
      ' OR QualifiedApiName LIKE \'\'%{1}%\'\'';
    return String.format(format, new List<String>{ likeTerm, standardTerm });
  }

  /*
   * @description Override fieldQuery() to include additional fields necessary
   * for routing logic.
   */
  public override String fieldQuery() {
    return 'Id, DurableId, IsCustomSetting, KeyPrefix, QualifiedApiName';
  }

  /*
   * @description Override limitQuery() because EntityDefinition queries may
   * not include a LIMIT without SOQL failing.
   */
  public override String limitQuery() {
    return '';
  }

  /*
   * @description Override redirect() to route to Object Manager home.
   */
  public virtual override String redirect(String param) {
    return REDIRECT_PATH;
  }

  /*
   * @description Override route() to go to the correct record page based on
   * the type of object found.
   */
  public virtual override String route(Sobject obj) {
    EntityDefinition entity = (EntityDefinition) obj;
    final String path;
    if (entity.QualifiedApiName.endsWith('__mdt')) {
      path = RECORD_PATH_LIGHTNING_METADATA;
    } else if (entity.QualifiedApiName.endsWith('__e')) {
      path = RECORD_PATH_LIGHTNING_PLATFORM_EVENT;
    } else if (entity.isCustomSetting) {
      path = RECORD_PATH_LIGHTNING_CUSTOM_SETTING;
    } else {
      path = RECORD_PATH_LIGHTNING;
    }
    return String.format(path, new List<String>{ entity.DurableId });
  }
}
