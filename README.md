# Instedd Telemetry Server

[![Build Status](https://travis-ci.org/instedd/telemetry_server.svg?branch=master)](https://travis-ci.org/instedd/telemetry_server)

## Dependencies

* Ruby 2.2.2
* Bundler
* PostgreSQL
* ElasticSearch 2.1+
* Kibana 4.3+

## Installation

Clone this repository and fetch the dependencies using bundler:

```
bundle install
```

Initialize database:

```
bundle exec rake db:create db:schema:load db:seed
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

   * `telemetry*` with time-based events using the field `beginning`
   * `telem*` with time-based events using the field `created_at`


Some features of these dashboards may not work on old versions of ElasticSearch. Versions >= 2.1 should work fine.

# License

Telemetry Server is released under the [GPLv3 license](LICENSE).
