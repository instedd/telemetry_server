require 'rails_helper'

RSpec.describe DeleteInstallationIndexJob, type: :job do
  let(:elasticseach) { double('elasticseach') }
  let(:uuid) { '1234-5678' }

  before :each do
    allow(ElasticsearchService).to receive(:client).and_return(elasticseach)
  end

  it 'deletes installation and events from index' do
    expect(elasticseach).to receive(:delete_by_query).with({
      index: ElasticsearchService.index_name,
      type: 'installation',
      body: {
        query: { match: { uuid: uuid } }
      }
    })

    expect(elasticseach).to receive(:delete_by_query).with({
      index: ElasticsearchService.index_name,
      body: {
        query: { match: { installation_uuid: uuid } }
      }
    })

    DeleteInstallationIndexJob.perform_now(uuid)
  end
end
