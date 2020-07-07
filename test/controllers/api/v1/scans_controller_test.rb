require 'test_helper'

module Api::V1
# This test MUST run before the test: scans_controller_test.rb.
# That's the only way found to allow the jobs tested to not interference.
# That's the reason this test starts with Z.
  class Z_ScansControllerTest < ActionDispatch::IntegrationTest
    setup do
      @scan01 = scans(:scan01)
      @scan05 = scans(:scan05)
      @scan06 = scans(:scan06)
    end

    test "should get index" do
      scans_url = v1_scans_url+"?force=true"
      get scans_url, as: :json
      assert_response :success
    end

    test "should fail get index" do
      get v1_scans_url, as: :json
      assert_response :method_not_allowed
    end

    test "should create scan" do
      assert_difference('Scan.count') do
        post v1_scans_url, params: nil, as: :json
      end

      assert_response 201
    end

    test "should create scan with checks" do
      assert_difference('Scan.count') do
        post v1_scans_url, params: { scan: { tag: "test-tag", program_id: "test-program", checks: [{ check: { checktype_name: "tls", target: "localhost" }}, { check: { checktype_name: "tls", target: "www.example.com" }}] } }, as: :json
      end
      scan = JSON.parse(response.body)
      assert_response 201
      assert_equal(scan['scan']['size'], 0)
      assert_equal('test-tag', scan['scan']['tag'])
      assert_equal('test-program', scan['scan']['program'])
    end

    test "should create scan with checks associated to a specific queue" do
      scan = nil
      assert_difference('Scan.count') do
        post v1_scans_url, params: { scan: { checks: [{ check: { checktype_name: "tls", target: "localhost", jobqueue_id: '9f102bc5-1e4f-4b4a-8604-178247e4e666' }}, { check: { checktype_name: "tls", target: "www.example.com", jobqueue_id: '9f102bc5-1e4f-4b4a-8604-178247e4e666' }}] } }, as: :json
        scan = JSON.parse(response.body)
      end

      assert_response 201
      assert_equal(scan['scan']['size'], 0)

      get checks_v1_scan_url(scan['scan']['id']), as: :json
      scan_checks = JSON.parse(response.body)
      get v1_check_url(scan_checks['checks'][0]['id'])
      check0 = JSON.parse(response.body)
      get v1_check_url(scan_checks['checks'][1]['id'])
      check1 = JSON.parse(response.body)
      assert_equal(check0['check']['queue_name'], 'vulcan-test-queue')
      assert_equal(check1['check']['queue_name'], 'vulcan-test-queue')
    end

    test "should show scan" do
      get v1_scan_url(@scan01), as: :json
      assert_response :success
    end

    test "should destroy scan" do
      delete v1_scan_url(@scan01), as: :json
      assert_response :ok
    end

    test "should get running checks for selected scan" do
      get checks_v1_scan_url(@scan01, status: "RUNNING"), as: :json
      checks = JSON.parse(response.body)
      assert_equal(2, checks["checks"].count)
      assert_response :ok
    end

    test "should match scan size with number of checks" do
      get v1_scan_url(@scan01), as: :json
      scan = JSON.parse(response.body)
      get checks_v1_scan_url(@scan01), as: :json
      checks = JSON.parse(response.body)
      assert_equal(checks["checks"].count, scan["scan"]["size"])
      assert_response :ok
    end

    test "should get scan stats" do
      get stats_v1_scan_url(@scan01), as: :json
      scan_stats = JSON.parse(response.body)
      scan_stats["checks"].each do |stat|
        get checks_v1_scan_url(@scan01, status: stat["status"]), as: :json
        scan_checks = JSON.parse(response.body)
        assert_equal(scan_checks["checks"].count, stat["total"])
      end
      assert_response :ok
    end

    test "should abort scan" do
      post abort_v1_scan_url(@scan05), as: :json
      assert_response :accepted
    end

    test "should fail abort scan" do
      post abort_v1_scan_url(@scan06), as: :json
      assert_response :conflict
    end

    test "should show aborted scan" do
      get v1_scan_url(@scan06), as: :json
      scan = JSON.parse(response.body)
      assert_equal(scan["scan"]["aborted"], true)
      assert_equal(scan["scan"]["aborted_at"], "2018-10-06T09:03:50.000Z")
      assert_response :success
    end
  end
end
