RSpec.shared_context 'elasticseach', elasticseach: true do
  before(:each) do
    ElasticsearchService.client.indices.delete index: ElasticsearchService.index_name rescue nil
  end

  def refresh_index
    ElasticsearchService.client.indices.refresh index: ElasticsearchService.index_name
  end

  def search_counters
    response = ElasticsearchService.client.search index: ElasticsearchService.index_name, type: 'counter', body: { query: { match_all: {} } }
    SearchResponse.new(response)
  end

  def search_sets
    response = ElasticsearchService.client.search index: ElasticsearchService.index_name, type: 'set', body: { query: { match_all: {} } }
    SearchResponse.new(response)
  end
end
