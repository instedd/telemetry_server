require "rails_helper"

RSpec.describe Api::InstallationsController, :type => :controller do

  let(:params) { {admin_email: 'foo@bar.com'} }

  context 'new installation' do

    describe 'PUT #update' do
      let(:uuid) { SecureRandom.uuid }

      it 'responds successfully' do
        put :update, id: uuid, installation: params

        expect(response).to be_success
      end

      it 'creates a new installation' do
        allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return('201.123.57.7')

        expect {
          put :update, id: uuid, installation: params
        }.to change(Installation, :count).by(1)

        installation = Installation.last

        expect(installation.uuid).to eq(uuid)
        expect(installation.ip).to eq('201.123.57.7')
        expect(installation.admin_email).to eq(params[:admin_email])
      end
    end

  end

  context 'existing installation' do

    let!(:installation) { create(:installation) }

    describe 'PUT #update' do
      it 'responds successfully' do
        put :update, id: installation.uuid, installation: params

        expect(response).to be_success
      end

      it 'uses the existing installation' do
        expect {
          put :update, id: installation.uuid, installation: params
        }.not_to change(Installation, :count)
      end

      it 'update the installation' do
        put :update, id: installation.uuid, installation: params

        expect(installation.reload.admin_email).to eq(params[:admin_email])
      end
    end

  end

end
