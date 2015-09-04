namespace :elasticsearch do
  desc 'Creates the index and initializes the mappings'
  task init: :environment do
    ElasticsearchService.create_index
    ElasticsearchService.init_mappings
  end
end
