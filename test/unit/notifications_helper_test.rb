require 'test_helper'

describe "notifications helper" do
  it "should notify" do
    it_ok = false
    channel = Rails.application.config.stream_channel
    connection = ActiveRecord::Base.connection
    connection.execute "LISTEN #{channel}"
    NotificationsHelper.notify(action: 'test')
    connection.raw_connection.wait_for_notify do |channel, pid, message|
      json_message = JSON.load(message)
      it_ok = true if json_message['action'] == 'test'
    end
    connection.execute "UNLISTEN #{channel}"
    assert_equal(true, it_ok)
  end

  it "should fail notify due to no action" do
    assert_raises(ArgumentError) {
      NotificationsHelper.notify()
    }
  end
end
