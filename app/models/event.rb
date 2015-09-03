class Event < ActiveRecord::Base
  belongs_to :installation

  validates :installation, presence: true

  after_create :index_event

  private

  def index_event
    IndexEventJob.perform_later(self.id) if self.data.present?
  end
end
