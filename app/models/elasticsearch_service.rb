class ElasticsearchService
  class << self
    def client
      @client ||= Elasticsearch::Client.new url: url, log: should_log
    end

    def should_log
      Rails.env.development?
    end

    def index_name
      Rails.env.production? ? 'telemetry' : "telemetry-#{Rails.env}"
    end

    def url
      ENV['ELASTICSEARCH_URL'] || 'localhost'
    end

    def init_mappings
      client.indices.put_mapping index: index_name, type: 'installation', body: {
        installation: {
          properties: {
            location: {type: 'geo_point'},
            uuid: {type: 'string', index: 'not_analyzed'}
          }
        }
      }

      [:counter, :timespan, :set].each do |t|
        client.indices.put_mapping index: "*", type: t, body: {
          t => {
            properties: {
              installation_uuid: { type: 'string', index: 'not_analyzed' }
            }
          }
        }
      end
    end

    def create_index
      client.indices.create index: index_name rescue nil
    end
  end
end
