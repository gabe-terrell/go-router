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
 * @description Implementation of GoRouter for 'Record' type routing. Given an
 * object and some rules to find a record, will attempt to find that record and
 * return a page reference to it.
 */
public with sharing virtual class GoRouterRecord extends GoRouter {
  /*
   * @description Static constants defining the Salesforce paths to an Object
   * list view page. If an input is not specified, redirect to the object's page
   * instead.
   */
  private static final String LIGHTNING_OBJECT_VIEW = '/lightning/o/{0}/list';

  /*
   * @description Stores the lookup result of the specified objectType for reuse
   * throughout routing execution.
   */
  private final DescribeSObjectResult objectType;

  /*
   * @description Initializer will lookup the Object data specified in the
   * Go_Router__mdt definition. Note that unit testing will check all MDT for
   * GoRouters, so it is guaranteed that these will be valid.
   */
  public GoRouterRecord(Go_Router__mdt config) {
    super(config);
    objectType = Schema.getGlobalDescribe().get(config.Entity__c).getDescribe();
  }

  /*
   * @description Given input from the user, attempt to find a single record
   * given the queries described in the Go_Router__mdt definition. If exactly
   * one record is found, route to its record page. If 0 or 2+ are found,
   * redirect to search results to allow the user to choose which record they
   * meant to retrieve.
   * @param param - Input of the user (i.e. CaseNumber, UserName, etc.).
   * @return String relative URL of routing result.
   */
  public virtual override String route(String param) {
    // If the user did not provide input, immediately fall into redirect logic
    if (param.trim().length() == 0) {
      matchedOnInput = true;
      return redirect(param);
    }

    SObject record = getRecord(param);

    return record != null ? route(record) : redirect(param);
  }

  /*
   * @description Given input from the user, attempt to find a single record
   * given the queries described in the Go_Router__mdt definition. If exactly
   * one record is found, return the record. If 0 or 2+ are found, return null.
   * @param param - Input of the user (e.g. CaseNumber, Username, etc.).
   * @return SObject if query results in exactly one match.
   */
  @SuppressWarnings('PMD.UnusedLocalVariable,PMD.EmptyCatchBlock')
  public SObject getRecord(String param) {
    // These fields can be specified in the Go_Router__mdt definition and are
    // explained in the MDT builder. Ignore "Unused" warning since these are
    // inlined into potential queries.
    Double paramAsNumber;
    String likeParam = param.replace(' ', '%');
    String startsQuery = likeParam + '%';
    String endsQuery = '%' + likeParam;
    likeParam = '%' + likeParam + '%';
    try {
      paramAsNumber = Double.valueOf(param);
    } catch (System.TypeException ex) {
      // silently ignore, no guarantee for param to be a number
    }

    Sobject[] results = new List<SObject>{};

    // The Go_Router__mdt allows for two SOQL queries. An exact query and a like
    // query. If the exact query did not produce a result, fall back to the like
    // query to see if produces the desired result. Otherwise redirect.
    String query = query(param);
    if (query != null) {
      results = Database.query(buildQuery(query));
    }
    if (results.size() == 1) {
      matchedOnInput = true;
      return results[0];
    }

    String likeQuery = likeQuery(param);
    if (likeQuery != null) {
      results = Database.query(buildQuery(likeQuery));
    }
    if (results.size() == 1) {
      matchedOnInput = true;
      return results[0];
    }

    return null;
  }

  /*
   * @description Helper method to build the SOQL query from the query passed
   * in.
   * @param query - Query used for WHERE clause.
   * @return String full SOQL query to execute.
   */
  public String buildQuery(String query) {
    return 'SELECT ' +
      fieldQuery() +
      ' FROM ' +
      objectType.getName() +
      ' WHERE ' +
      query +
      limitQuery();
  }

  /*
   * @description By default, the query value is expected to be grabbed from the
   * Go_Router__mdt definition. For Apex routers subclassing GoRouterRecord,
   * this behavior can be overriden.
   */
  public virtual String query(String param) {
    return super.config.Query__c;
  }

  /*
   * @description By default, the likeQuery value is expected to be grabbed from
   * the Go_Router__mdt definition. For Apex routers subclassing GoRouterRecord,
   * this behavior can be overriden.
   */
  public virtual String likeQuery(String param) {
    return super.config.Like_Query__c;
  }

  /*
   * @description By default, Go_Router__mdt 'Record' definitions only need the
   * Id field. For Apex routers subclassing GoRouterRecord, this behavior can be
   * overriden.
   */
  public virtual String fieldQuery() {
    return 'Id';
  }

  /*
   * @description By default, Go_Router__mdt 'Record' definitions only need a
   * limit of 2. For Apex routers subclassing GoRouterRecord, this behavior can
   * be overriden.
   */
  public virtual String limitQuery() {
    return ' LIMIT 2 ';
  }

  /*
   * @description By default, the isSetupObject value is expected to be grabbed
   * from the Go_Router__mdt definition. For Apex routers subclassing
   * GoRouterRecord, this behavior can be overriden.
   */
  public virtual Boolean isSetupObject() {
    return super.config.Is_Setup_Record__c;
  }

  /*
   * @description Given a record, return the relative URL to route to its record
   * page. The standard route will be used unless overridden by Go_Router__mdt
   * rules.
   * @param obj The sObject to route to.
   * @return String the relative URL to the record page.
   */
  public virtual String route(Sobject obj) {
    if (super.config.Record_Page__c != null) {
      return String.format(
        super.config.Record_Page__c,
        new List<String>{ obj.Id }
      );
    }
    return new GoRouterId().route(obj.Id);
  }

  /*
   * @description If an exact record was not determined to be routed to, fall
   * back to a helpful result page.
   * @param param - String the original input passed in by the user.
   * @return String the relative URL to route to.
   */
  public virtual String redirect(String param) {
    if (super.config.Redirect_Path__c != null) {
      GoRouter redirectRouter = new GoRouterRedirect(super.config);
      return redirectRouter.route(param);
    }
    // If no search query was actually given, redirect to the proper Record List
    // page for the object.
    if (String.isEmpty(param)) {
      if (isSetupObject()) {
        return getSetupPath();
      } else {
        return getObjectViewPath();
      }
    }
    // Otherwise, redirect to Salesforce search given the input and with a scope
    // for the specific Object type.
    return new GoRouterSearch().route(param, objectType, isSetupObject());
  }

  /*
   * @description For Setup objects, the Setup Router can generally point to the
   * correct Setup path for that object. If it is not covered, it can be
   * overriden by the Go_Router__mdt definition.
   */
  public virtual String getSetupPath() {
    if (super.config.Redirect_Path__c != null) {
      return super.config.Redirect_Path__c;
    }
    return new GoRouterSetup().route(objectType.getName());
  }

  /*
   * @description Helper method to build the relative URL to the List View page
   * for the object defined by the Router.
   * @return String the relative URL to route to.
   */
  public virtual String getObjectViewPath() {
    return String.format(
      LIGHTNING_OBJECT_VIEW,
      new List<String>{ objectType.getName() }
    );
  }
}
