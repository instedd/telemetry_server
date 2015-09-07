class Event < ActiveRecord::Base
  belongs_to :installation

  validates :installation, presence: true

  after_create :index_event
  after_create :touch_installation

  private

  def index_event
    IndexEventJob.perform_later(self.id) if self.data.present?
  end

  def touch_installation
    self.installation.touch_last_reported_at!
  end
end
