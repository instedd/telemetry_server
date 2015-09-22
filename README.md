# Instedd Telemetry Server

## Dependencies

* Ruby 2.2.2
* Bundler
* PostgreSQL
* ElasticSearch

## Installation

Clone this repository and fetch the dependencies using bundler:

```
bundle install
```

Initialize the ElasticSearch index and mappings:

```
rake elasticsearch:init
```

Download the database needed to geocode IPs

```
rake telemetry:geoip
```

## Kibana Dashboards

Visualization definitions are stored in the "visualizations" subdirectory. These are json files that can be imported into a Kibana installation.

Before importing them, set up the following index patterns:

   * `telemetry-*` with time-based events using the field `beginning`
   * `telemetry-dev*` with time-based events using the field `created_at`


Some features of these dashboards may not work on old versions of ElasticSearch. Versions >= 1.7.1 should work fine.

# License

Telemetry Server is released under the [GPLv3 license](LICENSE).
