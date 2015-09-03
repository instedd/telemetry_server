class EventIndexer
  def initialize
    @client = ElasticsearchService.client
  end

  def index(event)
    data = JSON.parse(event.data)
    index_counters event, data['counters'] || []
    index_sets event, data['sets'] || []
  end

  private

  def index_counters(event, counters)
    counters.each do |counter|
      add_to_index type: 'counter', body: {
        installation_uuid: event.installation.uuid,
        kind: counter['type'],
        key: counter['key'],
        value: counter['value']
      }
    end
  end

  def index_sets(event, sets)
    sets.each do |set|
      add_to_index type: 'set', body: {
        installation_uuid: event.installation.uuid,
        kind: set['type'],
        key: set['key'],
        elements: set['elements']
      }
    end
  end

  def add_to_index(attrs)
    @client.index attrs.reverse_merge(index: ElasticsearchService.index_name)
  end
end
