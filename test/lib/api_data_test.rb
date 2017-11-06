require 'test_helper'
require 'wovnrb/text_caches/cache_base'
require 'wovnrb/text_caches/memory_cache'
require 'wovnrb/api_data'
require 'webmock/minitest'

module Wovnrb
  class MemoryCacheTest < WovnMiniTest
    def setup
      Wovnrb::CacheBase.set_single({})
    end

    def teardown
      Wovnrb::CacheBase.reset_cache
      WebMock.reset!
    end

    def test_initialize
      Wovnrb::ApiData.new('http://wwww.example.com', Wovnrb::Store.instance)
    end

    def test_get_data
      token = 'a'
      url = 'url'
      stub_request(:get, "https://api.wovn.io/v0/values?token=#{token}&url=#{url}").
        to_return(:body => '{"test_body": "a"}')
      store = Wovnrb::Store.instance
      store.settings('project_token' => token)
      api_data = Wovnrb::ApiData.new(url, store)

      assert_equal({'test_body' => 'a'}, api_data.get_data)
    end

    def test_get_data_when_cache_exists
      token = 'a'
      url = 'url'
      stub = stub_request(:get, "https://api.wovn.io/v0/values?token=#{token}&url=#{url}").
        to_return(:body => '{"test_body": "a"}')
      store = Wovnrb::Store.instance
      store.settings('project_token' => token)
      api_data = Wovnrb::ApiData.new(url, store)

      assert_equal({'test_body' => 'a'}, api_data.get_data)
      assert_equal({'test_body' => 'a'}, api_data.get_data)
      assert_requested(stub, :times => 1)
    end

    def test_get_data_cache_with_different_project_tokens
      token = 'a'
      url = 'url'
      stub_a = stub_request(:get, "https://api.wovn.io/v0/values?token=#{token}&url=#{url}").
        to_return(:body => '{"test_body": "a"}')
      store = Wovnrb::Store.instance
      api_data = Wovnrb::ApiData.new(url, store)

      store.settings('project_token' => token)
      assert_equal({'test_body' => 'a'}, api_data.get_data)

      token = 'b'
      stub_b = stub_request(:get, "https://api.wovn.io/v0/values?token=#{token}&url=#{url}").
        to_return(:body => '{"test_body": "a"}')
      store.settings('project_token' => token)
      assert_equal({'test_body' => 'a'}, api_data.get_data)

      assert_requested(stub_a, :times => 1)
      assert_requested(stub_b, :times => 1)
    end

    def test_get_data_fail
      token = 'a'
      url = 'url'
      stub_request(:get, "https://api.wovn.io/v0/values?token=#{token}&url=#{url}").
        to_return(:status => [500, "Internal Server Error"])
      store = Wovnrb::Store.instance
      store.settings('project_token' => token)
      api_data = Wovnrb::ApiData.new(url, store)
      log_mock = Wovnrb::LogMock.mock_log

      assert_equal({}, api_data.get_data)
      assert(log_mock.errors[0].start_with?('API server GET request failed'))
    end
  end
end
