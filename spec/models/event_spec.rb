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

  describe 'period' do
    let(:from) { DateTime.new(2015,12,4,7,0,0) }
    let(:to) { from + 1.hour }

    it 'sets period span' do
      event = build(:event, data: {period: {beginning: from, end: to}}.to_json)

      event.save!

      expect(event.reload.period_beginning).to eq(from)
      expect(event.reload.period_end).to eq(to)
    end

    it 'validates presence of end if beggining is present' do
      event = build(:event, data: {period: {beginning: from}}.to_json)

      expect(event.valid?).to be_falsy
      expect(event.errors[:period_end].size).to eq(1)
    end

    it 'validates presence of beggining if beggining is end' do
      event = build(:event, data: {period: {end: to}}.to_json)

      expect(event.valid?).to be_falsy
      expect(event.errors[:period_beginning].size).to eq(1)
    end

    it 'allows to be nil both beginning and end' do
      event = build(:event, data: {period: {}}.to_json)

      expect(event.valid?).to be_truthy
      expect(event.save).to be_truthy
    end

    describe 'already reported?' do
      let(:installation) { create(:installation) }
      let!(:reported_event) { create(:event, installation: installation, data: {period: {beginning: from, end: to}}.to_json) }

      it 'tells if event was already reported' do
        event = build(:event, installation: installation, data: {period: {beginning: from, end: to}}.to_json)

        expect(event.already_reported?).to be_truthy
      end

      it 'should not report true if it is from another installation' do
        event = build(:event, installation: create(:installation), data: {period: {beginning: from, end: to}}.to_json)

        expect(event.already_reported?).to be_falsy
      end

      it 'should not report true if period is not the same' do
        event = build(:event, installation: installation, data: {period: {beginning: from + 1.hour, end: to + 1.hour}}.to_json)

        expect(event.already_reported?).to be_falsy
      end
    end

    describe 'overlapping' do
      let(:installation) { create(:installation) }
      let(:data) { {period: {beginning: from, end: to}} }
      let!(:event) { create(:event, installation: installation, data: data.to_json) }

      it 'should validate overlapping with other event' do
        other_from = from - 1.hour
        other_to = from + 30.minutes
        other_event = build(:event, installation: installation, data: {period: {beginning: other_from, end: other_to}}.to_json)

        expect(other_event.valid?).to be_falsy

        other_from = from - 1.hour
        other_to = to + 30.minutes
        other_event = build(:event, installation: installation, data: {period: {beginning: other_from, end: other_to}}.to_json)

        expect(other_event.valid?).to be_falsy

        other_from = from
        other_to = to - 30.minutes
        other_event = build(:event, installation: installation, data: {period: {beginning: other_from, end: other_to}}.to_json)

        expect(other_event.valid?).to be_falsy

        other_from = from
        other_to = to + 30.minutes
        other_event = build(:event, installation: installation, data: {period: {beginning: other_from, end: other_to}}.to_json)

        other_from = from
        other_to = to
        other_event = build(:event, installation: installation, data: {period: {beginning: other_from, end: other_to}}.to_json)

        expect(other_event.valid?).to be_falsy

        other_from = from + 30.minutes
        other_to = to - 15.minutes
        other_event = build(:event, installation: installation, data: {period: {beginning: other_from, end: other_to}}.to_json)

        expect(other_event.valid?).to be_falsy

        other_from = from + 30.minutes
        other_to = to + 30.minutes
        other_event = build(:event, installation: installation, data: {period: {beginning: other_from, end: other_to}}.to_json)

        expect(other_event.valid?).to be_falsy

        other_from = from + 30.minutes
        other_to = to
        other_event = build(:event, installation: installation, data: {period: {beginning: other_from, end: other_to}}.to_json)

        expect(other_event.valid?).to be_falsy
      end

      it 'allows no overlapping spans' do
        other_from = from - 2.hours
        other_to = to - 2.hours
        other_event = build(:event, installation: installation, data: {period: {beginning: other_from, end: other_to}}.to_json)

        expect(other_event.valid?).to be_truthy

        other_from = from + 2.hours
        other_to = to + 2.hours
        other_event = build(:event, installation: installation, data: {period: {beginning: other_from, end: other_to}}.to_json)

        expect(other_event.valid?).to be_truthy
      end

      it 'allows contiguous spans' do
        other_from = from - 1.hour
        other_to = from
        other_event = build(:event, installation: installation, data: {period: {beginning: other_from, end: other_to}}.to_json)

        expect(other_event.valid?).to be_truthy

        other_from = to
        other_to = to + 1.hour
        other_event = build(:event, installation: installation, data: {period: {beginning: other_from, end: other_to}}.to_json)

        expect(other_event.valid?).to be_truthy
      end

      it 'should allow overlapping between different installations' do
        other_installation = create(:installation)

        other_from = from - 1.hour
        other_to = from + 30.minutes
        other_event = build(:event, installation: other_installation, data: {period: {beginning: other_from, end: other_to}}.to_json)

        expect(other_event.valid?).to be_truthy

        other_from = from - 1.hour
        other_to = to + 30.minutes
        other_event = build(:event, installation: other_installation, data: {period: {beginning: other_from, end: other_to}}.to_json)

        expect(other_event.valid?).to be_truthy

        other_from = from
        other_to = to - 30.minutes
        other_event = build(:event, installation: other_installation, data: {period: {beginning: other_from, end: other_to}}.to_json)

        expect(other_event.valid?).to be_truthy

        other_from = from
        other_to = to + 30.minutes
        other_event = build(:event, installation: other_installation, data: {period: {beginning: other_from, end: other_to}}.to_json)

        other_from = from
        other_to = to
        other_event = build(:event, installation: other_installation, data: {period: {beginning: other_from, end: other_to}}.to_json)

        expect(other_event.valid?).to be_truthy

        other_from = from + 30.minutes
        other_to = to - 15.minutes
        other_event = build(:event, installation: other_installation, data: {period: {beginning: other_from, end: other_to}}.to_json)

        expect(other_event.valid?).to be_truthy

        other_from = from + 30.minutes
        other_to = to + 30.minutes
        other_event = build(:event, installation: other_installation, data: {period: {beginning: other_from, end: other_to}}.to_json)

        expect(other_event.valid?).to be_truthy

        other_from = from + 30.minutes
        other_to = to
        other_event = build(:event, installation: other_installation, data: {period: {beginning: other_from, end: other_to}}.to_json)

        expect(other_event.valid?).to be_truthy
      end
    end
  end

end
