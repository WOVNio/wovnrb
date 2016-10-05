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

    def test_settings_ignore_patterns
      s = Wovnrb::Store.instance
      s.settings({'ignore_patterns' => ['/api/**']})
      assert_equal(1, s.settings['ignore_globs'].size)
      assert_equal(true, s.settings['ignore_globs'].first.match?('/api/a/b'))
      assert_equal(false, s.settings['ignore_globs'].first.match?('/a/b'))
    end

    def test_settings_ignore_patterns_multiple
      s = Wovnrb::Store.instance
      s.settings({'ignore_patterns' => ['/api/a/**', '/api/b/**']})
      assert_equal(2, s.settings['ignore_globs'].size)
      assert_equal(true, s.settings['ignore_globs'].any?{|g| g.match?('/api/a')})
      assert_equal(true, s.settings['ignore_globs'].any?{|g| g.match?('/api/b')})
      assert_equal(false, s.settings['ignore_globs'].any?{|g| g.match?('/api/c')})
    end

    def test_settings_ignore_patterns_empty
      s = Wovnrb::Store.instance
      s.settings({'ignore_patterns' => []})
      assert_equal([], s.settings['ignore_globs'])
    end

    def test_settings_invalid_ignore_patterns
      mock = LogMock.mock_log
      store = Wovnrb::Store.instance
      store.settings({'ignore_patterns' => 'aaaa'})

      assert_equal(false, store.valid_settings?)
      assert_equal(['User token  is not valid.', 'Secret key  is not valid.', 'Ignore Patterns aaaa should be Array.'], mock.errors)
    end
  end
end
