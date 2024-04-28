# Go Router

## Overview

The Go Router Framework allows developers and administrators to quickly and
easily build shorthand, human-readable URLs to navigate to pages within a
Salesforce instance.

The framework supports easily creating aliases to specific pages, looking up
records based on a keyword, and creating custom Apex classes to support more
complex routing.

Each route can be hidden behind a custom permission, allowing segementation of
links to only the right users that should be able to access them.

Not only can go-links be defined, but the query URL can also be registered as a
search engine into internet browsers to quickly navigate to any page of a
Salesforce instance with only a few key strokes!

## Defining Routers

Each route is defined by a corresponding `Go_Router__mdt` record. The following
fields are used to define behavior for all routers:

| Field              | Usage                                                   |
| ------------------ | ------------------------------------------------------- |
| Type               | The type of router: Redirect, Record, Apex. See more below.      |
| Key                | The key used to use this route (e.g. `/apex/go?{key}={input}`).                      |
| Input              | A String explaining what input to send to this router. Used for the help page only.       |
| Usage              | A String explaining what the router does. Used for the help page only.              |
| Is Default Router? | If set, this router will be used when no key is matched from a query. (e.g. `/apex/go?query={input}`)  |
| Custom Permission  | API Name of a Custom Permission. If set, the user must have this custom permission to see and use the route.  |

### Redirect Routers

Redirect routers are used to route to a relative URL within Salesforce. The
route can optionally be modified based on input being passed in or not:

| Field                    | Usage                                      |
| ------------------------ | ------------------------------------------ |
| Redirect Path            | The relative URL to redirect to            |
| Redirect Path With Param | If input is provided, redirect to this URL instead. Pass in the param using `{0}` |

Here is an example to setup a router that makes it easy to install second
generation packages. If a package ID is passed in, the route will redirect to
the installation URL. If no input is passed in, it will instead redirect to the
setup page listing all installed packages.

### Record Routers

Redirect routers are used to route to a record based on a unique value. A SOQL
query will be defined based on the config, and if the query returns exactly 1
result, it will route to the corresponding record page. To add more flexibility
to the search, two queries can be defined: a specific query and a broader "like"
query. If the specific query fails, the broader query will be performed as a
second chance to match on the input. If both fail, it will redirect to the
Salesforce search page, scoping the query to the specific object (this even
works for setup objects!).

| Field            | Usage                                                     |
| ---------------- | --------------------------------------------------------- |
| Entity           | The API Name of the SObject being queried.                |
| Query            | The WHERE clause defining the query.                      |
| Like Query       | The WHERE clause defining the optional broader query. It's usually expected to use a `LIKE` clause if used.    |
| Is Setup Record? | If set, denotes the SObject as being a Setup Object (e.g. Group, Role, etc.). This is used for rerouting to the record page and for scoping search.    |
| Record Page      | If set, overrides the URL to navigate to upon finding a matching record. Pass in the ID using `{0}`.  |

Here is an example to setup a router that queries for a Case using CaseNumber.
This is helpful since a lot of references to a Case are by using the CaseNumber
instead of the ID. Using the Like Query, the query can also search for a
CaseNumber where the leading zeros have been removed.

### Apex Routers

For routers requiring more complex logic, an Apex class that extends
GoRouter
can be created. An example of a simple use case is defining a router for
handling the default router of an instance. This can involve sending the input
to a couple of common use cases and falling back to search. Take the following
example:

```java
public with sharing class GoRouterDefault extends GoRouter {
  public override String route(String param) {
    // Search for Case or User, most common needs of users of this instance.
    Set<String> keys = new Set<String>{'c', 'u'};
    for (GoRouter router : GoRouter.forKeys(keys)) {
      String result = router?.route(param);
      if (router?.matchedOnInput == true) {
        matchedOnInput = true;
        return result;
      }
    }
    // Fallback to global search if no match.
    return new GoRouterSearch().route(param);
  }
}
```

## Setting up a Chrome Search Engine

To create a custom search engine to quickly navigate to an instance with only a
few keystrokes in the omnibar, do the following:

1.  Open up a new tab and go to
    [manage search engines settings](chrome://settings/searchEngines)
2.  Navigate to the `Site search` section, and click the `add` button.
3.  Create the new search engine with the following parameters:

    1.  Search Engine: The name for the engine, as will appear in the omnibar

    2.  Shortcut: The shorthand to enable the search. For example, if the
        shortcut is `sf`, then typing `sf` followed by a space in the omnibar
        will invoke a search.

    3.  URL: Should take the form of
        `https://{myinstance}.lightning.force.com/apex/go?query=%s`

