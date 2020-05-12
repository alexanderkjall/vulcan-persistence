require 'test_helper'

module Api::V1
  class ChecksControllerTest < ActionDispatch::IntegrationTest
    setup do
      @check01 = checks(:check01)
      @check04 = checks(:check04)
      @agent01 = agents(:agent02)
      @checktype02 = checktypes(:checktype02)
      @checktype04 = checktypes(:checktype04)
      @scan01 = scans(:scan01)
      @check07 = checks(:check07)
      @check08 = checks(:check08)
      @check09 = checks(:check09)
    end

    test "should get index" do
      checks_url = v1_checks_url+"?force=true"
      get checks_url, as: :json
      assert_response :ok
    end

    test "should fail get index" do
      get v1_checks_url, as: :json
      assert_response :method_not_allowed
    end

    test "should create check" do
      assert_difference('Check.count') do
        post v1_checks_url, params: {
          check: {
            target: 'www.example.com',
            options: '',
            status: 'CREATED',
            webhook: 'http://localhost/1',
            agent_id: @agent01.id,
            checktype_id: @checktype02.id,
            tag: 'MyTag'
          }
        }, as: :json
      end

      assert_response :created
    end

    test "should create check with check and checktype options merged" do
      assert_difference('Check.count') do
        post v1_checks_url, params: {
          check: {
            target: 'www.example.com',
            options: "{\"sleep\":10}",
            status: 'CREATED',
            webhook: 'http://localhost/1',
            agent_id: @agent01.id,
            checktype_id: @checktype02.id,
            tag: 'MyTag'
          }
        }, as: :json
      end
      post_response = JSON.parse(response.body)
      assert_equal('{"timeout":60,"sleep":10}', post_response['check']['options'])

      assert_response :created
    end

    test "should create check with checktype options overwritten" do
      assert_difference('Check.count') do
        post v1_checks_url, params: {
          check: {
            target: 'www.example.com',
            options: "{\"timeout\":30,\"sleep\":10}",
            status: 'CREATED',
            webhook: 'http://localhost/1',
            agent_id: @agent01.id,
            checktype_id: @checktype02.id,
            tag: 'MyTag'
          }
        }, as: :json
      end
      post_response = JSON.parse(response.body)
      assert_equal('{"timeout":30,"sleep":10}', post_response['check']['options'])

      assert_response :created
    end

    test "should create check associated to a scan" do
      assert_difference('Check.count') do
        post v1_checks_url, params: {
          check: {
            target: 'www.example.com',
            options: '',
            status: 'CREATED',
            webhook: 'http://localhost/1',
            agent_id: @agent01.id,
            checktype_id: @checktype02.id,
            scan_id: @scan01.id,
            tag: 'MyTag'
          }
        }, as: :json
      end

      assert_response :created
    end

    test "should create check assigned to a specific queue by id" do
      assert_difference('Check.count') do
        post v1_checks_url, params: {
          check: {
            target: 'www.example.com',
            options: '',
            webhook: 'http://localhost/1',
            agent_id: @agent01.id,
            checktype_id: @checktype02.id,
            scan_id: @scan01.id,
            jobqueue_id: '9f102bc5-1e4f-4b4a-8604-178247e4e666'
          }
        }, as: :json
      end
      post_response = JSON.parse(response.body)
      assert_equal('vulcan-test-queue', post_response['check']['queue_name'])
      assert_response :created
    end

    test "should create check assigned to a specific queue by name" do
      assert_difference('Check.count') do
        post v1_checks_url, params: {
          check: {
            target: 'www.example.com',
            options: '',
            webhook: 'http://localhost/1',
            agent_id: @agent01.id,
            checktype_id: @checktype02.id,
            scan_id: @scan01.id,
            jobqueue_name: 'vulcan-test-queue'
          }
        }, as: :json
      end
      post_response = JSON.parse(response.body)
      assert_equal('vulcan-test-queue', post_response['check']['queue_name'])
      assert_response :created
    end

    test "should create check assigned to queue specified by checktype" do
      assert_difference('Check.count') do
        post v1_checks_url, params: {
          check: {
            target: 'www.example.com',
            options: '',
            webhook: 'http://localhost/1',
            agent_id: @agent01.id,
            checktype_id: @checktype04.id,
          }
        }, as: :json
      end
      post_response = JSON.parse(response.body)
      assert_equal('vulcan-nessus-queue', post_response['check']['queue_name'])
      assert_response :created
    end

    test "should fail create check when specifying a non existing queue" do
      post v1_checks_url, params: {
        check: {
          target: 'www.example.com',
          options: '',
          webhook: 'http://localhost/1',
          agent_id: @agent01.id,
          checktype_id: @checktype02.id,
          scan_id: @scan01.id,
          jobqueue_id: 'non-exsisting'
        }
      }, as: :json
      assert_response :unprocessable_entity
    end

    test "should fail create check" do
      post v1_checks_url, params: {
        check: {
          target: 'www.example.com',
          options: 'wrong options',
          status: 'CREATED',
          webhook: 'http://localhost/1',
          agent_id: @agent01.id,
          checktype_id: @checktype02.id,
          scan_id: @scan01.id,
          tag: 'MyTag'
        }
      }, as: :json

      assert_response :unprocessable_entity
    end

    test "should fail create check with wrong options" do
      post v1_checks_url, params: {
        check: {
          options: 'wrong options',
          status: 'CREATED',
          webhook: 'http://localhost/1',
          agent_id: @agent01.id
        }
      }, as: :json

      assert_response :unprocessable_entity
    end

    test "should show check" do
      get v1_check_url(@check01), as: :json
      assert_response :ok
    end

    test "should update check" do
      patch v1_check_url(@check01), params: { check: { options: @check01.options, status: @check01.status, webhook: @check01.webhook, tag: @check01.tag } }, as: :json
      assert_response :ok
    end

    test "should kill check" do
      post kill_v1_check_url(@check04), as: :json
      post_response = JSON.parse(response.body)
      assert_equal('PURGING', post_response['check']['status'])
      assert_response :ok
    end

    test "should fail kill check" do
      post kill_v1_check_url(@check01), as: :json
      post_response = JSON.parse(response.body)
      assert_equal('Unsupported status transition', post_response['error'])
      assert_response 409
    end

    test "should abort check" do
      post abort_v1_check_url(@check04), as: :json
      post_response = JSON.parse(response.body)
      assert_equal('ABORTED', post_response['check']['status'])
      assert_response :ok
    end

    test "should fail abort check" do
      post abort_v1_check_url(@check01), as: :json
      post_response = JSON.parse(response.body)
      assert_equal('Unsupported status transition', post_response['error'])
      assert_response 409
    end

    test "should return precondition_failed response" do
      patch v1_check_url(@check07), params: { check: { options: @check07.options, status: "ASSIGNED", webhook: @check07.webhook, tag: @check07.tag } }, as: :json
      assert_response :precondition_failed
    end

    test "should destroy check" do
      delete v1_check_url(@check01), as: :json
      assert_response :ok
    end

    test "should update check to timeout" do
      patch v1_check_url(@check08), params: { check: { status: "TIMEOUT" } }, as: :json
      assert_response :ok
    end

    test "should fail update check to timeout" do
      patch v1_check_url(@check09), params: { check: { status: "TIMEOUT" } }, as: :json
      post_response = JSON.parse(response.body)
      assert_equal('Unsupported status transition', post_response['error'])
      assert_response 409
    end
  end
end
