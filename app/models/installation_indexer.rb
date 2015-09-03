class InstallationIndexer
  def initialize
    @client = ElasticsearchService.client
  end

  def index(installation)
    @client.index index: ElasticsearchService.index_name, type: 'installation', id: installation.id, body: as_indexed(installation)
  end

  private

  def as_indexed(installation)
    body = {uuid: installation.uuid, created_at: installation.created_at.iso8601}
    body[:last_reported_at] = installation.last_reported_at.iso8601 if installation.last_reported_at.present?
    body[:application] = installation.application if installation.application.present?

    if installation.latitude.present? && installation.longitude.present?
      body[:location] = {lat: installation.latitude, lon: installation.longitude}
    end

    body
  end
end
