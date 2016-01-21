class DeleteInstallationIndexJob < ActiveJob::Base
  queue_as :default

  def perform(installation_uuid)
    client = ElasticsearchService.client
    index = ElasticsearchService.index_name

    # Delete installation
    client.delete_by_query index: index, type: 'installation', body: {
      query: { match: { uuid: installation_uuid } }
    }

    # Delete associated events
    client.delete_by_query index: index, body: {
      query: { match: { installation_uuid: installation_uuid } }
    }
  end
end
