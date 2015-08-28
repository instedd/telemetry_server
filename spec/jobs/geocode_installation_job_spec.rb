require 'rails_helper'

RSpec.describe GeocodeInstallationJob, type: :job do
  let(:ip) { '23.17.11.7'}
  let!(:installation) { create(:installation, ip: ip, latitude: nil, longitude: nil) }
  let(:job) { GeocodeInstallationJob}

  before :each do
    WebMock.reset!
  end

  it 'geocodes the installation' do
    request = stub_request(:get, "http://freegeoip.net/json/#{installation.ip}").to_return(body: {
      latitude: -34.123,
      longitude: -58.456
    }.to_json)

    GeocodeInstallationJob.perform_now(installation.id)

    expect(installation.reload.latitude).to eq(-34.123)
    expect(installation.reload.longitude).to eq(-58.456)
    expect(request).to have_been_requested
  end

  it 'should not fail if installation is missing' do
    expect {
      GeocodeInstallationJob.perform_now('asdf')
    }.to_not raise_error(Exception)
  end

  it 'should not fail if ip is missing' do
    installation = create(:installation, ip: nil, latitude: nil, longitude: nil)

    expect(RestClient).to_not receive(:get)

    GeocodeInstallationJob.perform_now(installation.id)

    expect(installation.reload.latitude).to eq(nil)
    expect(installation.reload.longitude).to eq(nil)
  end
end
