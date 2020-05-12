require 'test_helper'

module Api::V1
# This test MUST run before the test: scans_controller_test.rb.
# That's the only way found to allow the jobs tested to not interference.
# That's the reason this test starts with A.
  class A_FilescanControllerTest < ActionDispatch::IntegrationTest
    test "should create a file scan" do
    assert_difference('Scan.count') do
        upload_fixture =  fixture_file_upload('files/scan.json', 'text')
        post v1_filescan_url, params: {upload: upload_fixture}
      end
    assert_response 201
    end
  end
end
