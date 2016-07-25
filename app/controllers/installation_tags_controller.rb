class InstallationTagsController < AuthenticatedController

  def create
    @installation = Installation.find(params[:installation_id])
    @installation.tag_list.add(params[:name])
    @installation.save!
    render 'reload_installations_listing'
  end

  def destroy
    @installation = Installation.find(params[:installation_id])
    @installation.tag_list.remove(params[:id])
    @installation.save!
    render 'reload_installations_listing'
  end

end
