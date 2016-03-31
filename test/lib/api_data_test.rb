require 'wovnrb/lang'
require 'wovnrb/store'
require 'wovnrb/text_caches/cache_base'
require 'wovnrb/text_caches/memory_cache'
require 'wovnrb/api_data'
require 'minitest/autorun'
require 'webmock/minitest'

class MemoryCacheTest < Minitest::Test
  def setup
    Wovnrb::CacheBase.set_single({})
  end

  def teardown
    Wovnrb::CacheBase.reset_cache
    WebMock.reset!
  end

  def test_initialize
    Wovnrb::ApiData.new('http://wwww.example.com', Wovnrb::Store.new)
  end

  def test_get_data
    token = 'a'
    url = 'url'
    stub_request(:get, "https://api.wovn.io/v0/values?token=#{token}&url=#{url}").
      to_return(:body => '{"test_body": "a"}')
    store = Wovnrb::Store.new
    store.settings['user_token'] = token
    api_data = Wovnrb::ApiData.new(url, store)

    assert_equal({'test_body' => 'a'}, api_data.get_data)
  end

  def test_get_data_when_cache_exists
    token = 'a'
    url = 'url'
    stub = stub_request(:get, "https://api.wovn.io/v0/values?token=#{token}&url=#{url}").
      to_return(:body => '{"test_body": "a"}')
    store = Wovnrb::Store.new
    store.settings['user_token'] = token
    api_data = Wovnrb::ApiData.new(url, store)

    assert_equal({'test_body' => 'a'}, api_data.get_data)
    assert_equal({'test_body' => 'a'}, api_data.get_data)
    assert_requested(stub, :times => 1)
  end
end
