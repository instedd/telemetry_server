require 'rails_helper'

RSpec.describe InstallationIndexer, type: :model, elasticseach: true do

  let(:installation) { Installation.create(uuid: SecureRandom.uuid) }
  let(:indexer) { InstallationIndexer.new }

  it 'indexes installation' do
    indexer.index(installation)

    refresh_index

    response = search_installations
    results = response.results

    expect(response.total).to eq(1)
    expect(results.first['_id']). to eq(installation.id.to_s)
    expect(results.first['uuid']). to eq(installation.uuid)
    expect(results.first['created_at']). to eq(installation.created_at.iso8601)
  end

  it "indexes installation's last reported at" do
    installation.last_reported_at = Time.now.utc

    indexer.index(installation)

    refresh_index

    response = search_installations

    expect(response.results.first['last_reported_at']). to eq(installation.last_reported_at.iso8601)
  end

  it "indexes installation's location" do
    installation.latitude = -54.123
    installation.longitude = -38.456

    indexer.index(installation)

    refresh_index

    response = search_installations

    expect(response.results.first['location']['lat']). to eq(installation.latitude.to_s)
    expect(response.results.first['location']['lon']). to eq(installation.longitude.to_s)
  end

  it "indexes installation's application" do
    installation.application = 'verboice'

    indexer.index(installation)

    refresh_index

    response = search_installations

    expect(response.results.first['application']). to eq(installation.application)
  end

end
