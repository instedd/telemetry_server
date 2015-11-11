class EventsController < AuthenticatedController

  def index
    @installation = Installation.find(params[:installation_id])
  end

  def errors
    @event = Event.find(params[:id])
  end

end
