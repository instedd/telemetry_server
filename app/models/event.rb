class Event < ActiveRecord::Base
  belongs_to :installation

  validates :installation, presence: true

  after_save   :touch_installation
  after_commit :index_event

  private

  def index_event
    IndexEventJob.perform_later(self.id) if self.data.present?
  end

  def touch_installation
    self.installation.touch_last_reported_at!
  end
end
