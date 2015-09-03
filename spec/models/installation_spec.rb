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
end
