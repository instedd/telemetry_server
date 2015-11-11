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
    event = build(:event, installation: installation)

    expect(installation).to receive(:update_timestamps_from).with(event)

    event.save
  end

  describe 'parse data' do
    let(:data) { {'foo' => 'some data', 'bar' => 2} }
    let(:data_json) { data.to_json }

    it 'parses data' do
      event = build(:event, data: data_json)

      expect(event.parsed_data).to eq(data)
    end

    it 'parses data with indifferent access' do
      event = build(:event, data: data_json)

      expect(event.parsed_data[:foo]).to eq('some data')
      expect(event.parsed_data[:bar]).to eq(2)
    end

    it 'returns empty if data is malformed' do
      event = build(:event, data: 'foobarbaz')

      expect(event.parsed_data).to eq({})
    end
  end

  describe 'errors' do
    it 'should tell if it has errors' do
      event = build(:event, data: {'errors' => ['error 1', 'error 2', 'error 3']}.to_json)
      expect(event.has_reported_errors?).to be_truthy

      event = build(:event, data: {'errors' => []}.to_json)
      expect(event.has_reported_errors?).to be_falsy

      event = build(:event, data: {}.to_json)
      expect(event.has_reported_errors?).to be_falsy

      event = build(:event, data: nil)
      expect(event.has_reported_errors?).to be_falsy
    end

    it 'returns errors' do
      event = build(:event, data: {'errors' => ['error 1', 'error 2', 'error 3']}.to_json)

      expect(event.reported_errors).to eq(['error 1', 'error 2', 'error 3'])
    end
  end
end
