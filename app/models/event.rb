class Event < ActiveRecord::Base
  belongs_to :installation

  validates :installation, presence: true

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

  private

  def index_event
    IndexEventJob.perform_later(self.id) if self.data.present?
  end

  def update_installation
    self.installation.update_timestamps_from self
  end
end
