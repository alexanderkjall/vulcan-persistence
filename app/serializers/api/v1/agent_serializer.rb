module Api::V1
  class AgentSerializer < ActiveModel::Serializer
    include Rails.application.routes.url_helpers

    attributes :id, :status, :version, :enabled, :heartbeat_at

    has_one :jobqueue,  serializer: Api::V1::JobqueueSerializer

    attribute :links do
      { self: v1_agent_path(object.id) }
    end
  end
end
