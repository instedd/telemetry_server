class GeocodeService
  GEOLITE_DB_PATH = "#{Rails.root}/etc/geoip/GeoLiteCity.dat"

  def self.get
    @service ||= self.new
  end

  def initialize
    @geoip = GeoIP.new(GEOLITE_DB_PATH)
  end

  def geocode_ip(ip)
    @geoip.country(ip)
  end
end
