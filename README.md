Instedd Telemetry Server
=================

Kibana Dashboards
-------------

Visualization definitions are stored in the "visualizations" subdirectory. These are json files that can be imported into a Kibana installation.

Before importing them, set up the following index patterns:

   * `telemetry-*` with time-based events using the field `beginning`
   * `telemetry-dev*` with time-based events using the field `created_at`


Some features of these dashboards may not work on old versions of Elastic Search. Versions >= 1.7.1 should work fine.