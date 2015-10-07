class Api::InstallationsController < Api::BaseController
  before_action :fetch_installation

  def update
    if @installation.update(installation_params)
      render nothing: true, status: :ok
    else
      render nothing: true, status: :unprocessable_entity
    end
  end

  private

  def fetch_installation
    @installation = Installation.find_or_initialize_by(uuid: params[:id]) do |i|
      i.ip = request.remote_ip
    end
  end

  def installation_params
    params.require(:installation).permit(:admin_email, :application, :opt_out)
  end

end
