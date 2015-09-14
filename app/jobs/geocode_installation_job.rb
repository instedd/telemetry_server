class GeocodeInstallationJob < ActiveJob::Base
  queue_as :default

  GEOLITE_DB_PATH = 'etc/geoip/GeoLiteCity.dat'

  def perform(installation_id)
    installation = Installation.find_by(id: installation_id)
    return if installation.nil? || installation.ip.blank?

    lat, lng = geocode(installation.ip)

    installation.latitude  = lat
    installation.longitude = lng

    installation.save!
  end

  def geocode(ip)
    @@geoip ||= GeoIP.new('etc/geoip/GeoLiteCity.dat')
    country = @@geoip.country(ip)
    [country["latitude"], country["longitude"]]
  end
end
