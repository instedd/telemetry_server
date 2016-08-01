# Instedd Telemetry Server

[![Build Status](https://travis-ci.org/instedd/telemetry_server.svg?branch=master)](https://travis-ci.org/instedd/telemetry_server)

## Dependencies

* Ruby 2.2.2
* Bundler
* PostgreSQL
* ElasticSearch 2.3+
* Kibana 4.5+ ([custom build](https://github.com/instedd/telemetry-kibana))

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

### Docker development

`docker-compose.yml` file build a development environment mounting the current folder and running rails in development environment.

Run the following commands to have a stable development environment.

```
$ docker-compose run --rm --no-deps web bundle install
$ ./on-web rake db:create db:schema:load db:seed
$ ./on-web rake elasticsearch:init
$ ./on-web rake telemetry:geoip
$ docker-compose up
```

In order to create fake data:

```
$ ./on-web rake telemetry:fake_data
```

To setup and run test, once the web container is running:

```
$ docker exec -it resourcemap_web_1 bash
root@45ccfa697a3a:/app# RAILS_ENV=test rake db:create db:schema:load
$ ./on-web rake
$ ./on-web rake spec SPEC=spec/models/user_spec.rb
```

#### Cleanup

```
$ docker-compose rm -v -f
$ docker volume rm $(docker volume ls -q | grep ^telemetryserver)
```

## Kibana Dashboards

Visualization definitions are stored in the "visualizations" subdirectory. These are json files that can be imported into a Kibana installation.

Before importing them, set up the following index patterns:

   * `telemetry*` with time-based events using the field `beginning`
   * `telem*` with time-based events using the field `created_at`

Events with `created_at` corresponds to `installation` events, so they serve to ananlyze instaces stateless metric, like lat*lng, number of instances, number of applications.

All other events will have a `beginning` field since they are bounded to a period.

Visualizations that show evolution through the time are easy to build form `telemetry*` index pattern.

If a metric is needed to, for example count the number of accounts, showing only the last known number, then a filter on the metric should be added: `metric:accounts AND beginning:[now-2w TO now]`. This works since the reporting period of all instances is 2 weeks long (yet in staging environment is 3 days). Notice that these widgets won't be affected by the general time filter of the dashboard (ie: last 5 years). Kibana's limitation to perform aggregations and grouping on visualization is forcing this workaround.

Some features of these dashboards may not work on old versions of ElasticSearch. Versions >= 2.3 should work fine.

# License

Telemetry Server is released under the [GPLv3 license](LICENSE).
