require 'rails_helper'

RSpec.describe EventIndexer, type: :model, elasticseach: true do

  let(:from) { 10.days.ago }
  let(:to) { from + 7.days }
  let(:installation) { create(:installation) }
  let(:data) do
    {
      counters: [
        {type: 'users', key: {project_id: 5}, value: 11},
        {type: 'calls', key: {project_id: 3}, value: 17}
      ],
      sets: [
        {type: 'languages', key: {project_id: 7}, elements: ['en', 'es', 'jp']},
        {type: 'channels', key: {project_id: 23}, elements: ['twilio', 'sip', 'callcentric']}
      ],
      period: {beggining: from.iso8601, end: to.iso8601}
    }.to_json
  end
  let(:event) { build(:event, installation: installation, data: data)}
  let(:indexer) { EventIndexer.new }

  it 'should index counters' do
    indexer.index(event)

    refresh_index

    response = search_counters

    expect(response.total).to eq(2)

    results = response.results
    users_result = results.find{|x| x['kind'] == 'users'}
    calls_result = results.find{|x| x['kind'] == 'calls'}

    expect(users_result['key']['project_id']).to eq(5)
    expect(users_result['value']).to eq(11)
    expect(users_result['beggining']).to eq(from.iso8601)
    expect(users_result['end']).to eq(to.iso8601)

    expect(calls_result['key']['project_id']).to eq(3)
    expect(calls_result['value']).to eq(17)
    expect(calls_result['beggining']).to eq(from.iso8601)
    expect(calls_result['end']).to eq(to.iso8601)
  end

  it 'should index sets' do
    indexer.index(event)

    refresh_index

    response = search_sets

    expect(response.total).to eq(2)

    results = response.results
    languages_result = results.find{|x| x['kind'] == 'languages'}
    channels_result = results.find{|x| x['kind'] == 'channels'}

    expect(languages_result['key']['project_id']).to eq(7)
    expect(languages_result['elements']).to eq(['en', 'es', 'jp'])
    expect(languages_result['beggining']).to eq(from.iso8601)
    expect(languages_result['end']).to eq(to.iso8601)

    expect(channels_result['key']['project_id']).to eq(23)
    expect(channels_result['elements']).to eq(['twilio', 'sip', 'callcentric'])
    expect(channels_result['beggining']).to eq(from.iso8601)
    expect(channels_result['end']).to eq(to.iso8601)
  end

end
