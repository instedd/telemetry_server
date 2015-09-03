class SearchResponse
  def initialize(response)
    @response = response
  end

  def total
    @response['hits']['total']
  end

  def results
    @response['hits']['hits'].map{|x| x['_source'].merge('_id' => x['_id'])}
  end
end
