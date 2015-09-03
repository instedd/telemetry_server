require "rails_helper"

RSpec.describe Api::EventsController, :type => :controller do

  let(:event_data) { 'the event data' }

  before :each do
    @request.env['RAW_POST_DATA'] = event_data
    allow(IndexEventJob).to receive(:perform_later)
  end

  context 'new installation' do

    describe 'POST #create' do
      let(:uuid) { SecureRandom.uuid }

      it 'responds successfully' do
        post :create, installation_id: uuid

        expect(response).to be_success
      end

      it 'creates a new installation' do
        allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return('201.123.57.7')

        expect {
          post :create, installation_id: uuid
        }.to change(Installation, :count).by(1)

        installation = Installation.last

        expect(installation.uuid).to eq(uuid)
        expect(installation.ip).to eq('201.123.57.7')
      end

      it 'creates an event' do
        expect {
          post :create, installation_id: uuid
        }.to change(Event, :count).by(1)

        event = Event.last

        expect(event.installation.uuid).to eq(uuid)
        expect(event.data).to eq(event_data)
      end
    end

  end

  context 'existing installation' do

    let!(:installation) { create(:installation) }

    describe 'POST #create' do
      it 'responds successfully' do
        post :create, installation_id: installation.uuid

        expect(response).to be_success
      end

      it 'uses the existing installation' do
        expect {
          post :create, installation_id: installation.uuid
        }.not_to change(Installation, :count)
      end

      it 'creates an event' do
        expect {
          post :create, installation_id: installation.uuid
        }.to change(Event, :count).by(1)

        event = Event.last

        expect(event.installation).to eq(installation)
        expect(event.data).to eq(event_data)
      end
    end

  end

end
