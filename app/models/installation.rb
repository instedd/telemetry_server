class Installation < ActiveRecord::Base
  has_many :events

  validates :uuid, presence: true
  validates :uuid, uniqueness: true

  after_commit :geocode
  after_commit :index_installation

  def update_timestamps_from(event)
    self.last_reported_at = [self.last_reported_at, event.created_at].reject(&:nil?).max

    if event.has_reported_errors?
      self.last_errored_at = [self.last_errored_at, event.created_at].reject(&:nil?).max
    end

    self.save
  end

  def needs_geocoding?
    !self.latitude.present? || !self.latitude.present?
  end

  private

  def geocode
    if self.ip.present? && self.needs_geocoding?
      GeocodeInstallationJob.perform_later self.id
    end
  end

  def index_installation
    IndexInstallationJob.perform_later(self.id)
  end
end
