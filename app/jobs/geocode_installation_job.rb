class GeocodeInstallationJob < ActiveJob::Base
  queue_as :default

  def perform(installation_id)
    installation = Installation.find_by(id: installation_id)
    return if installation.nil? || installation.ip.blank?

    response = RestClient.get "http://freegeoip.net/json/#{installation.ip}"
    json = JSON.parse(response)

    installation.latitude = json['latitude']
    installation.longitude = json['longitude']

    installation.save!
  end
end
