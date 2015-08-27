class Api::EventsController < Api::BaseController
  before_action :fetch_installation, only: [:create]

  def create
    event = @installation.events.build(data: event_data)
    if event.save
      render nothing: true, status: :ok
    else
      render nothing: true, status: :unprocessable_entity
    end
  end

  private

  def fetch_installation
    @installation = Installation.find_or_create_by(uuid: params[:installation_id]) do |i|
      i.ip = request.remote_ip
    end
  end

  def event_data
    request.raw_post
  end

end
