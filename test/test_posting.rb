require 'helper'

class Toadhopper::TestPosting < Test::Unit::TestCase
  def test_mock_posting
    key = 'lolc@tz'
    response_body = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<notice/>"
    FakeWeb.register_uri(:post, 'http://airbrake.io/notifier_api/v2/notices', :body => response_body, :status => ['200', 'OK'])
    response = Toadhopper(key).post!(error)
    # Check our request
    assert_match key, FakeWeb.last_request.body, FakeWeb.last_request.body
    # Check how we capture the mock response
    assert_equal 200, response.status, response
    assert_equal response_body, response.body, response
    assert_equal [], response.errors, response
  end

  def test_posting
    FakeWeb.allow_net_connect = true
    response = Toadhopper('bogus key').post!(error)
    # Check how we capture the live response
    assert_equal 422, response.status, response
    assert_respond_to response.errors, :each_with_index, response
    assert_equal 1, response.errors.length, response
  end

  if ENV['AIRBRAKE_API_KEY']
    def test_posting_integration
      FakeWeb.allow_net_connect = true
      toadhopper.filters = "AIRBRAKE_API_KEY", "ROOT_PASSWORD"
      response = toadhopper.post!(error)
      # Check how we capture the live response
      assert_equal 200, response.status, response
      assert_match '</id>', response.body, response
      assert_equal [], response.errors, response
    end
  end

  # This method is called automatically after every test
  def teardown
    reset_test_env
  end
end
