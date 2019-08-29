class Jobqueue < ApplicationRecord
  include Filterable

  has_many :agents
  validates :name, :presence => true

  scope :jobqueue_name, -> (jobqueue_name) { where name: jobqueue_name }
  scope :arn, -> (arn) { where arn: arn }
end
