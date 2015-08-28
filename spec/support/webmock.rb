WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.before(:each) do
    # Stub all requests to freegeoip
    stub_request(:any, /freegeoip/).to_return(body: {
      latitude: Faker::Address.latitude,
      longitude: Faker::Address.longitude,
    }.to_json)
  end
end
