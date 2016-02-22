require 'test_helper'

class GithubWebhooksControllerTest < ActionController::TestCase
  test "should get webhooks" do
    get :webhooks
    assert_response :success
  end

end
