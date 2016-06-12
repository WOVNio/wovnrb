require 'wovnrb/text_caches/cache_base'
require 'wovnrb/text_caches/memory_cache'
require 'wovnrb/api_data'
require 'test_helper'
require 'webmock/minitest'

class Wovnrb
  class MemoryCacheTest < WovnMiniTest
    def setup
      Wovnrb::CacheBase.set_single({})
    end

    def teardown
      Wovnrb::CacheBase.reset_cache
      WebMock.reset!
    end

    def test_initialize
      Wovnrb::ApiData.new(Wovnrb::Store.instance)
    end

    def test_get_page_values
      token = 'a'
      url = 'url'
      stub_request(:get, "https://api.wovn.io/v0/values?token=#{token}&url=#{url}").
        to_return(:body => '{"test_body": "a"}')
      store = Wovnrb::Store.instance
      store.settings['user_token'] = token
      api_data = Wovnrb::ApiData.new(store)

      assert_equal({'test_body' => 'a'}, api_data.get_page_values(url))
    end

    def test_get_page_values_when_cache_exists
      token = 'a'
      url = 'url'
      stub = stub_request(:get, "https://api.wovn.io/v0/values?token=#{token}&url=#{url}").
        to_return(:body => '{"test_body": "a"}')
      store = Wovnrb::Store.instance
      store.settings['user_token'] = token
      api_data = Wovnrb::ApiData.new(store)

      assert_equal({'test_body' => 'a'}, api_data.get_page_values(url))
      assert_equal({'test_body' => 'a'}, api_data.get_page_values(url))
      assert_requested(stub, :times => 1)
    end

    def test_get_page_values_fail
      token = 'a'
      url = 'url'
      stub_request(:get, "https://api.wovn.io/v0/values?token=#{token}&url=#{url}").
        to_return(:status => [500, "Internal Server Error"])
      store = Wovnrb::Store.instance
      store.settings['user_token'] = token
      api_data = Wovnrb::ApiData.new(store)
      log_mock = Wovnrb::LogMock.mock_log

      assert_equal({}, api_data.get_page_values(url))
      assert(log_mock.errors[0].start_with?('API server GET request failed'))
    end

    def test_build_page_values_uri
      token = 'a'
      url = 'url'
      store = Wovnrb::Store.instance
      store.settings['user_token'] = token
      api_data = Wovnrb::ApiData.new(store)
      api_data.instance_variable_set(:@access_url, url)
      api_uri = api_data.send(:build_page_values_uri)
      assert_equal('https://api.wovn.io/v0/values?token=a&url=url', api_uri.to_s)
    end

    def test_build_page_values_uri_with_old_api_url
      token = 'a'
      url = 'url'
      store = Wovnrb::Store.instance
      store.settings['user_token'] = token
      store.settings['api_url'] = 'https://api.wovn.io/v0/values'
      api_data = Wovnrb::ApiData.new(store)
      api_data.instance_variable_set(:@access_url, url)
      api_uri = api_data.send(:build_page_values_uri)
      assert_equal('https://api.wovn.io/v0/values?token=a&url=url', api_uri.to_s)
    end

    def test_build_page_values_uri_with_non_default_api_url
      token = 'a'
      url = 'url'
      store = Wovnrb::Store.instance
      store.settings['user_token'] = token
      store.settings['api_url'] = 'http://api0.wovn.io/v1'
      api_data = Wovnrb::ApiData.new(store)
      api_data.instance_variable_set(:@access_url, url)
      api_uri = api_data.send(:build_page_values_uri)
      assert_equal('http://api0.wovn.io/v1/values?token=a&url=url', api_uri.to_s)
    end
  end
end
