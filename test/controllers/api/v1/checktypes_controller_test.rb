require 'test_helper'

module Api::V1
  class ChecktypesControllerTest < ActionDispatch::IntegrationTest
    setup do
      @checktype = checktypes(:checktype01)
    end

    test "should get index" do
      get v1_checktypes_url, as: :json
      assert_response :ok
    end

    test "should get index only enabled" do
      get v1_checktypes_url(enabled: "true"), as: :json
      ct = JSON.parse(response.body)
      assert_equal(ct["checktypes"].count,3)
      assert_response :ok
    end

    test "should get latest checktype with name" do
      get v1_checktypes_url(name: "tls"), as: :json
      ct = JSON.parse(response.body)
      assert_equal(ct["checktype"]["image"],"dockerimage3")
      assert_response :ok
    end

    test "should create checktype" do
      assert_difference('Checktype.count') do
        post v1_checktypes_url, params: {
          checktype: {
            description: 'Checktyp description text',
            image: 'dockerimage1',
            name: 'newchecktype',
            timeout: 10
          }
        }, as: :json
      end
      assert_response :created
    end

    test "should create checktype storing all the fields" do
      check = {
        checktype: {
        description: 'Checktyp description text',
        required_vars: ['ENV_VAR'],
        image: 'dockerimage1',
        name: 'newchecktype',
        timeout: 10,
        assets: ['Domain']
      }
    }
      post v1_checktypes_url, params: check, as: :json
      assert_response :created
      body = JSON.parse(@response.body, symbolize_names: true)
      body = body[:checktype]
      check = check[:checktype]
      # ignore the fields added by the reponse but not directly specified by the test
      delete_fields(body,[:id,:links,:enabled])
      diff = hash_deep_diff(body,check)
      assert_equal diff, {}
    end

    test "should fail create checktype" do
      post v1_checktypes_url, params: {
        checktype: {
          description: 'Checktype description text',
          timeout: 10
        }
      }, as: :json

      assert_response :unprocessable_entity
    end

    test "should fail create checktype due to wrong content type" do
      post v1_checktypes_url, params: {
        checktype: {
          description: 'Checktype description text',
          image: 'dockerimage1',
          name: 'newchecktype',
          timeout: 10
        }
      }

      assert_response :unsupported_media_type
    end

    test "should show checktype" do
      get v1_checktype_url(@checktype), as: :json
      assert_response :ok
    end

    test "should update checktype" do
      patch v1_checktype_url(@checktype), params: { checktype: { description: @checktype.description, image: @checktype.image, name: @checktype.name, options: @checktype.options, timeout: 20 } }, as: :json
      assert_response :ok
    end

    test "should destroy checktype" do
      delete v1_checktype_url(@checktype), as: :json
      assert_response :ok
    end
  end
end
