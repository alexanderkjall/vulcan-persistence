class Scan < ApplicationRecord
  include Filterable
  has_many :checks

end
