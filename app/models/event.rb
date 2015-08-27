class Event < ActiveRecord::Base
  belongs_to :installation

  validates :installation, presence: true
end
