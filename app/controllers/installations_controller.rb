class InstallationsController < AuthenticatedController

  def index
  end

  def destroy
    @installation = Installation.find(params[:id])
    @installation.destroy

    redirect_to installations_path
  end

end
