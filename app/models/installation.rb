class Installation < ActiveRecord::Base
  has_many :events

  validates :uuid, presence: true
  validates :uuid, uniqueness: true

  after_save :geocode
  after_save :index_installation

  def touch_last_reported_at!
    self.last_reported_at = Time.now.utc
    self.save
  end

  private

  def geocode
    if self.ip.present? && self.ip_changed?
      GeocodeInstallationJob.perform_later self.id
    end
  end

  def index_installation
    IndexInstallationJob.perform_later(self.id)
  end
end
