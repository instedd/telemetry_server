require 'rails_helper'

RSpec.describe Installation, type: :model do
  it { is_expected.to have_many(:events) }
  it { is_expected.to validate_presence_of(:uuid) }
  it { is_expected.to validate_uniqueness_of(:uuid) }

  describe 'geocode' do
    it 'geocodes using job when creating' do
      expect(GeocodeInstallationJob).to receive(:perform_later)

      installation = create(:installation, ip: '23.17.11.7')
    end

    it 'geocodes using job when updating' do
      installation = create(:installation, ip: nil)

      expect(GeocodeInstallationJob).to receive(:perform_later).with(installation.id)

      installation.ip = '23.17.11.7'

      installation.save!
    end

    it 'should not geocode if ip is not present' do
      expect(GeocodeInstallationJob).not_to receive(:perform_later)
      installation = create(:installation, ip: nil)
    end

    it 'should not geocode if ip has not changed' do
      installation = create(:installation)

      expect(GeocodeInstallationJob).not_to receive(:perform_later)

      installation.uuid = "#{installation.uuid}-updated"

      installation.save!
    end
  end

  describe 'index' do
    it 'indexes using job when creating' do
      expect(IndexInstallationJob).to receive(:perform_later)

      create(:installation, ip: nil)
    end

    it 'indexes using job when updating' do
      installation = create(:installation)

      installation.last_reported_at = Time.now.utc
      expect(IndexInstallationJob).to receive(:perform_later)

      installation.save
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
