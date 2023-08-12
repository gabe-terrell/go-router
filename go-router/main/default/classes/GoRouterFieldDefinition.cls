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
 * @description Apex GoRouter for searching for Object Fields in the Object.
 * Manager
 */
public without sharing class GoRouterFieldDefinition extends GoRouterRecord {
  /*
   * @description Static constant to redirect to ObjectManager home if no match.
   */
  @TestVisible
  private static final String REDIRECT_PATH = '/lightning/setup/ObjectManager/home';

  /*
   * @description Static constant to route record to corresponding page.
   */
  @TestVisible
  private static final String RECORD_PATH = '/lightning/setup/ObjectManager/{0}/FieldsAndRelationships/{1}/view';

  /*
   * @description Since this subclasses GoRouterRecord, spoof a Go_Router__mdt
   * rule for binding an SObjectType.
   */
  public GoRouterFieldDefinition() {
    super(new Go_Router__mdt(Entity__c = FieldDefinition.class.toString()));
  }

  /*
   * @description Override query() to  query against Object and Field name.
   */
  public override String query(String param) {
    String[] components = param.split('\\.');
    if (components.size() != 2) {
      // fail out if we get poorly formed input
      return 'Id = null';
    }
    String entity = components[0];
    String field = components[1].trim();
    String format = 'EntityDefinition.QualifiedApiName = \'\'{0}\'\' AND QualifiedApiName = \'\'{1}\'\'';
    return String.format(format, new List<String>{ entity, field });
  }

  /*
   * @description Override fieldQuery() to include additional fields necessary
   * for routing logic.
   */
  public override String fieldQuery() {
    return 'Id, DurableId, QualifiedApiName, EntityDefinition.QualifiedApiName';
  }

  /*
   * @description Override limitQuery() because FieldDefinition queries may not
   * include a LIMIT without SOQL failing.
   */
  public override String limitQuery() {
    return '';
  }

  /*
   * @description Override redirect() to route to Object Manager home.
   */
  public override String redirect(String param) {
    // There has been some weird capitalization issues with
    // matching against FieldDefinition names, so try a more
    // generalized second attempt, otherwise redirect per usual
    FieldDefinition field = fuzzyMatch(param);
    if (field != null) {
      return route(field);
    }
    return REDIRECT_PATH;
  }

  /*
   * @description Override route() to go to the correct record page based on
   * the type of object found.
   */
  public override String route(Sobject obj) {
    FieldDefinition field = (FieldDefinition) obj;
    String[] components = field.DurableId.split('\\.');
    String entityId = components[0];
    String fieldId = components[1];

    return String.format(RECORD_PATH, new List<String>{ entityId, fieldId });
  }

  /*
   * @description A more leniant approach compared to ApexRecordRouter's
   * likeQuery fallback. FieldDefinition queries have proven to be more finicky
   * with capitalization, so this is a more successful solution to finding
   * matches against queries.
   */
  public FieldDefinition fuzzyMatch(String param) {
    String[] components = param.split('\\.');
    if (components.size() != 2) {
      // fail out if we get poorly formed input
      return null;
    }
    String entity = components[0].trim().replaceAll(' ', '_');
    String fieldName = components[1].trim().replaceAll(' ', '_').toLowercase();
    String regularEntity = '%' + entity + '%';
    String customEntity = '%' + entity + '__c%';

    FieldDefinition[] fields = [
      SELECT DurableId, EntityDefinition.QualifiedApiName, QualifiedApiName
      FROM FieldDefinition
      WHERE
        EntityDefinition.QualifiedApiName LIKE :regularEntity
        OR EntityDefinition.QualifiedApiName LIKE :customEntity
    ];

    for (FieldDefinition field : fields) {
      String name = field.QualifiedApiName.toLowercase();
      if (name.contains(fieldName)) {
        matchedOnInput = true;
        return field;
      }
    }
    return null;
  }
}
