require 'test_helper'
require 'cgi'
require 'json'
require 'wovnrb/text_caches/cache_base'
require 'wovnrb/text_caches/memory_cache'
require 'wovnrb/api_data'
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

    def test_get_project_values
      token = 'a'
      srcs = ['Message']
      host = 'wovn.io'
      target_lang = 'ja'
      stub_request(:get, "https://api.wovn.io/v0/project/values?srcs=#{CGI::escape(srcs.to_json)}&host=#{CGI::escape(host)}&target_lang=#{target_lang}&token=#{token}").
        to_return(:body => '{"results": [{"dst": "メッセージ", "src": "Message"}]}')
      store = Wovnrb::Store.instance
      store.settings['user_token'] = token
      api_data = Wovnrb::ApiData.new(store)
      assert_equal({'results' => [{'dst' => 'メッセージ', 'src' => 'Message'}]}, api_data.get_project_values(srcs, host, target_lang))
    end

    def test_build_api_url
      store = Store.instance
      api_data = ApiData.new(store)
      api_url = api_data.send(:build_api_url, '/values')
      assert_equal('https://api.wovn.io/v0/values', api_url.to_s)
    end

    def test_build_api_url_with_old_api_url
      store = Store.instance
      store.settings['api_url'] = 'https://api.wovn.io/v0/values'
      api_data = ApiData.new(store)
      api_url = api_data.send(:build_api_url, '/project/values')
      assert_equal('https://api.wovn.io/v0/project/values', api_url.to_s)
    end

    def test_build_api_url_with_non_default_api_url
      store = Store.instance
      store.settings['api_url'] = 'http://api0.wovn.io/v1'
      api_data = ApiData.new(store)
      api_url = api_data.send(:build_api_url, '/values')
      assert_equal('http://api0.wovn.io/v1/values', api_url.to_s)
    end

    def test_build_api_url_with_host_only
      store = Store.instance
      store.settings['api_url'] = 'https://api.wovn.io'
      api_data = ApiData.new(store)
      api_url = api_data.send(:build_api_url, '/values')
      assert_equal('https://api.wovn.io/v0/values', api_url.to_s)
    end

    def test_build_page_values_uri
      token = 'a'
      url = 'url'
      store = Store.instance
      store.settings['user_token'] = token
      api_data = ApiData.new(store)
      api_data.instance_variable_set(:@access_url, url)
      api_uri = api_data.send(:build_page_values_uri)
      assert_equal('https://api.wovn.io/v0/values?token=a&url=url', api_uri.to_s)
    end

    def test_build_project_values_uri
      token = 'a'
      srcs = ['Message']
      host = 'wovn.io'
      target_lang = 'ja'
      store = Store.instance
      store.settings['user_token'] = token
      api_data = ApiData.new(store)
      api_data.instance_variable_set(:@srcs, srcs)
      api_data.instance_variable_set(:@host, host)
      api_data.instance_variable_set(:@target_lang, target_lang)
      api_uri = api_data.send(:build_project_values_uri)
      assert_equal("https://api.wovn.io/v0/project/values?srcs=#{CGI::escape(srcs.to_json)}&host=#{CGI::escape(host)}&target_lang=#{target_lang}&token=#{token}", api_uri.to_s)
    end
  end
end
