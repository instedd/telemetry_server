require 'rails_helper'

RSpec.describe EventIndexer, type: :model, elasticseach: true do

  let(:from) { 10.days.ago }
  let(:to) { from + 7.days }
  let(:installation) { create(:installation) }
  let(:data) do
    {
      counters: [
        {metric: 'users', key: {project_id: 5}, value: 11},
        {metric: 'calls', key: {project_id: 3}, value: 17}
      ],
      sets: [
        {metric: 'languages', key: {project_id: 7}, elements: ['en', 'es', 'jp']},
        {metric: 'channels', key: {project_id: 23}, elements: ['twilio', 'sip', 'callcentric']}
      ],
      timespans: [
        {metric: 'user_lifespan', key: {user_id: 46}, days: 14},
        {metric: 'project_lifespan', key: {project_id: 34}, days: 30}
      ],
      period: {beginning: from.iso8601, end: to.iso8601},
      application: 'verboice'
    }.to_json
  end
  let(:event) { create(:event, installation: installation, data: data)}
  let(:indexer) { EventIndexer.new }

  it 'should index counters' do
    indexer.index(event)

    refresh_index

    response = search_counters

    expect(response.total).to eq(2)

    results = response.results
    users_result = results.find{|x| x['metric'] == 'users'}
    calls_result = results.find{|x| x['metric'] == 'calls'}

    expect(users_result['_id']).to eq("#{event.id}-0")
    expect(users_result['key']['project_id']).to eq(5)
    expect(users_result['value']).to eq(11)
    expect(users_result['beginning']).to eq(from.iso8601)
    expect(users_result['end']).to eq(to.iso8601)
    expect(users_result['application']).to eq('verboice')

    expect(calls_result['_id']).to eq("#{event.id}-1")
    expect(calls_result['key']['project_id']).to eq(3)
    expect(calls_result['value']).to eq(17)
    expect(calls_result['beginning']).to eq(from.iso8601)
    expect(calls_result['end']).to eq(to.iso8601)
    expect(calls_result['application']).to eq('verboice')
  end

  it 'should index sets' do
    indexer.index(event)

    refresh_index

    response = search_sets

    expect(response.total).to eq(2)

    results = response.results
    languages_result = results.find{|x| x['metric'] == 'languages'}
    channels_result = results.find{|x| x['metric'] == 'channels'}

    expect(languages_result['_id']).to eq("#{event.id}-0")
    expect(languages_result['key']['project_id']).to eq(7)
    expect(languages_result['elements']).to eq(['en', 'es', 'jp'])
    expect(languages_result['beginning']).to eq(from.iso8601)
    expect(languages_result['end']).to eq(to.iso8601)
    expect(languages_result['application']).to eq('verboice')

    expect(channels_result['_id']).to eq("#{event.id}-1")
    expect(channels_result['key']['project_id']).to eq(23)
    expect(channels_result['elements']).to eq(['twilio', 'sip', 'callcentric'])
    expect(channels_result['beginning']).to eq(from.iso8601)
    expect(channels_result['end']).to eq(to.iso8601)
    expect(channels_result['application']).to eq('verboice')
  end

  it "should index timespans" do
    indexer.index(event)

    refresh_index

    response = search_timespans

    expect(response.total).to eq(2)

    results = response.results
    user_lifespan_result = results.find{|x| x['metric'] == 'user_lifespan'}
    project_lifespan_result = results.find{|x| x['metric'] == 'project_lifespan'}

    expect(user_lifespan_result['_id']).to eq("#{event.id}-0")
    expect(user_lifespan_result['key']['user_id']).to eq(46)
    expect(user_lifespan_result['days']).to eq(14)
    expect(user_lifespan_result['beginning']).to eq(from.iso8601)
    expect(user_lifespan_result['end']).to eq(to.iso8601)
    expect(user_lifespan_result['application']).to eq('verboice')

    expect(project_lifespan_result['_id']).to eq("#{event.id}-1")
    expect(project_lifespan_result['key']['project_id']).to eq(34)
    expect(project_lifespan_result['days']).to eq(30)
    expect(project_lifespan_result['beginning']).to eq(from.iso8601)
    expect(project_lifespan_result['end']).to eq(to.iso8601)
    expect(project_lifespan_result['application']).to eq('verboice')
  end

  it 'should index application from installation if not present in event data' do
    data = {
      counters: [
        {metric: 'active_channels', key: {}, value: 37}
      ],
      period: {beginning: from.iso8601, end: to.iso8601}
    }.to_json

    installation = build(:installation, application: 'nuntium')
    event = build(:event, installation: installation, data: data)

    indexer.index(event)

    refresh_index

    response = search_counters

    expect(response.total).to eq(1)
    expect(response.results.first['application']).to eq('nuntium')
  end

  it "does not fail on events without data" do
    data = { period: {beginning: from.iso8601, end: to.iso8601}, counters: [], sets: [], timespans: [] }.to_json
    event = build(:event, installation: installation, data: data)
    expect { indexer.index(event) }.not_to raise_error
  end

end
