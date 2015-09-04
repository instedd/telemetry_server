class EventIndexer
  def initialize
    @client = ElasticsearchService.client
  end

  def index(event)
    data = JSON.parse(event.data)
    counters_data = index_counters event, data['period'], data['counters'] || []
    sets_data = index_sets event, data['period'], data['sets'] || []
    bulk_index counters_data.concat(sets_data)
  end

  private

  def index_counters(event, period, counters)
    index_data = {index: {_type: 'counter'}}
    bulk_data = []

    counters.each do |counter|
      bulk_data.push index_data
      bulk_data.push({
        installation_uuid: event.installation.uuid,
        kind: counter['type'],
        key: counter['key'],
        value: counter['value'],
        beginning: period['beginning'],
        end: period['end']
      })
    end

    bulk_data
  end

  def index_sets(event, period, sets)
    index_data = {index: {_type: 'set'}}
    bulk_data = []

    sets.each do |set|
      bulk_data.push index_data
      bulk_data.push({
        installation_uuid: event.installation.uuid,
        kind: set['type'],
        key: set['key'],
        elements: set['elements'],
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
