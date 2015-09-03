require 'rails_helper'

RSpec.describe Event, type: :model do
  it { is_expected.to belong_to(:installation) }
  it { is_expected.to validate_presence_of(:installation) }

  describe 'index' do
    it 'indexes using job when creating' do
      expect(IndexEventJob).to receive(:perform_later)

      create(:event, data: 'some data')
    end

    it 'doesnt index if data is not present' do
      expect(IndexEventJob).not_to receive(:perform_later)

      create(:event, data: nil)
    end
  end
end
