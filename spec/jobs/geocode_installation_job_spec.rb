require 'rails_helper'

RSpec.describe GeocodeInstallationJob, type: :job do
  let(:ip) { '23.17.11.7'}
  let!(:installation) { create(:installation, ip: ip, latitude: nil, longitude: nil) }
  let(:geocode_service) { double('geocode_service') }

  before :each do
    allow(GeocodeService).to receive(:get).and_return(geocode_service)
  end

  it 'geocodes the installation' do
    geocode_result = double(:geocode_result, latitude: -34.123, longitude: -58.456)
    expect(geocode_service).to receive(:geocode_ip).with(ip).and_return(geocode_result)

    GeocodeInstallationJob.perform_now(installation.id)

    expect(installation.reload.latitude).to eq(-34.123)
    expect(installation.reload.longitude).to eq(-58.456)
  end

  it 'should not fail if installation is missing' do
    expect {
      GeocodeInstallationJob.perform_now('asdf')
    }.to_not raise_error(Exception)
  end

  it 'should not fail if result is not found' do
    expect(geocode_service).to receive(:geocode_ip).with(ip).and_return(nil)

    GeocodeInstallationJob.perform_now(installation.id)
  end

  it 'should not fail if ip is missing' do
    installation = create(:installation, ip: nil, latitude: nil, longitude: nil)

    expect(geocode_service).to_not receive(:geocode_ip)

    GeocodeInstallationJob.perform_now(installation.id)

    expect(installation.reload.latitude).to eq(nil)
    expect(installation.reload.longitude).to eq(nil)
  end
end
