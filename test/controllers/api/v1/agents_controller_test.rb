require 'test_helper'

module Api::V1
  class AgentsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @agent01 = agents(:agent01)
      @agent02 = agents(:agent02)
      @agent03 = agents(:agent03)
      @agent04 = agents(:agent04)
      @agent05 = agents(:agent05)
      @jobqueue02 = jobqueues(:jobqueue02)
    end

    test "should get index" do
      get v1_agents_url, as: :json
      assert_response :ok
    end

    test "should get not heartbeating and running agents" do
      get v1_agents_url(enabled: "true", status: "RUNNING", no_heartbeat_since: "30"), as: :json
      ag = JSON.parse(response.body)
      assert_equal(ag["agents"].count,1)
      assert_response :ok
    end

    test "should create agent" do
      assert_difference('Agent.count') do
        post v1_agents_url, params: {
          agent: {
            enabled: true,
            status: 'REGISTERING',
            version: 'v3',
            jobqueue_id: @jobqueue02.id
          }
        }, as: :json
      end

      assert_response :created
    end

    test "should fail create agent" do
      post v1_agents_url, params: {
        agent: {
          enabled: true,
          status: 'REGISTERING',
          version: 'v3'
        }
      }, as: :json

      assert_response :unprocessable_entity
    end

    test "should show agent" do
      get v1_agent_url(@agent01), as: :json
      assert_response :ok
    end

    test "should update agent" do
      patch v1_agent_url(@agent01), params: { agent: { enabled: @agent01.enabled, heartbeat_at: @agent01.heartbeat_at, status: @agent01.status, version: @agent01.version } }, as: :json
      assert_response :ok
    end

    test "should destroy agent" do
      delete v1_agent_url(@agent01), as: :json
      assert_response :ok
    end

    test "should heartbeat agent" do
      post heartbeat_v1_agent_url(@agent01), as: :json
      assert_response :ok
    end

    test "should disconnect agent" do
      post disconnect_v1_agent_url(@agent01), as: :json
      post_response = JSON.parse(response.body)
      assert_equal('DISCONNECTED', post_response['agent']['status'])
      assert_response :ok
    end

    test "should fail disconnect agent" do
      post disconnect_v1_agent_url(@agent02), as: :json
      post_response = JSON.parse(response.body)
      assert_equal('Unsupported status transition', post_response['error'])
      assert_response 409
    end

    test "should set agent to pausing status" do
      post pause_v1_agent_url(@agent03), as: :json
      post_response = JSON.parse(response.body)
      assert_equal('PAUSING', post_response['agent']['status'])
      assert_response :ok
    end

    test "should fail set agent to pausing status" do
      post pause_v1_agent_url(@agent04), as: :json
      post_response = JSON.parse(response.body)
      assert_equal('Unsupported status transition', post_response['error'])
      assert_response 409
    end

    test "should set agent to resuming status" do
      post resume_v1_agent_url(@agent04), as: :json
      post_response = JSON.parse(response.body)
      assert_equal('RESUMING', post_response['agent']['status'])
      assert_response :ok
    end

    test "should fail set agent to resuming status" do
      post resume_v1_agent_url(@agent03), as: :json
      post_response = JSON.parse(response.body)
      assert_equal('Unsupported status transition', post_response['error'])
      assert_response 409
    end

  end
end
