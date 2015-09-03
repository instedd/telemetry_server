require 'rails_helper'

RSpec.describe IndexEventJob, type: :job do

  let(:indexer) { double('indexer') }

  before :each do
    allow(EventIndexer).to receive(:new).and_return(indexer)
  end

  context 'with event' do
    let(:event_id) { 17 }
    let(:event) { double('event') }

    before :each do
      allow(Event).to receive(:find_by).with(id: event_id).and_return(event)
    end

    it 'indexes event' do
      expect(indexer).to receive(:index).with(event)

      IndexEventJob.perform_now(event_id)
    end
  end

  it 'should not fail if event is missing' do
    expect(indexer).not_to receive(:index)

    IndexEventJob.perform_now('asdf')
  end

end
