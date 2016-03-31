require 'minitest/autorun'
require 'test_helper'

module Wovnrb
  class StoreTest < WovnMiniTest
    def test_initialize
      s = Wovnrb::Store.instance
      refute_nil(s)
    end

    def test_settings_no_parameters
      s = Wovnrb::Store.instance
      assert_equal('path', s.settings['url_pattern'])
      assert_equal('/(?<lang>[^/.?]+)', s.settings['url_pattern_reg'])
    end

    def test_settings_url_pattern_path
      s = Wovnrb::Store.instance
      s.settings({'url_pattern' => 'path'})
      assert_equal('path', s.settings['url_pattern'])
      assert_equal('/(?<lang>[^/.?]+)', s.settings['url_pattern_reg'])
    end

    def test_settings_url_pattern_subdomain
      s = Wovnrb::Store.instance
      s.settings({'url_pattern' => 'subdomain'})
      assert_equal("^(?<lang>[^.]+)\.", s.settings['url_pattern_reg'])
      assert_equal('subdomain', s.settings['url_pattern'])
    end

    def test_settings_url_pattern_query
      s = Wovnrb::Store.instance
      s.settings({'url_pattern' => 'query'})
      assert_equal('((\\?.*&)|\\?)wovn=(?<lang>[^&]+)(&|$)', s.settings['url_pattern_reg'])
      assert_equal('query', s.settings['url_pattern'])
    end

    def test_invalid_settings
      mock = LogMock.mock_log
      store = Wovnrb::Store.instance
      valid = store.valid_settings?

      assert_equal(false, valid)
      assert_equal(['User token  is not valid.', 'Secret key  is not valid.'], mock.errors)
    end
  end
end
