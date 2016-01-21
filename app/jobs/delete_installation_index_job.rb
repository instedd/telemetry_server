class DeleteInstallationIndexJob < ActiveJob::Base
  queue_as :default

  def perform(installation_id, installation_uuid)
    client = ElasticsearchService.client
    index = ElasticsearchService.index_name

    # Delete installation
    client.delete index: index, type: 'installation', id: installation_id

    # Delete associated events
    # Use scroll + bulk apis to batch delete all matching events
    r = client.search index: index, scroll: '1m', size: 500, body: {
      fields: [],
      query: { match: { installation_uuid: installation_uuid } }
    }

    while r && !r['hits']['hits'].empty? do
      bulk_data = r['hits']['hits'].map do |hit|
        {delete: {_type: hit['_type'], _id: hit['_id']}}
      end

      client.bulk index: index, body: bulk_data

      r = client.scroll scroll_id: r['_scroll_id'], scroll: '1m'
    end
  end
end
