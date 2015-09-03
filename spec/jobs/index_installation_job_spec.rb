require 'rails_helper'

RSpec.describe IndexInstallationJob, type: :job do

  let(:indexer) { double('indexer') }

  before :each do
    allow(InstallationIndexer).to receive(:new).and_return(indexer)
  end

  context 'with installation' do
    let(:installation_id) { 17 }
    let(:installation) { double('installation') }

    before :each do
      allow(Installation).to receive(:find_by).with(id: installation_id).and_return(installation)
    end

    it 'indexes installation' do
      expect(indexer).to receive(:index).with(installation)

      IndexInstallationJob.perform_now(installation_id)
    end
  end

  it 'should not fail if installation is missing' do
    expect(indexer).not_to receive(:index)

    IndexInstallationJob.perform_now('asdf')
  end

end
