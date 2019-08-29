require 'test_helper'

module Api::V1
  class JobqueuesControllerTest < ActionDispatch::IntegrationTest
    setup do
      @jobqueue = jobqueues(:jobqueue01)
    end

    test "should get index" do
      get v1_jobqueues_url, as: :json
      assert_response :ok
    end

    test "should create jobqueue" do
      assert_difference('Jobqueue.count') do
        post v1_jobqueues_url, params: {
          jobqueue: {
            name: 'z',
            arn: 'z:z:z:z',
            description: 'Jobqueue description'
          }
        }, as: :json
      end

      assert_response :created
    end

    test "should fail create default jobqueue" do
      post v1_jobqueues_url, params: {
        jobqueue: {
          name: 'a',
          description: 'Jobqueue description',
          default: true,
        }
      }, as: :json

      assert_response :bad_request
    end

    test "should fail create jobqueue" do
      post v1_jobqueues_url, params: {
        jobqueue: {
          description: 'Jobqueue description'
        }
      }, as: :json

      assert_response :unprocessable_entity
    end

    test "should show jobqueue" do
      get v1_jobqueue_url(@jobqueue), as: :json
      assert_response :ok
    end

    test "should update jobqueue" do
      patch v1_jobqueue_url(@jobqueue), params: { jobqueue: { name: @jobqueue.name, description: @jobqueue.description } }, as: :json
      assert_response :ok
    end

    test "should destroy jobqueue" do
      delete v1_jobqueue_url(@jobqueue), as: :json
      assert_response :ok
    end
  end
end
