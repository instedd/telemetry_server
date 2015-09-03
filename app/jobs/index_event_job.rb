class IndexEventJob < ActiveJob::Base
  queue_as :default

  def perform(event_id)
    event = Event.find_by(id: event_id)
    return if event.nil?

    EventIndexer.new.index(event)
  end
end
