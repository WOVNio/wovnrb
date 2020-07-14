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

    def test_settings_user_token_retro_compatibility
      s = Wovnrb::Store.instance
      s.update_settings('user_token' => 'aaaaa')
      assert_equal('aaaaa', s.settings['project_token'])
      assert(!s.settings.key?('user_token'))
    end

    def test_settings_project_token_set
      s = Wovnrb::Store.instance
      s.update_settings('project_token' => 'bbbbbb')
      assert_equal('bbbbbb', s.settings['project_token'])
    end

    def test_settings_project_token_set_without_retro_compatibility
      s = Wovnrb::Store.instance
      s.update_settings('project_token' => 'bbbbbb', 'user_token' => 'aaaaa')
      assert_equal('bbbbbb', s.settings['project_token'])
      assert(!s.settings.key?('user_token'))
    end

    def test_settings_url_pattern_path
      s = Wovnrb::Store.instance
      s.update_settings('url_pattern' => 'path')
      assert_equal('path', s.settings['url_pattern'])
      assert_equal('/(?<lang>[^/.?]+)', s.settings['url_pattern_reg'])
    end

    def test_settings_url_pattern_subdomain
      s = Wovnrb::Store.instance
      s.update_settings('url_pattern' => 'subdomain')
      assert_equal("^(?<lang>[^.]+)\.", s.settings['url_pattern_reg'])
      assert_equal('subdomain', s.settings['url_pattern'])
    end

    def test_settings_url_pattern_query
      s = Wovnrb::Store.instance
      s.update_settings('url_pattern' => 'query')
      assert_equal('((\\?.*&)|\\?)wovn=(?<lang>[^&]+)(&|$)', s.settings['url_pattern_reg'])
      assert_equal('query', s.settings['url_pattern'])
    end

    def test_settings_url_pattern_query_with_lang_param_name
      sut = Wovnrb::Store.instance

      sut.update_settings('url_pattern' => 'query', 'lang_param_name' => 'lang')

      assert_equal('((\\?.*&)|\\?)lang=(?<lang>[^&]+)(&|$)', sut.settings['url_pattern_reg'])
      assert_equal('query', sut.settings['url_pattern'])
    end

    def test_lang_param_name_wovn_by_default
      sut = Wovnrb::Store.instance

      assert_equal('wovn', sut.settings['lang_param_name'])
    end

    def test_lang_param_name_update
      sut = Wovnrb::Store.instance

      sut.update_settings('lang_param_name' => 'lang')
      assert_equal('lang', sut.settings['lang_param_name'])
    end

    def test_invalid_settings
      mock = LogMock.mock_log
      store = Wovnrb::Store.instance
      valid = store.valid_settings?

      assert_equal(false, valid)
      assert_equal(['Project token  is not valid.'], mock.errors)
    end

    def test_settings_ignore_paths
      s = Wovnrb::Store.instance
      s.update_settings('ignore_paths' => ['/api/**'])
      assert_equal(1, s.settings['ignore_globs'].size)
      assert_equal(true, s.settings['ignore_globs'].first.match?('/api/a/b'))
      assert_equal(false, s.settings['ignore_globs'].first.match?('/a/b'))
    end

    def test_settings_ignore_paths_multiple
      s = Wovnrb::Store.instance
      s.update_settings('ignore_paths' => ['/api/a/**', '/api/b/**'])
      assert_equal(2, s.settings['ignore_globs'].size)
      assert_equal(true, s.settings['ignore_globs'].any? { |g| g.match?('/api/a') })
      assert_equal(true, s.settings['ignore_globs'].any? { |g| g.match?('/api/b') })
      assert_equal(false, s.settings['ignore_globs'].any? { |g| g.match?('/api/c') })
    end

    def test_settings_ignore_paths_empty
      s = Wovnrb::Store.instance
      s.update_settings('ignore_paths' => [])
      assert_equal([], s.settings['ignore_globs'])
    end

    def test_settings_invalid_ignore_paths
      mock = LogMock.mock_log
      store = Wovnrb::Store.instance
      store.update_settings('ignore_paths' => 'aaaa')

      assert_equal(false, store.valid_settings?)
      assert_equal(['Project token  is not valid.', 'Ignore Paths aaaa should be Array.'], mock.errors)
    end

    def test_settings_ignore_glob_injection
      s = Wovnrb::Store.instance
      s.update_settings('ignore_paths' => nil)
      s.update_settings('ignore_globs' => [1, 2])

      assert_equal([], s.settings['ignore_globs'])
    end

    def test_default_dev_mode_settings
      store = Wovnrb::Store.instance

      store.update_settings('wovn_dev_mode' => true)

      assert(store.dev_mode?)
      assert_equal('dev-wovn.io', store.wovn_host)
      assert_equal('http://dev-wovn.io:3001/v0/', store.settings['api_url'])
      assert_equal(3, store.settings['api_timeout_seconds'])
    end

    def test_dev_mode_not_overriding_settings
      store = Wovnrb::Store.instance

      store.update_settings(
        'wovn_dev_mode' => true,
        'api_url' => 'http://my-test-api.wovn.io/v0/',
        'api_timeout_seconds' => 42
      )

      assert(store.dev_mode?)
      assert_equal('http://my-test-api.wovn.io/v0/', store.settings['api_url'])
      assert_equal(42, store.settings['api_timeout_seconds'])
    end

    def test_dev_mode?
      store = Wovnrb::Store.instance

      assert_equal(false, store.settings['wovn_dev_mode'])
      assert(!store.dev_mode?)

      store.update_settings('wovn_dev_mode' => true)

      assert_equal(true, store.settings['wovn_dev_mode'])
      assert(store.dev_mode?)
    end

    def test_valid_user_token
      mock = LogMock.mock_log
      store = Wovnrb::Store.instance

      assert_equal(true, store.valid_token?('12345'))
    end

    def test_valid_project_token
      mock = LogMock.mock_log
      store = Wovnrb::Store.instance

      assert_equal(true, store.valid_token?('123456'))
    end

    def test_invalid_token_nil
      mock = LogMock.mock_log
      store = Wovnrb::Store.instance
      settings = { 'not_a_token' => '12345' }

      assert_equal(false, store.valid_token?(settings['token']))
    end

    def test_invalid_token_too_short
      mock = LogMock.mock_log
      store = Wovnrb::Store.instance

      assert_equal(false, store.valid_token?('hi'))
    end

    def test_invalid_token_too_long
      mock = LogMock.mock_log
      store = Wovnrb::Store.instance

      assert_equal(false, store.valid_token?('1234567'))
    end

    def test_add_custom_lang_aliases_empty
      s = Wovnrb::Store.instance
      s.update_settings('custom_lang_aliases' => {})

      assert_equal({}, s.settings['custom_lang_aliases'])
    end

    def test_add_custom_lang_aliases_single_value
      s = Wovnrb::Store.instance
      s.update_settings('custom_lang_aliases' => { 'ja' => 'staging-ja' })

      assert_equal({ 'ja' => 'staging-ja' }, s.settings['custom_lang_aliases'])
    end

    def test_add_custom_lang_aliases_multiple_values
      s = Wovnrb::Store.instance
      s.update_settings('custom_lang_aliases' => { 'ja' => 'staging-ja', 'en' => 'staging-en' })

      assert_equal({ 'ja' => 'staging-ja', 'en' => 'staging-en' }, s.settings['custom_lang_aliases'])
    end

    def test_add_custom_lang_aliases_using_symbols
      s = Wovnrb::Store.instance
      s.update_settings('custom_lang_aliases' => { ja: 'staging-ja', en: 'staging-en' })

      assert_equal({ 'ja' => 'staging-ja', 'en' => 'staging-en' }, s.settings['custom_lang_aliases'])
    end
  end
end
