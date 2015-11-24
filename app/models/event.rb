class Event < ActiveRecord::Base
  belongs_to :installation

  validates :installation, presence: true
  validate :period_span_presence
  validate :period_overlapping

  before_validation :ensure_period_span, on: :create
  after_save   :update_installation
  after_commit :index_event

  def parsed_data
    @parsed_data ||= JSON.parse(self.data).with_indifferent_access rescue {}
  end

  def has_reported_errors?
    parsed_data[:errors].present?
  end

  def reported_errors
    parsed_data[:errors] || []
  end

  def already_reported?
    ensure_period_span
    self.class.where(period_beginning: self.period_beginning, period_end: self.period_end, installation: self.installation).exists?
  end

  private

  def ensure_period_span
    if self.period_beginning.nil? && beginning_str = parsed_data[:period].try(:[], :beginning)
      self.period_beginning = Time.parse(beginning_str) rescue nil
    end

    if self.period_end.nil? && end_str = parsed_data[:period].try(:[], :end)
      self.period_end = Time.parse(end_str) rescue nil
    end
  end

  def period_span_presence
    if self.period_beginning.present? && self.period_end.nil?
      errors.add(:period_end, 'is required')
    end

    if self.period_beginning.nil? && self.period_end.present?
      errors.add(:period_beginning, 'is required')
    end
  end

  def period_overlapping
    if self.period_beginning.present? && self.period_end.present?
      overlapping_exists = Event.where('(period_beginning >= ? AND period_beginning < ?) OR (period_beginning < ? AND period_end > ?)', self.period_beginning, self.period_end, self.period_beginning, self.period_beginning)
      overlapping_exists = overlapping_exists.where(installation: self.installation)
      overlapping_exists = overlapping_exists.where('id != ?', self.id) if self.id.present?
      overlapping_exists = overlapping_exists.exists?

      errors.add(:base, 'period conflicts with another event') if overlapping_exists
    end
  end

  def index_event
    IndexEventJob.perform_later(self.id) if self.data.present?
  end

  def update_installation
    self.installation.update_timestamps_from self
  end
end
