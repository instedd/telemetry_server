require 'rails_helper'

RSpec.describe Installation, type: :model do
  it { is_expected.to have_many(:events) }
  it { is_expected.to validate_presence_of(:uuid) }
  it { is_expected.to validate_uniqueness_of(:uuid) }

  describe 'geocode' do
    
    it 'hooks geocoding to transaction commit' do
      installation = create(:installation)
      expect(installation).to receive(:geocode)
      installation.run_callbacks(:commit)
    end

    it "geocodes using job if ip is present but no lat/lng" do
      installation = create(:installation, ip: '23.17.11.7', latitude: nil, longitude: nil)

      expect(GeocodeInstallationJob).to receive(:perform_later).with(installation.id)
      installation.send :geocode
    end

    it 'should not geocode if ip is not present' do
      installation = create(:installation, ip: nil, latitude: nil, longitude: nil)
      
      expect(GeocodeInstallationJob).not_to receive(:perform_later)
      installation.send :geocode
    end

    it 'should not geocode if latitude or longitude are present' do
      installation = create(:installation, ip: '23.17.11.7', latitude: -34.517491, longitude: -58.483444)
      
      expect(GeocodeInstallationJob).not_to receive(:perform_later)
      installation.send :geocode
    end
  end

  describe 'index' do

    it 'hooks indexing to transaction commit' do
      installation = create(:installation, ip: nil)
      expect(installation).to receive(:index_installation)
      installation.run_callbacks(:commit)
    end

    it 'indexes using job' do
      expect(IndexInstallationJob).to receive(:perform_later)
      installation = create(:installation)
      installation.send :index_installation
    end

  end

  describe 'last reported at' do
    let(:now) { Time.now.utc.change(nsec: 0) }
    let(:installation) { create(:installation) }

    before :each do
      Timecop.freeze(now)
    end

    it 'updates last reported at' do
      installation.touch_last_reported_at!

      expect(installation.reload.last_reported_at).to eq(now)
    end
  end
end
