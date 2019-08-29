module Api::V1
  class CheckSerializer < ActiveModel::Serializer
    include Rails.application.routes.url_helpers

    attributes :id, :target, :status, :options, :webhook, :progress, :raw, :report, :queue_name, :tag

    has_one :agent, serializer: Api::V1::AgentSerializer
    has_one :checktype, serializer: Api::V1::ChecktypeSerializer
    has_one :scan, serializer: Api::V1::ScanSerializer

    attribute :links do
      { self: v1_check_path(object.id) }
    end
  end
end
