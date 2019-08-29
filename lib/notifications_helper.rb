class NotificationsHelper
  class << self
    def notify(action, check_id: nil, agent_id: nil, scan_id: nil)
      channel ||= Rails.application.config.stream_channel
      begin
        ActiveRecord::Base.connection.execute(
          "NOTIFY #{channel}, '#{action.to_json}'"
        )
      rescue => e
        Rails.logger.error e.message
        Rails.logger.error e.backtrace.join("\n")
      end
    end
  end
end
