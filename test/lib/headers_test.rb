require 'test_helper'

module Wovnrb
  class HeadersTest < WovnMiniTest
    def utility_universal_assertion(env_opt, setting_opt, expected, msg)
      settings = Wovnrb.get_settings(setting_opt)
      store = Wovnrb.get_store(settings)
      url_lang_switcher = UrlLanguageSwitcher.new(store)
      header = Wovnrb::Headers.new(Wovnrb.get_env(env_opt), settings, url_lang_switcher)

      expected.each do |param, expected_value|
        if expected_value.instance_of?(Hash)
          expected_value.each do |arguments_to_call_with, expected_result|
            assert_equal(expected_result, header.send(param, *arguments_to_call_with), msg)
          end
        else
          assert_equal(expected_value, header.send(param), msg)
        end
      end
    end

    def test_initialize
      settings = Wovnrb.get_settings({})
      store = Wovnrb.get_store(settings)
      url_lang_switcher = UrlLanguageSwitcher.new(store)
      h = Wovnrb::Headers.new(Wovnrb.get_env, settings, url_lang_switcher)
      refute_nil(h)
    end

    URL_TEST_CASES = [
      {
        'env' => { 'url' => 'https://wovn.io' },
        'setting' => {},
        'name' => 'test_initialize_with_simple_url',
        'expected' => {
          'url' => 'wovn.io/'
        }
      },
      {
        'env' => { 'url' => 'https://wovn.io/?wovn=en' },
        'setting' => { 'url_pattern' => 'query' },
        'name' => 'test_initialize_with_query_language',
        'expected' => {
          'url' => 'wovn.io/?'
        }
      },
      {
        'env' => { 'url' => 'https://wovn.io?wovn=en' },
        'setting' => { 'url_pattern' => 'query' },
        'name' => 'test_initialize_with_query_language_without_slash',
        'expected' => {
          'url' => 'wovn.io/?'
        }
      },
      {
        'env' => { 'url' => 'https://wovn.io/en' },
        'setting' => { 'url_pattern' => 'path' },
        'name' => 'test_initialize_with_path_language',
        'expected' => {
          'url' => 'wovn.io/'
        }
      },
      {
        'env' => { 'url' => 'https://en.wovn.io/' },
        'setting' => { 'url_pattern' => 'subdomain' },
        'name' => 'test_initialize_with_domain_language',
        'expected' => {
          'url' => 'wovn.io/'
        }
      },
      {
        'env' => { 'url' => 'https://wovn.io/en/?wovn=zh-CHS' },
        'setting' => { 'url_pattern' => 'path' },
        'name' => 'test_initialize_with_path_language_with_query',
        'expected' => {
          'url' => 'wovn.io/?wovn=zh-CHS'
        }
      },
      {
        'env' => { 'url' => 'https://en.wovn.io/?wovn=zh-CHS' },
        'setting' => { 'url_pattern' => 'subdomain' },
        'name' => 'test_initialize_with_domain_language_with_query',
        'expected' => {
          'url' => 'wovn.io/?wovn=zh-CHS'
        }
      },
      {
        'env' => { 'url' => 'https://wovn.io/en?wovn=zh-CHS' },
        'setting' => { 'url_pattern' => 'path' },
        'name' => 'test_initialize_with_path_language_with_query_without_slash',
        'expected' => {
          'url' => 'wovn.io/?wovn=zh-CHS'
        }
      }
    ].freeze

    def test_header_url
      URL_TEST_CASES.each do |test_case|
        utility_universal_assertion(test_case['env'], test_case['setting'], test_case['expected'], test_case['name'])
      end
    end

    USE_PROXY_TEST_CASES = [
      {
        'env' => { 'url' => 'http://localhost/contact', 'HTTP_X_FORWARDED_HOST' => 'wovn.io' },
        'setting' => { 'url_pattern' => 'path' },
        'name' => 'test_initialize_with_use_proxy_false',
        'expected' => {
          'url' => 'localhost/contact',
          'host' => 'localhost',
          'unmasked_host' => 'localhost'
        }
      }
    ].freeze

    def test_use_proxy
      USE_PROXY_TEST_CASES.each do |test_case|
        utility_universal_assertion(test_case['env'], test_case['setting'], test_case['expected'], test_case['name'])
      end
    end

    def test_initialize_with_use_proxy_true
      settings = Wovnrb.get_settings({ 'use_proxy' => true })
      store = Wovnrb.get_store(settings)
      url_lang_switcher = UrlLanguageSwitcher.new(store)
      env = Wovnrb.get_env({ 'url' => 'http://localhost/contact', 'HTTP_X_FORWARDED_HOST' => 'wovn.io' })
      header = Wovnrb::Headers.new(env, settings, url_lang_switcher)
      assert_equal('wovn.io/contact', header.url)
      assert_equal('wovn.io', header.host)
      assert_equal('wovn.io', header.unmasked_host)
      assert_equal('localhost', env['HTTP_HOST'])
      assert_equal('localhost', env['SERVER_NAME'])
    end

    def test_initialize_with_proto_header
      settings = Wovnrb.get_settings({ 'query' => ['aaa'] })
      store = Wovnrb.get_store(settings)
      url_lang_switcher = UrlLanguageSwitcher.new(store)
      env = Wovnrb.get_env({ 'url' => 'http://page.com', 'HTTP_X_FORWARDED_PROTO' => 'https' })
      header = Wovnrb::Headers.new(env, settings, url_lang_switcher)
      assert_equal('https', header.protocol)
    end

    def utility_assert_pathname_with_trailing_slash_if_present(env_opt, setting_opt, expected_pathname, msg)
      settings = Wovnrb.get_settings(setting_opt)
      store = Wovnrb.get_store(settings)
      url_lang_switcher = UrlLanguageSwitcher.new(store)
      header = Wovnrb::Headers.new(Wovnrb.get_env(env_opt), settings, url_lang_switcher)
      assert_equal(expected_pathname, header.pathname_with_trailing_slash_if_present, msg)
    end

    PATH_NAME_WITH_TRAILING_SLASH_TEST_CASES = [
      {
        'env' => { 'REQUEST_URI' => 'http://page.com/test' },
        'setting' => { 'url_pattern' => 'path' },
        'name' => 'test_pathname_with_trailing_slash_if_present_when_trailing_slash_is_not_present',
        'expected' => {
          'pathname_with_trailing_slash_if_present' => '/test'
        }
      },
      {
        'env' => { 'REQUEST_URI' => 'http://page.com/test/' },
        'setting' => { 'url_pattern' => 'path' },
        'name' => 'test_pathname_with_trailing_slash_if_present_with_default_lang_when_trailing_slash_is_present',
        'expected' => {
          'pathname_with_trailing_slash_if_present' => '/test/'
        }
      },
      {
        'env' => { 'REQUEST_URI' => 'http://ja.page.com/test/' },
        'setting' => { 'url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+)\.' },
        'name' => 'test_pathname_with_trailing_slash_if_present_with_subdomain_lang_when_trailing_slash_is_present',
        'expected' => {
          'pathname_with_trailing_slash_if_present' => '/test/'
        }
      },
      {
        'env' => { 'REQUEST_URI' => 'http://page.com/ja/test/' },
        'setting' => { 'url_pattern' => 'path', 'url_pattern_reg' => '/(?<lang>[^/.?]+)' },
        'name' => 'test_pathname_with_trailing_slash_if_present_with_path_lang_when_trailing_slash_is_present',
        'expected' => {
          'pathname_with_trailing_slash_if_present' => '/test/'
        }
      },
      {
        'env' => { 'REQUEST_URI' => 'http://page.com/test/?wovn=ja' },
        'setting' => { 'url_pattern' => 'query', 'url_pattern_reg' => '((\\?.*&)|\\?)wovn=(?<lang>[^&]+)(&|$)' },
        'name' => 'test_pathname_with_trailing_slash_if_present_with_query_lang_when_trailing_slash_is_present',
        'expected' => {
          'pathname_with_trailing_slash_if_present' => '/test/'
        }
      }
    ].freeze

    def test_pathname_with_trailing_slash_if_present
      PATH_NAME_WITH_TRAILING_SLASH_TEST_CASES.each do |test_case|
        utility_universal_assertion(test_case['env'], test_case['setting'], test_case['expected'], test_case['name'])
      end
    end

    PATHNAME_TEST_CASES = [
      {
        'env' => { 'REQUEST_URI' => '/v0/download_html?url=https://wovn.io/' },
        'setting' => {},
        'name' => 'test_pathname_for_unencoded_url',
        'expected' => {
          'pathname' => '/v0/download_html',
          'pathname_with_trailing_slash_if_present' => '/v0/download_html',
          'url' => 'wovn.io/v0/download_html?url=https://wovn.io/'
        }
      },
      {
        'env' => { 'REQUEST_URI' => 'https://wovn.io/v0/download_html?url=https://wovn.io/' },
        'setting' => {},
        'name' => 'test_pathname_for_unencoded_url_with_http_scheme',
        'expected' => {
          'pathname' => '/v0/download_html',
          'pathname_with_trailing_slash_if_present' => '/v0/download_html',
          'url' => 'wovn.io/v0/download_html?url=https://wovn.io/'
        }
      }
    ].freeze

    def test_pathanme
      PATHNAME_TEST_CASES.each do |test_case|
        utility_universal_assertion(test_case['env'], test_case['setting'], test_case['expected'], test_case['name'])
      end
    end

    #########################
    # REDIRECT_LOCATION
    #########################

    REDIRECT_LOCATION_TESTS = [
      {
        'env' => { 'url' => 'http://wovn.io/contact', 'HTTP_X_FORWARDED_HOST' => 'wovn.io' },
        'setting' => { 'url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+)\.' },
        'name' => 'test_redirect_location_without_custom_lang_code',
        'expected' => {
          'redirect_location' => {
            'ja' => 'http://ja.wovn.io/contact'
          }
        }
      },
      {
        'env' => { 'url' => 'http://wovn.io/contact', 'HTTP_X_FORWARDED_HOST' => 'wovn.io' },
        'setting' => { 'url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+)\.', 'custom_lang_aliases' => { 'ja' => 'staging-ja' } },
        'name' => 'test_redirect_location_with_custom_lang_code',
        'expected' => {
          'redirect_location' => {
            'ja' => 'http://staging-ja.wovn.io/contact'
          }
        }
      },
      {
        'env' => { 'url' => 'http://wovn.io/contact', 'HTTP_X_FORWARDED_HOST' => 'wovn.io' },
        'setting' => { 'url_pattern' => 'query' },
        'name' => 'test_redirect_location_without_lang_param_name',
        'expected' => {
          'redirect_location' => {
            'ja' => 'http://wovn.io/contact?wovn=ja'
          }
        }
      },
      {
        'env' => { 'url' => 'http://wovn.io/contact', 'HTTP_X_FORWARDED_HOST' => 'wovn.io' },
        'setting' => { 'url_pattern' => 'query' },
        'name' => 'test_redirect_location_without_lang_param_name default lang, do not add lang code',
        'expected' => {
          'redirect_location' => {
            'en' => 'http://wovn.io/contact'
          }
        }
      },
      {
        'env' => { 'url' => 'http://wovn.io/contact', 'HTTP_X_FORWARDED_HOST' => 'wovn.io' },
        'setting' => { 'url_pattern' => 'query', 'lang_param_name' => 'lang' },
        'name' => 'test_redirect_location_with_lang_param_name',
        'expected' => {
          'redirect_location' => {
            'ja' => 'http://wovn.io/contact?lang=ja'
          }
        }
      }
    ].freeze

    def test_redirect_location
      REDIRECT_LOCATION_TESTS.each do |test_case|
        utility_universal_assertion(test_case['env'], test_case['setting'], test_case['expected'], test_case['name'])
      end
    end

    #########################
    # REQUEST_OUT
    #########################

    def test_request_out_with_wovn_target_lang_header_using_subdomain
      settings = Wovnrb.get_settings({
                                       'url_pattern' => 'subdomain',
                                       'url_pattern_reg' => '^(?<lang>[^.]+)\.'
                                     })
      store = Wovnrb.get_store(settings)
      env = Wovnrb.get_env({
                             'SERVER_NAME' => 'ja.wovn.io',
                             'REQUEST_URI' => '/test',
                             'HTTP_REFERER' => 'http://ja.wovn.io/test'
                           })
      url_lang_switcher = UrlLanguageSwitcher.new(store)
      header = Wovnrb::Headers.new(env, settings, url_lang_switcher)

      request_out_env = header.request_out
      assert_equal('ja', request_out_env['wovnrb.target_lang'])
    end

    def test_request_out_with_wovn_target_lang_header_using_path
      settings = Wovnrb.get_settings({})
      store = Wovnrb.get_store(settings)
      env = Wovnrb.get_env({
                             'REQUEST_URI' => '/ja/test', 'HTTP_REFERER' => 'http://wovn.io/ja/test'
                           })
      url_lang_switcher = UrlLanguageSwitcher.new(store)
      header = Wovnrb::Headers.new(env, settings, url_lang_switcher)

      request_out_env = header.request_out
      assert_equal('ja', request_out_env['wovnrb.target_lang'])
    end

    def test_request_out_with_wovn_target_lang_header_using_query
      settings = Wovnrb.get_settings({
                                       'url_pattern' => 'query',
                                       'url_pattern_reg' => '((\\?.*&)|\\?)wovn=(?<lang>[^&]+)(&|$)'
                                     })
      store = Wovnrb.get_store(settings)
      env = Wovnrb.get_env({
                             'REQUEST_URI' => 'test?wovn=ja',
                             'HTTP_REFERER' => 'http://wovn.io/test'
                           })
      url_lang_switcher = UrlLanguageSwitcher.new(store)
      header = Wovnrb::Headers.new(env, settings, url_lang_switcher)

      request_out_env = header.request_out
      assert_equal('ja', request_out_env['wovnrb.target_lang'])
    end

    def test_request_out_with_use_proxy_false
      settings = Wovnrb.get_settings({
                                       'url_pattern' => 'subdomain',
                                       'url_pattern_reg' => '^(?<lang>[^.]+)\.'
                                     })
      store = Wovnrb.get_store(settings)
      env = Wovnrb.get_env({
                             'url' => 'http://localhost/contact',
                             'HTTP_X_FORWARDED_HOST' => 'ja.wovn.io'
                           })
      url_lang_switcher = UrlLanguageSwitcher.new(store)
      header = Wovnrb::Headers.new(env, settings, url_lang_switcher)

      request_out_env = header.request_out
      assert_equal('ja.wovn.io', request_out_env['HTTP_X_FORWARDED_HOST'])
    end

    def test_request_out_with_use_proxy_true
      settings = Wovnrb.get_settings({
                                       'url_pattern' => 'subdomain',
                                       'url_pattern_reg' => '^(?<lang>[^.]+)\.',
                                       'use_proxy' => true
                                     })
      store = Wovnrb.get_store(settings)
      env = Wovnrb.get_env({
                             'url' => 'http://localhost/contact',
                             'HTTP_X_FORWARDED_HOST' => 'ja.wovn.io'
                           })
      url_lang_switcher = UrlLanguageSwitcher.new(store)
      header = Wovnrb::Headers.new(env, settings, url_lang_switcher)

      request_out_env = header.request_out
      assert_equal('wovn.io', request_out_env['HTTP_X_FORWARDED_HOST'])
    end

    def test_request_out_http_referer_subdomain
      settings = Wovnrb.get_settings({
                                       'url_pattern' => 'subdomain',
                                       'url_pattern_reg' => '^(?<lang>[^.]+)\.'
                                     })
      store = Wovnrb.get_store(settings)
      env = Wovnrb.get_env({
                             'SERVER_NAME' => 'ja.wovn.io',
                             'REQUEST_URI' => '/test',
                             'HTTP_REFERER' => 'http://ja.wovn.io/test'
                           })
      url_lang_switcher = UrlLanguageSwitcher.new(store)
      header = Wovnrb::Headers.new(env, settings, url_lang_switcher)

      request_out_env = header.request_out
      assert_equal('http://wovn.io/test', request_out_env['HTTP_REFERER'])
    end

    def test_request_out_http_referer_path
      settings = Wovnrb.get_settings({})
      store = Wovnrb.get_store(settings)
      env = Wovnrb.get_env({
                             'REQUEST_URI' => '/ja/test',
                             'HTTP_REFERER' => 'http://wovn.io/ja/test'
                           })
      url_lang_switcher = UrlLanguageSwitcher.new(store)
      header = Wovnrb::Headers.new(env, settings, url_lang_switcher)

      request_out_env = header.request_out
      assert_equal('http://wovn.io/test', request_out_env['HTTP_REFERER'])
    end

    def test_request_out_http_referer_subdomain_with_custom_lang_code
      settings = Wovnrb.get_settings({
                                       'custom_lang_aliases' => { 'ja' => 'staging-ja' },
                                       'url_pattern' => 'subdomain',
                                       'url_pattern_reg' => '^(?<lang>[^.]+)\.'
                                     })
      store = Wovnrb.get_store(settings)
      env = Wovnrb.get_env({
                             'SERVER_NAME' => 'staging-ja.wovn.io',
                             'REQUEST_URI' => '/test',
                             'HTTP_REFERER' => 'http://staging-ja.wovn.io/test'
                           })
      url_lang_switcher = UrlLanguageSwitcher.new(store)
      header = Wovnrb::Headers.new(env, settings, url_lang_switcher)

      request_out_env = header.request_out
      assert_equal('http://wovn.io/test', request_out_env['HTTP_REFERER'])
    end

    def test_request_out_custom_domain
      settings = Wovnrb.get_settings({
                                       'url_pattern' => 'custom_domain',
                                       'custom_domain_langs' => {
                                         'en' => { 'url' => 'wovn.io' },
                                         'ja' => { 'url' => 'ja.wovn.io' }
                                       }
                                     })
      store = Wovnrb.get_store(settings)
      env = Wovnrb.get_env({
                             'HTTP_REFERER' => 'ja.wovn.io',
                             'SERVER_NAME' => 'ja.wovn.io',
                             'REQUEST_URI' => '/dummy'
                           })
      url_lang_switcher = UrlLanguageSwitcher.new(store)
      header = Wovnrb::Headers.new(env, settings, url_lang_switcher)

      request_out_env = header.request_out
      assert_equal('wovn.io', request_out_env['HTTP_REFERER'])
      assert_equal('wovn.io', request_out_env['SERVER_NAME'])
    end

    def test_out_should_add_lang_code_to_redirection
      settings = Wovnrb.get_settings({
                                       'default_lang' => 'en',
                                       'supported_langs' => %w[en ja],
                                       'url_pattern' => 'path',
                                       'url_pattern_reg' => '/(?<lang>[^/.?]+)'
                                     })
      store = Wovnrb.get_store(settings)
      env = Wovnrb.get_env({
                             'SERVER_NAME' => 'wovn.io',
                             'REQUEST_URI' => '/ja/test',
                             'HTTP_REFERER' => 'http://wovn.io/ja/test'
                           })
      url_lang_switcher = UrlLanguageSwitcher.new(store)
      header = Wovnrb::Headers.new(env, settings, url_lang_switcher)
      headers = {
        'Location' => 'http://wovn.io/'
      }
      assert_equal('http://wovn.io/ja/', header.out(headers)['Location'])
    end

    def test_out_should_not_add_lang_code_to_ignored_redirection
      settings = Wovnrb.get_settings({
                                       'default_lang' => 'en',
                                       'supported_langs' => %w[en ja],
                                       'url_pattern' => 'path',
                                       'url_pattern_reg' => '/(?<lang>[^/.?]+)',
                                       'ignore_paths' => ['/static/']
                                     })
      store = Wovnrb.get_store(settings)
      env = Wovnrb.get_env({
                             'SERVER_NAME' => 'wovn.io',
                             'REQUEST_URI' => '/ja/test',
                             'HTTP_REFERER' => 'http://wovn.io/ja/test'
                           })
      url_lang_switcher = UrlLanguageSwitcher.new(store)
      header = Wovnrb::Headers.new(env, settings, url_lang_switcher)
      headers = {
        'Location' => 'http://wovn.io/static/'
      }
      assert_equal('http://wovn.io/static/', header.out(headers)['Location'])
    end

    def test_out_http_referer_subdomain_with_custom_lang_code
      settings = Wovnrb.get_settings({
                                       'custom_lang_aliases' => { 'ja' => 'staging-ja' },
                                       'url_pattern' => 'subdomain',
                                       'url_pattern_reg' => '^(?<lang>[^.]+)\.'
                                     })
      store = Wovnrb.get_store(settings)
      env = Wovnrb.get_env({
                             'SERVER_NAME' => 'staging-ja.wovn.io',
                             'REQUEST_URI' => '/test',
                             'HTTP_REFERER' => 'http://staging-ja.wovn.io/test'
                           })
      url_lang_switcher = UrlLanguageSwitcher.new(store)
      header = Wovnrb::Headers.new(env, settings, url_lang_switcher)
      headers = header.request_out
      assert_equal('http://wovn.io/test', headers['HTTP_REFERER'])
      headers['Location'] = headers['HTTP_REFERER']
      assert_equal('http://staging-ja.wovn.io/test', header.out(headers)['Location'])
    end

    def test_out_original_lang_with_subdomain_url_pattern
      settings = Wovnrb.get_settings({
                                       'url_pattern' => 'subdomain',
                                       'url_pattern_reg' => '^(?<lang>[^.]+)\.'
                                     })
      store = Wovnrb.get_store(settings)
      env = Wovnrb.get_env({
                             'SERVER_NAME' => 'wovn.io',
                             'REQUEST_URI' => '/test',
                             'HTTP_REFERER' => 'http://wovn.io/test'
                           })
      url_lang_switcher = UrlLanguageSwitcher.new(store)
      header = Wovnrb::Headers.new(env, settings, url_lang_switcher)
      headers = header.request_out
      assert_equal('http://wovn.io/test', headers['HTTP_REFERER'])
      headers['Location'] = headers['HTTP_REFERER']
      assert_equal('http://wovn.io/test', header.out(headers)['Location'])
    end

    def test_out_original_lang_with_path_url_pattern
      settings = Wovnrb.get_settings({
                                       'url_pattern' => 'path',
                                       'url_pattern_reg' => '/(?<lang>[^/.?]+)'
                                     })
      store = Wovnrb.get_store(settings)
      env = Wovnrb.get_env({
                             'SERVER_NAME' => 'wovn.io',
                             'REQUEST_URI' => '/test',
                             'HTTP_REFERER' => 'http://wovn.io/test'
                           })
      url_lang_switcher = UrlLanguageSwitcher.new(store)
      header = Wovnrb::Headers.new(env, settings, url_lang_switcher)
      headers = header.request_out
      assert_equal('http://wovn.io/test', headers['HTTP_REFERER'])
      headers['Location'] = headers['HTTP_REFERER']
      assert_equal('http://wovn.io/test', header.out(headers)['Location'])
    end

    def test_out_original_lang_with_query_url_pattern
      settings = Wovnrb.get_settings({
                                       'url_pattern' => 'query',
                                       'url_pattern_reg' => '((\\?.*&)|\\?)wovn=(?<lang>[^&]+)(&|$)'
                                     })
      store = Wovnrb.get_store(settings)
      env = Wovnrb.get_env({
                             'SERVER_NAME' => 'wovn.io',
                             'REQUEST_URI' => '/test',
                             'HTTP_REFERER' => 'http://wovn.io/test'
                           })
      url_lang_switcher = UrlLanguageSwitcher.new(store)
      header = Wovnrb::Headers.new(env, settings, url_lang_switcher)
      headers = header.request_out
      assert_equal('http://wovn.io/test', headers['HTTP_REFERER'])
      headers['Location'] = headers['HTTP_REFERER']
      assert_equal('http://wovn.io/test', header.out(headers)['Location'])
    end

    def test_out_with_wovn_target_lang_header_using_subdomain
      settings = Wovnrb.get_settings({
                                       'url_pattern' => 'subdomain',
                                       'url_pattern_reg' => '^(?<lang>[^.]+)\.'
                                     })
      store = Wovnrb.get_store(settings)
      env = Wovnrb.get_env({
                             'SERVER_NAME' => 'ja.wovn.io',
                             'REQUEST_URI' => '/test',
                             'HTTP_REFERER' => 'http://ja.wovn.io/test'
                           })
      url_lang_switcher = UrlLanguageSwitcher.new(store)
      header = Wovnrb::Headers.new(env, settings, url_lang_switcher)
      headers = header.out(header.request_out)
      assert_equal('ja', headers['wovnrb.target_lang'])
    end

    def test_out_with_wovn_target_lang_header_using_path
      settings = Wovnrb.get_settings({})
      store = Wovnrb.get_store(settings)
      env = Wovnrb.get_env({
                             'REQUEST_URI' => '/ja/test',
                             'HTTP_REFERER' => 'http://wovn.io/ja/test'
                           })
      url_lang_switcher = UrlLanguageSwitcher.new(store)
      header = Wovnrb::Headers.new(env, settings, url_lang_switcher)
      headers = header.out(header.request_out)
      assert_equal('ja', headers['wovnrb.target_lang'])
    end

    def test_out_with_wovn_target_lang_header_using_query
      settings = Wovnrb.get_settings({
                                       'url_pattern' => 'query',
                                       'url_pattern_reg' => '((\\?.*&)|\\?)wovn=(?<lang>[^&]+)(&|$)'
                                     })
      store = Wovnrb.get_store(settings)
      env = Wovnrb.get_env({
                             'REQUEST_URI' => 'test?wovn=ja',
                             'HTTP_REFERER' => 'http://wovn.io/test'
                           })
      url_lang_switcher = UrlLanguageSwitcher.new(store)
      header = Wovnrb::Headers.new(env, settings, url_lang_switcher)
      headers = header.out(header.request_out)
      assert_equal('ja', headers['wovnrb.target_lang'])
    end

    def test_out_with_wovn_target_lang_header_using_query_with_lang_param_name
      settings = Wovnrb.get_settings({
                                       'url_pattern' => 'query',
                                       'lang_param_name' => 'lang',
                                       'url_pattern_reg' => '((\\?.*&)|\\?)lang=(?<lang>[^&]+)(&|$)'
                                     })
      store = Wovnrb.get_store(settings)
      env = Wovnrb.get_env({
                             'REQUEST_URI' => 'test?lang=ja',
                             'HTTP_REFERER' => 'http://wovn.io/test'
                           })
      url_lang_switcher = UrlLanguageSwitcher.new(store)
      header = Wovnrb::Headers.new(env, settings, url_lang_switcher)
      headers = header.out(header.request_out)
      assert_equal('ja', headers['wovnrb.target_lang'])
    end

    def test_out_with_custom_domain
      settings = Wovnrb.get_settings({
                                       'default_lang' => 'en',
                                       'url_pattern' => 'custom_domain',
                                       'custom_domain_langs' => {
                                         'en' => { 'url' => 'wovn.io' },
                                         'ja' => { 'url' => 'wovn.io/ja' }
                                       }
                                     })
      store = Wovnrb.get_store(settings)
      env = Wovnrb.get_env({
                             'SERVER_NAME' => 'wovn.io',
                             'REQUEST_URI' => '/ja/test',
                             'HTTP_REFERER' => 'http://wovn.io/ja/test'
                           })
      url_lang_switcher = UrlLanguageSwitcher.new(store)
      header = Wovnrb::Headers.new(env, settings, url_lang_switcher)
      headers = {
        'Location' => 'http://wovn.io/'
      }
      assert_equal('http://wovn.io/ja/', header.out(headers)['Location'])
    end

    def test_out_with_custom_domain__absolute_url_redirect
      settings = Wovnrb.get_settings({
                                       'default_lang' => 'en',
                                       'url_pattern' => 'custom_domain',
                                       'custom_domain_langs' => {
                                         'en' => { 'url' => 'wovn.io' },
                                         'ja' => { 'url' => 'wovn.io/ja' }
                                       }
                                     })
      store = Wovnrb.get_store(settings)
      env = Wovnrb.get_env({
                             'SERVER_NAME' => 'wovn.io',
                             'REQUEST_URI' => '/ja/test',
                             'HTTP_REFERER' => 'http://wovn.io/ja/test'
                           })
      url_lang_switcher = UrlLanguageSwitcher.new(store)
      header = Wovnrb::Headers.new(env, settings, url_lang_switcher)
      headers = {
        'Location' => 'http://wovn.io/foo'
      }
      assert_equal('http://wovn.io/ja/foo', header.out(headers)['Location'])
    end

    def test_out_with_custom_domain__absolute_path_redirect
      settings = Wovnrb.get_settings({
                                       'default_lang' => 'en',
                                       'url_pattern' => 'custom_domain',
                                       'custom_domain_langs' => {
                                         'en' => { 'url' => 'wovn.io' },
                                         'ja' => { 'url' => 'wovn.io/ja' }
                                       }
                                     })
      store = Wovnrb.get_store(settings)
      env = Wovnrb.get_env({
                             'SERVER_NAME' => 'wovn.io',
                             'REQUEST_URI' => '/ja/test',
                             'HTTP_REFERER' => 'http://wovn.io/ja/test'
                           })
      url_lang_switcher = UrlLanguageSwitcher.new(store)
      header = Wovnrb::Headers.new(env, settings, url_lang_switcher)
      headers = {
        'Location' => '/foo'
      }
      assert_equal('http://wovn.io/ja/foo', header.out(headers)['Location'])
    end

    def test_out_with_custom_domain__relative_url_redirect
      settings = Wovnrb.get_settings({
                                       'default_lang' => 'en',
                                       'url_pattern' => 'custom_domain',
                                       'custom_domain_langs' => {
                                         'en' => { 'url' => 'wovn.io' },
                                         'ja' => { 'url' => 'wovn.io/ja' }
                                       }
                                     })
      store = Wovnrb.get_store(settings)
      env = Wovnrb.get_env({
                             'SERVER_NAME' => 'wovn.io',
                             'REQUEST_URI' => '/ja/test',
                             'HTTP_REFERER' => 'http://wovn.io/ja/test'
                           })
      url_lang_switcher = UrlLanguageSwitcher.new(store)
      header = Wovnrb::Headers.new(env, settings, url_lang_switcher)
      headers = {
        'Location' => 'foo/page.html'
      }
      assert_equal('http://wovn.io/ja/foo/page.html', header.out(headers)['Location'])
    end

    def test_get_settings_valid
      # TODO: check if Wovnrb.get_settings is valid (store.rb, valid_settings)
      # s = Wovnrb::Store.new
      # settings = Wovnrb.get_settings

      # settings_stub = stub
      # settings_stub.expects(:has_key).with(:user_token).returns(settings["user_token"])
      # s.valid_settings?
    end

    def test_lang_detection_subdomain
      sub_domains = { '' => '', 'ar' => 'ar', 'AR' => 'ar', 'zh-CHS' => 'zh-CHS', 'ZH-CHS' => 'zh-CHS', 'zh-chs' => 'zh-CHS' }
      sub_domains.each do |subdomain, lang|
        name = "test path lang subdomain #{lang}"
        env = { 'url' => "https://#{subdomain}.wovn.io" }
        settings = { 'url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+)\.' }
        utility_universal_assertion(env, settings, { 'path_lang' => lang }, name)

        name = "test path lang subdomain #{lang} with slash"
        env = { 'url' => "https://#{subdomain}.wovn.io/" }
        settings = { 'url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+)\.' }
        utility_universal_assertion(env, settings, { 'path_lang' => lang }, name)

        name = "test path lang subdomain #{lang} with port"
        env = { 'url' => "https://#{subdomain}.wovn.io:1234" }
        settings = { 'url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+)\.' }
        utility_universal_assertion(env, settings, { 'path_lang' => lang }, name)

        name = "test path lang subdomain #{lang} with slash and port"
        env = { 'url' => "https://#{subdomain}.wovn.io:1234/" }
        settings = { 'url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+)\.' }
        utility_universal_assertion(env, settings, { 'path_lang' => lang }, name)

        name = "test path lang subdomain #{lang} insecure"
        env = { 'url' => "http://#{subdomain}.wovn.io" }
        settings = { 'url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+)\.' }
        utility_universal_assertion(env, settings, { 'path_lang' => lang }, name)

        name = "test path lang subdomain #{lang} insecure with slash"
        env = { 'url' => "http://#{subdomain}.wovn.io/" }
        settings = { 'url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+)\.' }
        utility_universal_assertion(env, settings, { 'path_lang' => lang }, name)

        name = "test path lang subdomain #{lang} insecure with port"
        env = { 'url' => "http://#{subdomain}.wovn.io:1234" }
        settings = { 'url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+)\.' }
        utility_universal_assertion(env, settings, { 'path_lang' => lang }, name)

        name = "test path lang subdomain #{lang} insecure with port and slash"
        env = { 'url' => "http://#{subdomain}.wovn.io:1234/" }
        settings = { 'url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+)\.' }
        utility_universal_assertion(env, settings, { 'path_lang' => lang }, name)
      end
    end

    def test_lang_detection_query
      sub_domains = { '' => '', 'ar' => 'ar', 'AR' => 'ar', 'zh-CHS' => 'zh-CHS', 'ZH-CHS' => 'zh-CHS', 'zh-chs' => 'zh-CHS' }
      sub_domains.each do |query, lang|
        name = "test path lang query #{lang}"
        env = { 'url' => "https://wovn.io?wovn=#{query}" }
        settings = { 'url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)' }
        utility_universal_assertion(env, settings, { 'path_lang' => lang }, name)

        name = "test path lang query #{lang} with slash"
        env = { 'url' => "https://wovn.io/?wovn=#{query}" }
        settings = { 'url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)' }
        utility_universal_assertion(env, settings, { 'path_lang' => lang }, name)

        name = "test path lang query #{lang} with port"
        env = { 'url' => "https://wovn.io:1234?wovn=#{query}" }
        settings = { 'url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)' }
        utility_universal_assertion(env, settings, { 'path_lang' => lang }, name)

        name = "test path lang query #{lang} with port and slash"
        env = { 'url' => "https://wovn.io:1234/?wovn=#{query}" }
        settings = { 'url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)' }
        utility_universal_assertion(env, settings, { 'path_lang' => lang }, name)

        name = "test path lang query #{lang} insecure"
        env = { 'url' => "http://wovn.io?wovn=#{query}" }
        settings = { 'url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)' }
        utility_universal_assertion(env, settings, { 'path_lang' => lang }, name)

        name = "test path lang query #{lang} with slash insecure"
        env = { 'url' => "http://wovn.io/?wovn=#{query}" }
        settings = { 'url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)' }
        utility_universal_assertion(env, settings, { 'path_lang' => lang }, name)

        name = "test path lang query #{lang} with port insecure"
        env = { 'url' => "http://wovn.io:1234?wovn=#{query}" }
        settings = { 'url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)' }
        utility_universal_assertion(env, settings, { 'path_lang' => lang }, name)

        name = "test path lang query #{lang} with port and slash insecure"
        env = { 'url' => "http://wovn.io:1234/?wovn=#{query}" }
        settings = { 'url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)' }
        utility_universal_assertion(env, settings, { 'path_lang' => lang }, name)
      end
    end

    def test_lang_detection_path
      sub_domains = { '' => '', 'ar' => 'ar', 'AR' => 'ar', 'zh-CHS' => 'zh-CHS', 'ZH-CHS' => 'zh-CHS', 'zh-chs' => 'zh-CHS' }
      sub_domains.each do |query, lang|
        name = "test path lang path #{lang}"
        env = { 'url' => "https://wovn.io/#{query}" }
        settings = { 'url_pattern' => 'path' }
        utility_universal_assertion(env, settings, { 'path_lang' => lang }, name)

        name = "test path lang path #{lang} with slash"
        env = { 'url' => "https://wovn.io/#{query}/" }
        settings = { 'url_pattern' => 'path' }
        utility_universal_assertion(env, settings, { 'path_lang' => lang }, name)

        name = "test path lang path #{lang} with port"
        env = { 'url' => "https://wovn.io:1234/#{query}" }
        settings = { 'url_pattern' => 'path' }
        utility_universal_assertion(env, settings, { 'path_lang' => lang }, name)

        name = "test path lang path #{lang} with port and slash"
        env = { 'url' => "https://wovn.io:1234/#{query}/" }
        settings = { 'url_pattern' => 'path' }
        utility_universal_assertion(env, settings, { 'path_lang' => lang }, name)

        name = "test path lang path #{lang} insecure"
        env = { 'url' => "http://wovn.io/#{query}" }
        settings = { 'url_pattern' => 'path' }
        utility_universal_assertion(env, settings, { 'path_lang' => lang }, name)

        name = "test path lang path #{lang} with slash insecure"
        env = { 'url' => "http://wovn.io/#{query}/" }
        settings = { 'url_pattern' => 'path' }
        utility_universal_assertion(env, settings, { 'path_lang' => lang }, name)

        name = "test path lang path #{lang} with port insecure"
        env = { 'url' => "http://wovn.io:1234/#{query}" }
        settings = { 'url_pattern' => 'path' }
        utility_universal_assertion(env, settings, { 'path_lang' => lang }, name)

        name = "test path lang path #{lang} with port and slash insecure"
        env = { 'url' => "http://wovn.io:1234/#{query}/" }
        settings = { 'url_pattern' => 'path' }
        utility_universal_assertion(env, settings, { 'path_lang' => lang }, name)
      end
    end

    def test_path_lang_sudomain_with_use_proxy_false
      settings = Wovnrb.get_settings({
                                       'url_pattern' => 'subdomain',
                                       'url_pattern_reg' => '^(?<lang>[^.]+)\.'
                                     })
      store = Wovnrb.get_store(settings)
      env = Wovnrb.get_env({
                             'url' => 'http://localhost:1234/test',
                             'HTTP_X_FORWARDED_HOST' => 'zh-cht.wovn.io'
                           })
      url_lang_switcher = UrlLanguageSwitcher.new(store)
      header = Wovnrb::Headers.new(env, settings, url_lang_switcher)
      assert_equal('', header.path_lang)
    end

    def test_path_lang_sudomain_with_use_proxy_true
      settings = Wovnrb.get_settings({
                                       'url_pattern' => 'subdomain',
                                       'url_pattern_reg' => '^(?<lang>[^.]+)\.',
                                       'use_proxy' => true
                                     })
      store = Wovnrb.get_store(settings)
      env = Wovnrb.get_env({
                             'url' => 'http://localhost:1234/test',
                             'HTTP_X_FORWARDED_HOST' => 'zh-cht.wovn.io'
                           })
      url_lang_switcher = UrlLanguageSwitcher.new(store)
      header = Wovnrb::Headers.new(env, settings, url_lang_switcher)
      assert_equal('zh-CHT', header.path_lang)
    end

    def test_path_lang_with_custom_domain
      custom_domain_langs = {
        'en' => { 'url' => 'my-site.com' },
        'en-US' => { 'url' => 'en-us.my-site.com' },
        'ja' => { 'url' => 'my-site.com/ja' },
        'zh-CHS' => { 'url' => 'my-site.com/zh/chs' },
        'zh-Hant-HK' => { 'url' => 'zh-hant-hk.com/zh' }
      }
      settings = {
        'url_pattern' => 'custom_domain',
        'custom_domain_langs' => custom_domain_langs
      }
      test_cases = [
        [{ 'SERVER_NAME' => 'my-site.com', 'REQUEST_URI' => '/' }, 'en'],
        [{ 'SERVER_NAME' => 'en-us.my-site.com', 'REQUEST_URI' => '/' }, 'en-US'],
        [{ 'SERVER_NAME' => 'my-site.com', 'REQUEST_URI' => '/ja' }, 'ja'],
        [{ 'SERVER_NAME' => 'my-site.com', 'REQUEST_URI' => '/zh/chs' }, 'zh-CHS'],
        [{ 'SERVER_NAME' => 'zh-hant-hk.com', 'REQUEST_URI' => '/zh' }, 'zh-Hant-HK'],

        # request uri pattern
        [{ 'SERVER_NAME' => 'zh-hant-hk.com', 'REQUEST_URI' => '/zh' }, 'zh-Hant-HK'],
        [{ 'SERVER_NAME' => 'zh-hant-hk.com', 'REQUEST_URI' => '/zh/' }, 'zh-Hant-HK'],
        [{ 'SERVER_NAME' => 'zh-hant-hk.com', 'REQUEST_URI' => '/zh/index.html' }, 'zh-Hant-HK'],
        [{ 'SERVER_NAME' => 'zh-hant-hk.com', 'REQUEST_URI' => '/zh/dir' }, 'zh-Hant-HK'],
        [{ 'SERVER_NAME' => 'zh-hant-hk.com', 'REQUEST_URI' => '/zh/dir/' }, 'zh-Hant-HK'],
        [{ 'SERVER_NAME' => 'zh-hant-hk.com', 'REQUEST_URI' => '/zh/dir/index.html' }, 'zh-Hant-HK'],
        [{ 'SERVER_NAME' => 'zh-hant-hk.com', 'REQUEST_URI' => '/zh?query=1' }, 'zh-Hant-HK'],
        [{ 'SERVER_NAME' => 'zh-hant-hk.com', 'REQUEST_URI' => '/zh#hash' }, 'zh-Hant-HK'],

        # should be default lang
        [{ 'SERVER_NAME' => 'my-site.com', 'REQUEST_URI' => '/japan' }, 'en'],
        [{ 'SERVER_NAME' => 'my-site.com', 'REQUEST_URI' => '/' }, 'en'],
        [{ 'SERVER_NAME' => 'zh-hant-hk.com', 'REQUEST_URI' => '/' }, '']
      ]

      test_cases.each do |test_case|
        env_hash, expected_lang_code = test_case
        settings = Wovnrb.get_settings(settings)
        store = Wovnrb.get_store(settings)
        env = Wovnrb.get_env(env_hash)
        url_lang_switcher = UrlLanguageSwitcher.new(store)
        header = Wovnrb::Headers.new(env, settings, url_lang_switcher)

        assert_equal(expected_lang_code, header.path_lang)
      end
    end
  end
end
