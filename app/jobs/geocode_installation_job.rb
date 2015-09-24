class GeocodeInstallationJob < ActiveJob::Base
  queue_as :default

  def perform(installation_id)
    installation = Installation.find_by(id: installation_id)
    return if installation.nil? || installation.ip.blank?

    result = GeocodeService.get.geocode_ip installation.ip

    return unless result.present?

    installation.latitude  = result.latitude
    installation.longitude = result.longitude

    installation.save!
  end
end
