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
 * @description Apex GoRouter for better redirecting setup objects.
 */
public without sharing class GoRouterId extends GoRouter {
  /*
   * @description Route to non-standard record pages.
   * @param id - the record id.
   * @return String the relative URL to route to.
   */
  public override String route(String param) {
    if (!(param instanceof Id)) {
      return '/';
    }

    String url = objectUrl(param.substring(0, 3), param);
    return String.format(url, new List<String>{ param });
  }

  private static String objectUrl(String prefix, Id id) {
    DescribeSObjectResult describe = id.getSObjectType().getDescribe();
    if (describe.getName().endsWith('__mdt')) {
      return '/lightning/setup/CustomMetadata/page?address=%2F{0}';
    }
    if (describe.isCustomSetting()) {
      return '/lightning/setup/CustomSettings/page?address=%2F{0}';
    }
    switch on prefix {
      // ApexClass
      when '01p' {
        return '/lightning/setup/ApexClasses/page?address=%2F{0}';
      }
      // AsyncApiJob
      when '750' {
        return '/lightning/setup/AsyncApiJobStatus/page?address=%2F{0}';
      }
      // DeployRequest
      when '0Af' {
        return '/lightning/setup/DeployStatus/page?address=%2Fchangemgmt%2FmonitorDeploymentsDetails.apexp%3FasyncId%3D{0}';
      }
      // EmailRoutingAddress
      when '02t' {
        return '/lightning/setup/EmailToCase/page?address=%2F{0}';
      }
      // EmailTemplate
      when '00X' {
        return '/lightning/setup/CommunicationTemplatesEmail/page?address=%2F{0}';
      }
      // Group (also redirects for Queue)
      when '00G' {
        return '/lightning/setup/PublicGroups/page?address=%2Fsetup%2Fown%2Fgroupdetail.jsp%3Fid%3D{0}';
      }
      // InteractionDefinitionVersion (Flow)
      when '301' {
        return '/builder_platform_interaction/flowBuilder.app?flowId={0}';
      }
      // LiveChatButton
      when '573' {
        return '/lightning/setup/LiveChatButtonSettings/page?address=%2F{0}';
      }
      // LiveChatDeployment
      when '572' {
        return '/lightning/setup/LiveChatDeploymentSettings/page?address=%2F{0}';
      }
      // OrgWideEmailAddress
      when '0D2' {
        return '/lightning/setup/OrgWideEmailAddresses/page?address=%2F{0}';
      }
      // PermissionSet
      when '0PS' {
        return '/lightning/setup/PermSets/page?address=%2F{0}';
      }
      // Profile
      when '00e' {
        return '/lightning/setup/Profiles/page?address=%2F{0}';
      }
      // UserRole
      when '00E' {
        return '/lightning/setup/Roles/page?address=%2F{0}%3Fsetupid%3DRoles';
      }
      when else {
        return '/{0}';
      }
    }
  }
}
