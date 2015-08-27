class Installation < ActiveRecord::Base
  has_many :events

  validates :uuid, presence: true
  validates :uuid, uniqueness: true
end
