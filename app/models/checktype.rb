class Checktype < ApplicationRecord
  include Filterable

  has_many :checks
  validates :name, :presence => true
  validates :timeout, :image, :presence => true

  scope :checktype, -> (checktype) { where name: checktype }
  scope :enabled, -> (enabled) { where enabled: enabled }
  scope :image, -> (image) { where image: image }
  scope :queue_name, -> (queue_name) { where queue_name: queue_name }
end
