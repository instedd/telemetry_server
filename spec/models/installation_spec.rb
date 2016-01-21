require 'rails_helper'

RSpec.describe Installation, type: :model do
  it { is_expected.to have_many(:events).dependent(:delete_all) }
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

    it 'deletes from index when destroyed' do
      installation = create(:installation)

      expect(DeleteInstallationIndexJob).to receive(:perform_later).with(installation.uuid)

      installation.destroy
    end

  end

  describe 'update timestamps from event' do
    let(:installation) { create(:installation) }

    describe 'last reported at' do
      let(:created_at) { 1.hour.ago.change(nsec: 0) }
      let(:event) { build(:event, created_at: created_at) }

      it 'updates last reported at' do
        installation.update_timestamps_from event

        expect(installation.reload.last_reported_at).to eq(created_at)
      end

      it 'keeps max last reported at' do
        last_reported_at = created_at + 30.minutes
        installation = create(:installation, last_reported_at: last_reported_at)

        installation.update_timestamps_from event

        expect(installation.reload.last_reported_at).to eq(last_reported_at)
      end
    end

    describe 'last errored at' do
      let(:created_at) { 1.hour.ago.change(nsec: 0) }
      let(:event) { build(:event_with_errors, created_at: created_at) }

      it 'updates last reported at' do
        installation.update_timestamps_from event

        expect(installation.reload.last_errored_at).to eq(created_at)
      end

      it 'keeps max last reported at' do
        last_errored_at = created_at + 30.minutes
        installation = create(:installation, last_errored_at: last_errored_at)

        installation.update_timestamps_from event

        expect(installation.reload.last_errored_at).to eq(last_errored_at)
      end
    end
  end
end
