class EventIndexer
  def initialize
    @client = ElasticsearchService.client
  end

  def index(event)
    data = JSON.parse(event.data)
    counters_data = index_counters event, data['period'], data['counters'] || []
    sets_data = index_sets event, data['period'], data['sets'] || []
    timespans_data = index_timespans event, data['period'], data['timespans'] || []
    bulk_index counters_data.concat(sets_data).concat(timespans_data)
  end

  private

  def index_counters(event, period, counters)
    bulk_data = []

    counters.each_with_index do |counter, i|
      bulk_data.push({index: {_type: 'counter', _id: "#{event.id}-#{i}"}})
      bulk_data.push({
        installation_uuid: event.installation.uuid,
        metric: counter['metric'],
        key: counter['key'],
        value: counter['value'],
        beginning: period['beginning'],
        end: period['end']
      })
    end

    bulk_data
  end

  def index_sets(event, period, sets)
    bulk_data = []

    sets.each_with_index do |set, i|
      bulk_data.push({index: {_type: 'set', _id: "#{event.id}-#{i}"}})
      bulk_data.push({
        installation_uuid: event.installation.uuid,
        metric: set['metric'],
        key: set['key'],
        elements: set['elements'],
        beginning: period['beginning'],
        end: period['end']
      })
    end

    bulk_data
  end

  def index_timespans(event, period, timespans)
    bulk_data = []

    timespans.each_with_index do |set, i|
      bulk_data.push({index: {_type: 'timespan', _id: "#{event.id}-#{i}"}})
      bulk_data.push({
        installation_uuid: event.installation.uuid,
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
