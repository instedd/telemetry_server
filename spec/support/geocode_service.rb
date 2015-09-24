class FakeGeocodeService
  Result = Struct.new(:latitude, :longitude)

  def geocode_ip(ip)
    Result.new(Faker::Address.latitude, Faker::Address.longitude)
  end
end

RSpec.configure do |config|
  config.before(:each) do
    allow(GeocodeService).to receive(:get).and_return(FakeGeocodeService.new)
  end
end
