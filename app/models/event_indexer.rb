class EventIndexer
  def initialize
    @client = ElasticsearchService.client
  end

  def index(event)
    data = JSON.parse(event.data)

    period = data['period']
    application = data['application'] || event.installation.application
    counters = data['counters'] || []
    sets = data['sets'] || []
    timespans = data['timespans'] || []

    counters_data = index_counters event, application, period, counters
    sets_data = index_sets event, application, period, sets
    timespans_data = index_timespans event, application, period, timespans

    bulk_index counters_data.concat(sets_data).concat(timespans_data)
  end

  private

  def index_counters(event, application, period, counters)
    bulk_data = []

    counters.each_with_index do |counter, i|
      bulk_data.push({index: {_type: 'counter', _id: "#{event.id}-#{i}"}})
      bulk_data.push({
        installation_uuid: event.installation.uuid,
        application: application,
        metric: counter['metric'],
        key: counter['key'],
        value: counter['value'],
        beginning: period['beginning'],
        end: period['end']
      })
    end

    bulk_data
  end

  def index_sets(event, application, period, sets)
    bulk_data = []

    sets.each_with_index do |set, i|
      bulk_data.push({index: {_type: 'set', _id: "#{event.id}-#{i}"}})
      bulk_data.push({
        installation_uuid: event.installation.uuid,
        application: application,
        metric: set['metric'],
        key: set['key'],
        elements: set['elements'],
        beginning: period['beginning'],
        end: period['end']
      })
    end

    bulk_data
  end

  def index_timespans(event, application, period, timespans)
    bulk_data = []

    timespans.each_with_index do |set, i|
      bulk_data.push({index: {_type: 'timespan', _id: "#{event.id}-#{i}"}})
      bulk_data.push({
        installation_uuid: event.installation.uuid,
        application: application,
        metric: set['metric'],
        key: set['key'],
        days: set['days'],
        beginning: period['beginning'],
        end: period['end']
      })
    end

    bulk_data
  end

  def bulk_index(data)
    @client.bulk index: ElasticsearchService.index_name, body: data
  end
end
