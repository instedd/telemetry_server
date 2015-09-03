class ElasticsearchService
  class << self
    def client
      @client ||= Elasticsearch::Client.new log: should_log
    end

    def should_log
      Rails.env.development?
    end

    def index_name
      Rails.env.production? ? 'telemetry' : "telemetry-#{Rails.env}"
    end
  end
end
