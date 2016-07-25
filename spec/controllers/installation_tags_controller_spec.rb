require "rails_helper"

RSpec.describe InstallationTagsController, :type => :controller do

  before(:each) { sign_in create(:user) }

  let(:installation) { create(:installation) }

  it "can add tag" do
    xhr :post, :create, installation_id: installation, name: "lorem"
    installation.reload
    expect(installation.tag_list).to eq(["lorem"])
  end

  it "can remove tag" do
    installation.tag_list = "lorem"
    installation.save!

    xhr :post, :destroy, installation_id: installation, id: "lorem"

    installation.reload
    expect(installation.tag_list).to eq([])
  end
end
