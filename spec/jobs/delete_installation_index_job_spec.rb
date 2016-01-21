require 'rails_helper'

RSpec.describe DeleteInstallationIndexJob, type: :job, elasticseach: true do
  let(:installation) { create(:installation) }
  let(:events_size) { 5 }
  let(:now) { Time.now }
  let(:data) do
    {
      counters: [
        {metric: 'users', key: {}, value: 13}
      ],
      application: 'verboice'
    }
  end

  before :each do
    InstallationIndexer.new.index(installation)
    event_indexer = EventIndexer.new
    events_size.times do |i|
      period = events_size - i
      data[:period] = {beginning: now - (period + 1).weeks, end: now - period.week}
      event = create(:event, installation: installation, data: data.to_json)
      event_indexer.index(event)
    end
    refresh_index
  end

  it 'deletes installation and events from index' do
    installations_result = search_installations
    expect(installations_result.total).to eq(1)

    events_result = search_events(installation.uuid)
    expect(events_result.total).to eq(events_size)

    DeleteInstallationIndexJob.perform_now(installation.id, installation.uuid)

    refresh_index

    installations_result = search_installations
    expect(installations_result.total).to eq(0)

    events_result = search_events(installation.uuid)
    expect(events_result.total).to eq(0)
  end
end
