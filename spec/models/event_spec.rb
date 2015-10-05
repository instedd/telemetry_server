require 'rails_helper'

RSpec.describe Event, type: :model do
  it { is_expected.to belong_to(:installation) }
  it { is_expected.to validate_presence_of(:installation) }

  describe 'index' do

    it 'hooks indexint to transaction commit' do
      event = create(:event, data: 'some data')
      expect(event).to receive(:index_event)
      event.run_callbacks(:commit)
    end

    it "indexes using job" do
      expect(IndexEventJob).to receive(:perform_later)

      event = create(:event, data: 'some data')
      event.send :index_event
    end

    it 'doesnt index if data is not present' do
      expect(IndexEventJob).not_to receive(:perform_later)

      event = create(:event, data: nil)
      event.send :index_event
    end
  end

  it 'updates installation last reported at' do
    installation = create(:installation)
    expect(installation).to receive(:touch_last_reported_at!)

    create(:event, installation: installation)
  end
end
