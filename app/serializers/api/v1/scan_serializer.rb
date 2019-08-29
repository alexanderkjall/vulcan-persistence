module Api::V1
  class ScanSerializer < ActiveModel::Serializer
    attributes :id, :size, :created_at, :aborted, :aborted_at
  end
end
