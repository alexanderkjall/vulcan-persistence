module Api::V1
  class ScanStatsSerializer < ActiveModel::Serializer
    attributes :status, :total
  end
end
