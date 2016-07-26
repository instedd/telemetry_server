if Rails.env.test?
  require "./spec/support/webmock"
end

namespace :elasticsearch do
  desc 'Creates the index and initializes the mappings'
  task init: :environment do
    ElasticsearchService.create_index
    ElasticsearchService.init_mappings
  end

  desc 'Reindex installations and events'
  task reindex: :init do
    installation_indexer = InstallationIndexer.new
    event_indexer = EventIndexer.new

    Installation.find_each batch_size: 100 do |installation|
      installation_indexer.index(installation)
    end

    Event.find_each batch_size: 100 do |event|
      event_indexer.index(event)
    end
  end

  desc 'Drop the index'
  task drop: :environment do
    ElasticsearchService.client.indices.delete index: ElasticsearchService.index_name
  end
end
