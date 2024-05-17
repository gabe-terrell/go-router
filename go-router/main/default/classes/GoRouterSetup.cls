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
 * @description Apex GoRouter for shorthands to certain Setup pages.
 */
@SuppressWarnings('PMD.AvoidDuplicateStrings')
public without sharing class GoRouterSetup extends GoRouter {
  private static final String LIGHTNING_SETUP_PATH = '/lightning/setup/{0}/home';

  /*
   * @description Mappings of shorthand terms to corresponding setup pages.
   */
  private static final Map<String, String> SHORTCUTS = new Map<String, String>{
    '' => 'SetupOneHome',
    'apex' => 'ApexClasses',
    'approvalprocess' => 'ApprovalProcesses',
    'approvalprocesses' => 'ApprovalProcesses',
    'approvals' => 'ApprovalProcesses',
    'apps' => 'NavigationMenus',
    'auras' => 'LightningComponentBundles',
    'authproviders' => 'AuthProviders',
    'auths' => 'AuthProviders',
    'businesshours' => 'BusinessHours',
    'buttons' => 'LiveChatButtonSettings',
    'caches' => 'PlatformCache',
    'caseteamroles' => 'CaseTeamRoles',
    'caseteams' => 'CaseTeamTemplates',
    'company' => 'CompanyProfileInfo',
    'cors' => 'CorsWhitelistEntries',
    'chatbuttons' => 'LiveChatButtonSettings',
    'chatconfigs' => 'LiveChatUserConfigSettings',
    'chatdeployments' => 'LiveChatDeploymentSettings',
    'chatdeploys' => 'LiveChatDeploymentSettings',
    'cps' => 'CustomPermissions',
    'creds' => 'NamedCredential',
    'custommetadatas' => 'CustomMetadata',
    'customnotifications' => 'CustomNotifications',
    'custompermissions' => 'CustomPermissions',
    'customperms' => 'CustomPermissions',
    'customsettings' => 'CustomSettings',
    'debugs' => 'ApexDebugLogs',
    'deliverability' => 'OrgEmailSettings',
    'deploys' => 'DeployStatus',
    'devhub' => 'DevHub',
    'devops' => 'DevOpsCenterSetup',
    'domains' => 'DomainNames',
    'duplicaterules' => 'DuplicateRules',
    'duplicates' => 'DuplicateRules',
    'e2a' => 'EmailToApexFunction',
    'e2c' => 'EmailToCase',
    'emails' => 'CommunicationTemplatesEmail',
    'emailtemplates' => 'CommunicationTemplatesEmail',
    'emailtoapex' => 'EmailToApexFunction',
    'emailtocase' => 'EmailToCase',
    'events' => 'EventObjects',
    'feedtracking' => 'FeedTracking',
    'files' => 'StaticResources',
    'flexipages' => 'FlexiPageList',
    'flows' => 'Flows',
    'globalvaluesets' => 'Picklists',
    'groups' => 'PublicGroups',
    'holidays' => 'Holiday',
    'hours' => 'BusinessHours',
    'import' => 'DataManagementDataImporter',
    'jobs' => 'AsyncApexJobs',
    'labels' => 'ExternalStrings',
    'languages' => 'LanguageSettings',
    'laps' => 'LoginAccessPolicies',
    'livechatbuttons' => 'LiveChatButtonSettings',
    'livechatdeployments' => 'LiveChatDeploymentSettings',
    'loginaccesspolicies' => 'LoginAccessPolicies',
    'loginaccess' => 'LoginAccessPolicies',
    'logs' => 'ApexDebugLogs',
    'lwcs' => 'LightningComponentBundles',
    'matching' => 'MatchingRules',
    'matchingrules' => 'MatchingRules',
    'mdts' => 'CustomMetadata',
    'metadata' => 'CustomMetadata',
    'namedcredential' => 'NamedCredential',
    'ncs' => 'NamedCredential',
    'nextbestactions' => 'NextBestAction',
    'objects' => 'ObjectManager',
    'obms' => 'WorkflowOutboundMessaging',
    'om' => 'ObjectManager',
    'optimizer' => 'SalesforceOptimizer',
    'orgs' => 'CompanyProfileInfo',
    'orgshapes' => 'ShapeGrantAccess',
    'owas' => 'OrgWideEmailAddresses',
    'packagemanager' => 'Package',
    'packages' => 'ImportedPackage',
    'pbs' => 'ProcessAutomation',
    'permissionsets' => 'PermSets',
    'picklists' => 'Picklists',
    'platformevents' => 'EventObjects',
    'pman' => 'Package',
    'presence' => 'ServicePresenceStatusSettings',
    'presenceconfigs' => 'ServicePresenceUserConfigSettings',
    'presencedeclines' => 'ServicePresenceDeclineReasonSettings',
    'presencestatus' => 'ServicePresenceStatusSettings',
    'processbuilders' => 'ProcessAutomation',
    'profs' => 'EnhancedProfiles',
    'profiles' => 'EnhancedProfiles',
    'ps' => 'PermSets',
    'queues' => 'Queues',
    'releases' => 'ReleaseUpdates',
    'releaseupdates' => 'ReleaseUpdates',
    'resources' => 'StaticResources',
    'roles' => 'Roles',
    'routing' => 'QueueRoutingConfigSettings',
    'routingconfigs' => 'QueueRoutingConfigSettings',
    'sandbox' => 'DataManagementCreateTestInstance',
    'sandboxes' => 'DataManagementCreateTestInstance',
    'scheduled' => 'ScheduledJobs',
    'scheduledjobs' => 'ScheduledJobs',
    'schemabuilder' => 'SchemaBuilder',
    'schemas' => 'SchemaBuilder',
    'sharing' => 'SecuritySharing',
    'sites' => 'CustomDomain',
    'slas' => 'SlaProcess',
    'ssos' => 'SingleSignOn',
    'statics' => 'StaticResources',
    'staticresources' => 'StaticResources',
    'storage' => 'CompanyResourceDisk',
    'tabs' => 'CustomTabs',
    'templates' => 'CommunicationTemplatesEmail',
    'triggers' => 'ApexTriggers',
    'users' => 'ManageUsers',
    'vf' => 'ApexPages',
    'vfcomponents' => 'ApexComponents',
    'vfpages' => 'ApexPages',
    'wizards' => 'DataManagementDataImporter',
    'workflows' => 'WorkflowRules'
  };

  /*
   * @description Route to a specific Salesforce URL given the presence or lack
   * of input.
   * @param param - String the input passed in by the user.
   * @return String the relative URL to route to.
   */
  public override String route(String param) {
    String key = keyForPage(param);
    super.matchedOnInput = !String.isBlank(key) || String.isBlank(param);
    return routePage(key);
  }

  /*
   * @description Helper method to determine the correct key given an input.
   * Thus searching for "app" or "apps" yields the same result.
   * @param param - String the input passed in by the user.
   * @return String the corresponding key to the route if it exists.
   */
  public String keyForPage(String key) {
    key = key.replaceAll(' ', '').toLowerCase();
    if (SHORTCUTS.containsKey(key)) {
      return key;
    }
    if (SHORTCUTS.containsKey(key + 's')) {
      return key + 's';
    }
    return '';
  }

  /*
  * @description Used by VF page to retrieve all valid pages that can be routed to
  and the inputs that lead to them. Constructs this list one and stores it as
  allInputs, which future calls will then return directly.
  * @return Map of String input to String combined list of valid shortcuts.
  */
  public Map<String, String> getAllInputs {
    get {
      if (allInputs == null) {
        allInputs = new Map<String, String>();
        for (String shortcut : SHORTCUTS.keySet()) {
          if (shortcut == '') {
            continue;
          }
          String value = SHORTCUTS.get(shortcut);
          if (allInputs.containsKey(value)) {
            allInputs.put(value, allInputs.get(value) + ', ' + shortcut);
          } else {
            allInputs.put(value, shortcut);
          }
        }
      }
      return allInputs;
    }
    private set;
  }

  /*
  * @description Stores all valid pages that can be routed to
  and the inputs that lead to them. It is constructed once in the 
  getAllInputs property.
  */
  private Map<String, String> allInputs;

  /*
   * @description Helper method to return the proper route.
   * @param param - String the key to the route.
   * @return String the relative URL to route to.
   */
  public String routePage(String param) {
    String setupPage = SHORTCUTS.get(param);
    return String.format(LIGHTNING_SETUP_PATH, new List<String>{ setupPage });
  }
}
