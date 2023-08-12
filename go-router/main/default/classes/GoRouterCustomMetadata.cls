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
 * @description Apex GoRouter for searching for custom metadata objects.
 * Behavior:
 * mdt -> Setup Page for Custom Metadata
 * mdt Go_Router__mdt -> Setup Page for Custom Metadata Type
 * mdt Go_Router__mdt.CustomMetadata -> Setup Page for mdt record entry
 */
public with sharing class GoRouterCustomMetadata extends GoRouterEntityDefinition {
  private String mdtName;

  public override String redirect(String param) {
    return new GoRouterSetup().route('mdts');
  }

  // Override route to store the mdtName before finding the underlying entity type.
  public override String route(String param) {
    String[] parts = param.split('\\.');
    if (parts.size() > 1) {
      mdtName = parts[1];
    }
    return super.route(parts[0]);
  }

  public override String route(Sobject obj) {
    EntityDefinition entity = (EntityDefinition) obj;
    // Non Custom Metadata entities consitituess a miss.
    // Redirect to Setup page for Custom Metadata.
    if (!entity.QualifiedApiName.endsWith('__mdt')) {
      super.matchedOnInput = false;
      return redirect(null);
    }
    // If only the metadata type was searched for, return its OM page.
    if (String.isBlank(mdtName)) {
      return super.route(obj);
    }
    // Otherwise search for the specific record.
    // Can't have OR clause in MDT SOQL, hence chaining routers.
    GoRouter[] recordRouters = new List<GoRouter>{
      new GoRouterRecord(
        new Go_Router__mdt(
          Entity__c = entity.QualifiedApiName,
          Query__c = 'DeveloperName = :param'
        )
      ),
      new GoRouterRecord(
        new Go_Router__mdt(
          Entity__c = entity.QualifiedApiName,
          Query__c = 'MasterLabel = :param'
        )
      )
    };
    String result = delegateTo(mdtName, recordRouters);
    // If the record was found, route to it.
    // Otherwise assume user's intent was to find a specific record, so route to the
    // record listing page of the specific custom metadata type.
    return super.matchedOnInput ? result : new GoRouterObjectList().route(obj);
  }
}
