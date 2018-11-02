require 'test_helper'

module Wovnrb
  class LangTest < WovnMiniTest

    #########################
    # INITIALIZE
    #########################

    def test_initialize
      h = Wovnrb::Headers.new(Wovnrb.get_env, Wovnrb.get_settings)
      refute_nil(h)
    end

    # def test_initialize_env
    #   env = Wovnrb.get_env
    #   h = Wovnrb::Headers.new(env, {})
    #   binding.pry
    #   #assert_equal(''
    # end

    def test_initialize_with_simple_url
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io'), Wovnrb.get_settings)
      assert_equal('wovn.io/', h.url)
    end

    def test_initialize_with_query_language
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/?wovn=en'), Wovnrb.get_settings('url_pattern' => 'query'))
      assert_equal('wovn.io/?', h.url)
    end

    def test_initialize_with_query_language_without_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io?wovn=en'), Wovnrb.get_settings('url_pattern' => 'query'))
      assert_equal('wovn.io/?', h.url)
    end

    def test_initialize_with_path_language
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/en'), Wovnrb.get_settings)
      assert_equal('wovn.io/', h.url)
    end

    def test_initialize_with_domain_language
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://en.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain'))
      assert_equal('wovn.io/', h.url)
    end

    def test_initialize_with_path_language_with_query
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/en/?wovn=zh-CHS'), Wovnrb.get_settings)
      assert_equal('wovn.io/?wovn=zh-CHS', h.url)
    end

    def test_initialize_with_domain_language_with_query
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://en.wovn.io/?wovn=zh-CHS'), Wovnrb.get_settings('url_pattern' => 'subdomain'))
      assert_equal('wovn.io/?wovn=zh-CHS', h.url)
    end

    def test_initialize_with_path_language_with_query_without_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/en?wovn=zh-CHS'), Wovnrb.get_settings)
      assert_equal('wovn.io/?wovn=zh-CHS', h.url)
    end

    def test_initialize_with_domain_language_with_query_without_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://en.wovn.io?wovn=zh-CHS'), Wovnrb.get_settings('url_pattern' => 'subdomain'))
      assert_equal('wovn.io/?wovn=zh-CHS', h.url)
    end

    def test_initialize_with_use_proxy_false
      env = Wovnrb.get_env('url' => 'http://localhost/contact', 'HTTP_X_FORWARDED_HOST' => 'wovn.io')
      h = Wovnrb::Headers.new(env, Wovnrb.get_settings)
      assert_equal('localhost/contact', h.url)
      assert_equal('localhost', h.host)
      assert_equal('localhost', h.unmasked_host)
    end

    def test_initialize_with_use_proxy_true
      env = Wovnrb.get_env('url' => 'http://localhost/contact', 'HTTP_X_FORWARDED_HOST' => 'wovn.io')
      h = Wovnrb::Headers.new(env, Wovnrb.get_settings('use_proxy' => true))
      assert_equal('wovn.io/contact', h.url)
      assert_equal('wovn.io', h.host)
      assert_equal('wovn.io', h.unmasked_host)
      assert_equal('localhost', env['HTTP_HOST'])
      assert_equal('localhost', env['SERVER_NAME'])
    end

    def test_initialize_without_query
      env = Wovnrb.get_env
      h = Wovnrb::Headers.new(env, Wovnrb.get_settings)
      assert_equal('wovn.io/dashboard', h.redis_url)
    end

    def test_initialize_with_query
      env = Wovnrb.get_env
      h = Wovnrb::Headers.new(env, Wovnrb.get_settings('query' => ['param']))
      assert_equal('wovn.io/dashboard?param=val', h.redis_url)
    end

    def test_initialize_with_not_matching_query
      env = Wovnrb.get_env
      h = Wovnrb::Headers.new(env, Wovnrb.get_settings('query' => ['aaa']))
      assert_equal('wovn.io/dashboard', h.redis_url)
    end

    def test_initialize_with_proto_header
      env = Wovnrb.get_env('url' => 'http://page.com', 'HTTP_X_FORWARDED_PROTO' => 'https')
      h = Wovnrb::Headers.new(env, Wovnrb.get_settings('query' => ['aaa']))
      assert_equal('https', h.protocol)
    end

    def test_pathname_with_trailing_slash_if_present_when_trailing_slash_is_not_present
      env = Wovnrb.get_env('REQUEST_URI' => 'http://page.com/test')
      headers = Wovnrb::Headers.new(env, Wovnrb.get_settings())

      assert_equal('/test', headers.pathname_with_trailing_slash_if_present)
    end

    def test_pathname_with_trailing_slash_if_present_with_default_lang_when_trailing_slash_is_present
      env = Wovnrb.get_env('REQUEST_URI' => 'http://page.com/test/')
      headers = Wovnrb::Headers.new(env, Wovnrb.get_settings())

      assert_equal('/test/', headers.pathname_with_trailing_slash_if_present)
    end

    def test_pathname_with_trailing_slash_if_present_with_subdomain_lang_when_trailing_slash_is_present
      headers = Wovnrb::Headers.new(
        Wovnrb.get_env('REQUEST_URI' => 'http://ja.page.com/test/'),
        Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).')
      )

      assert_equal('/test/', headers.pathname_with_trailing_slash_if_present)
    end

    def test_pathname_with_trailing_slash_if_present_with_path_lang_when_trailing_slash_is_present
      headers = Wovnrb::Headers.new(
        Wovnrb.get_env('REQUEST_URI' => 'http://page.com/ja/test/'),
        Wovnrb.get_settings('url_pattern' => 'path', 'url_pattern_reg' => '/(?<lang>[^/.?]+)')
      )

      assert_equal('/test/', headers.pathname_with_trailing_slash_if_present)
    end

    def test_pathname_with_trailing_slash_if_present_with_query_lang_when_trailing_slash_is_present
      headers = Wovnrb::Headers.new(
        Wovnrb.get_env('REQUEST_URI' => 'http://page.com/test/?wovn=ja'),
        Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\\?.*&)|\\?)wovn=(?<lang>[^&]+)(&|$)')
      )

      assert_equal('/test/', headers.pathname_with_trailing_slash_if_present)
    end

    #########################
    # REDIRECT_LOCATION
    #########################

    def test_redirect_location_without_custom_lang_code
      h = Wovnrb::Headers.new(
        Wovnrb.get_env('url' => 'http://wovn.io/contact', 'HTTP_X_FORWARDED_HOST' => 'wovn.io'),
        Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'),
      )
      assert_equal('http://ja.wovn.io/contact', h.redirect_location('ja'))
    end

    def test_redirect_location_without_custom_lang_code
      Store.instance.update_settings({'custom_lang_aliases' => {'ja' => 'staging-ja'}})
      h = Wovnrb::Headers.new(
        Wovnrb.get_env('url' => 'http://wovn.io/contact', 'HTTP_X_FORWARDED_HOST' => 'wovn.io'),
        Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'),
      )
      assert_equal('http://staging-ja.wovn.io/contact', h.redirect_location('ja'))
    end

    #########################
    # REQUEST_OUT
    #########################

    def test_request_out_with_wovn_target_lang_header_using_subdomain
      h = Wovnrb::Headers.new(
        Wovnrb.get_env(
          'SERVER_NAME' => 'ja.wovn.io',
          'REQUEST_URI' => '/test',
          'HTTP_REFERER' => 'http://ja.wovn.io/test',
        ),
        Wovnrb.get_settings(
          'url_pattern' => 'subdomain',
          'url_pattern_reg' => '^(?<lang>[^.]+).',
        ),
      )
      env = h.request_out('ja')
      assert_equal('ja', env['wovnrb.target_lang'])
    end

    def test_request_out_with_wovn_target_lang_header_using_path
      h = Wovnrb::Headers.new(
        Wovnrb.get_env('REQUEST_URI' => '/ja/test', 'HTTP_REFERER' => 'http://wovn.io/ja/test'),
        Wovnrb.get_settings,
      )
      env = h.request_out('ja')
      assert_equal('ja', env['wovnrb.target_lang'])
    end

    def test_request_out_with_wovn_target_lang_header_using_query
      h = Wovnrb::Headers.new(
        Wovnrb.get_env('REQUEST_URI' => 'test?wovn=ja', 'HTTP_REFERER' => 'http://wovn.io/test'),
        Wovnrb.get_settings(
          'url_pattern' => 'query',
          'url_pattern_reg' => "((\\?.*&)|\\?)wovn=(?<lang>[^&]+)(&|$)",
        ),
      )
      env = h.request_out('ja')
      assert_equal('ja', env['wovnrb.target_lang'])
    end

    def test_request_out_with_use_proxy_false
      h = Wovnrb::Headers.new(
        Wovnrb.get_env('url' => 'http://localhost/contact', 'HTTP_X_FORWARDED_HOST' => 'ja.wovn.io'),
        Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'),
      )
      env = h.request_out('ja')
      assert_equal('ja.wovn.io', env['HTTP_X_FORWARDED_HOST'])
    end

    def test_request_out_with_use_proxy_true
      h = Wovnrb::Headers.new(
        Wovnrb.get_env('url' => 'http://localhost/contact', 'HTTP_X_FORWARDED_HOST' => 'ja.wovn.io'),
        Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).', 'use_proxy' => true),
      )
      env = h.request_out('ja')
      assert_equal('wovn.io', env['HTTP_X_FORWARDED_HOST'])
    end

    def test_request_out_http_referer_subdomain
      h = Wovnrb::Headers.new(
        Wovnrb.get_env(
          'SERVER_NAME' => 'ja.wovn.io',
          'REQUEST_URI' => '/test',
          'HTTP_REFERER' => 'http://ja.wovn.io/test',
        ),
        Wovnrb.get_settings(
          'url_pattern' => 'subdomain',
          'url_pattern_reg' => '^(?<lang>[^.]+).',
        ),
      )
      env = h.request_out('ja')
      assert_equal('http://wovn.io/test', env['HTTP_REFERER'])
    end

    def test_request_out_http_referer_path
      h = Wovnrb::Headers.new(
        Wovnrb.get_env('REQUEST_URI' => '/ja/test', 'HTTP_REFERER' => 'http://wovn.io/ja/test'),
        Wovnrb.get_settings,
      )
      env = h.request_out('ja')
      assert_equal('http://wovn.io/test', env['HTTP_REFERER'])
    end

    def test_request_out_http_referer_subdomain_with_custom_lang_code
      Store.instance.update_settings({'custom_lang_aliases' => {'ja' => 'staging-ja'}})
      h = Wovnrb::Headers.new(
        Wovnrb.get_env(
          'SERVER_NAME' => 'staging-ja.wovn.io',
          'REQUEST_URI' => '/test',
          'HTTP_REFERER' => 'http://staging-ja.wovn.io/test',
        ),
        Wovnrb.get_settings(
          'url_pattern' => 'subdomain',
          'url_pattern_reg' => '^(?<lang>[^.]+).',
        ),
      )
      env = h.request_out('ja')
      assert_equal('http://wovn.io/test', env['HTTP_REFERER'])
    end

    def test_out_http_referer_subdomain_with_custom_lang_code
      Store.instance.update_settings({'custom_lang_aliases' => {'ja' => 'staging-ja'}})
      h = Wovnrb::Headers.new(
        Wovnrb.get_env(
          'SERVER_NAME' => 'staging-ja.wovn.io',
          'REQUEST_URI' => '/test',
          'HTTP_REFERER' => 'http://staging-ja.wovn.io/test',
        ),
        Wovnrb.get_settings(
          'url_pattern' => 'subdomain',
          'url_pattern_reg' => '^(?<lang>[^.]+).',
        ),
      )
      headers = h.request_out('ja')
      assert_equal('http://wovn.io/test', headers['HTTP_REFERER'])
      headers['Location'] = headers['HTTP_REFERER']
      assert_equal('http://staging-ja.wovn.io/test', h.out(headers)['Location'])
    end

    def test_out_original_lang_with_subdomain_url_pattern
      h = Wovnrb::Headers.new(
        Wovnrb.get_env(
          'SERVER_NAME' => 'wovn.io',
          'REQUEST_URI' => '/test',
          'HTTP_REFERER' => 'http://wovn.io/test',
        ),
        Wovnrb.get_settings(
          'url_pattern' => 'subdomain',
          'url_pattern_reg' => '^(?<lang>[^.]+).',
        ),
      )
      headers = h.request_out(h.lang_code)
      assert_equal('http://wovn.io/test', headers['HTTP_REFERER'])
      headers['Location'] = headers['HTTP_REFERER']
      assert_equal('http://wovn.io/test', h.out(headers)['Location'])
    end

    def test_out_original_lang_with_path_url_pattern
      h = Wovnrb::Headers.new(
        Wovnrb.get_env(
          'SERVER_NAME' => 'wovn.io',
          'REQUEST_URI' => '/test',
          'HTTP_REFERER' => 'http://wovn.io/test',
        ),
        Wovnrb.get_settings(
          'url_pattern' => 'path',
          'url_pattern_reg' => '/(?<lang>[^/.?]+)',
        ),
      )
      headers = h.request_out(h.lang_code)
      assert_equal('http://wovn.io/test', headers['HTTP_REFERER'])
      headers['Location'] = headers['HTTP_REFERER']
      assert_equal('http://wovn.io/test', h.out(headers)['Location'])
    end

    def test_out_original_lang_with_query_url_pattern
      h = Wovnrb::Headers.new(
        Wovnrb.get_env(
          'SERVER_NAME' => 'wovn.io',
          'REQUEST_URI' => '/test',
          'HTTP_REFERER' => 'http://wovn.io/test',
        ),
        Wovnrb.get_settings(
          'url_pattern' => 'query',
          'url_pattern_reg' => '((\\?.*&)|\\?)wovn=(?<lang>[^&]+)(&|$)',
        ),
      )
      headers = h.request_out(h.lang_code)
      assert_equal('http://wovn.io/test', headers['HTTP_REFERER'])
      headers['Location'] = headers['HTTP_REFERER']
      assert_equal('http://wovn.io/test', h.out(headers)['Location'])
    end

    def test_out_with_wovn_target_lang_header_using_subdomain
      h = Wovnrb::Headers.new(
        Wovnrb.get_env(
          'SERVER_NAME' => 'ja.wovn.io',
          'REQUEST_URI' => '/test',
          'HTTP_REFERER' => 'http://ja.wovn.io/test',
        ),
        Wovnrb.get_settings(
          'url_pattern' => 'subdomain',
          'url_pattern_reg' => '^(?<lang>[^.]+).',
        ),
      )
      headers = h.out(h.request_out('ja'))
      assert_equal('ja', headers['wovnrb.target_lang'])
    end

    def test_out_with_wovn_target_lang_header_using_path
      h = Wovnrb::Headers.new(
        Wovnrb.get_env('REQUEST_URI' => '/ja/test', 'HTTP_REFERER' => 'http://wovn.io/ja/test'),
        Wovnrb.get_settings,
      )
      headers = h.out(h.request_out('ja'))
      assert_equal('ja', headers['wovnrb.target_lang'])
    end

    def test_out_with_wovn_target_lang_header_using_query
      h = Wovnrb::Headers.new(
        Wovnrb.get_env('REQUEST_URI' => 'test?wovn=ja', 'HTTP_REFERER' => 'http://wovn.io/test'),
        Wovnrb.get_settings(
          'url_pattern' => 'query',
          'url_pattern_reg' => "((\\?.*&)|\\?)wovn=(?<lang>[^&]+)(&|$)",
        ),
      )
      headers = h.out(h.request_out('ja'))
      assert_equal('ja', headers['wovnrb.target_lang'])
    end

    #########################
    # GET SETTINGS
    #########################

    def test_get_settings_valid
      # TODO: check if Wovnrb.get_settings is valid (store.rb, valid_settings)
      # s = Wovnrb::Store.new
      # settings = Wovnrb.get_settings

      # settings_stub = stub
      # settings_stub.expects(:has_key).with(:user_token).returns(settings["user_token"])
      # s.valid_settings?
    end

    #########################
    # PATH LANG: SUBDOMAIN
    #########################

    def test_path_lang_subdomain_empty
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+)\.'))
      assert_equal('', h.path_lang)
    end

    def test_path_lang_subdomain_ar
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://ar.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ar', h.path_lang)
    end

    def test_path_lang_subdomain_ar_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://AR.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ar', h.path_lang)
    end

    def test_path_lang_subdomain_da
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://da.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('da', h.path_lang)
    end

    def test_path_lang_subdomain_da_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://DA.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('da', h.path_lang)
    end

    def test_path_lang_subdomain_nl
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://nl.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('nl', h.path_lang)
    end

    def test_path_lang_subdomain_nl_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://NL.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('nl', h.path_lang)
    end

    def test_path_lang_subdomain_en
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://en.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('en', h.path_lang)
    end

    def test_path_lang_subdomain_en_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://EN.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('en', h.path_lang)
    end

    def test_path_lang_subdomain_fi
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://fi.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('fi', h.path_lang)
    end

    def test_path_lang_subdomain_fi_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://FI.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('fi', h.path_lang)
    end

    def test_path_lang_subdomain_fr
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://fr.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('fr', h.path_lang)
    end

    def test_path_lang_subdomain_fr_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://FR.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('fr', h.path_lang)
    end

    def test_path_lang_subdomain_de
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://de.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('de', h.path_lang)
    end

    def test_path_lang_subdomain_de_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://DE.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('de', h.path_lang)
    end

    def test_path_lang_subdomain_el
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://el.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('el', h.path_lang)
    end

    def test_path_lang_subdomain_el_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://EL.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('el', h.path_lang)
    end

    def test_path_lang_subdomain_he
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://he.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('he', h.path_lang)
    end

    def test_path_lang_subdomain_he_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://HE.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('he', h.path_lang)
    end

    def test_path_lang_subdomain_id
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://id.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('id', h.path_lang)
    end

    def test_path_lang_subdomain_id_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://ID.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('id', h.path_lang)
    end

    def test_path_lang_subdomain_it
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://it.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('it', h.path_lang)
    end

    def test_path_lang_subdomain_it_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://IT.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('it', h.path_lang)
    end

    def test_path_lang_subdomain_ja
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://ja.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ja', h.path_lang)
    end

    def test_path_lang_subdomain_ja_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://JA.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ja', h.path_lang)
    end

    def test_path_lang_subdomain_ko
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://ko.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ko', h.path_lang)
    end

    def test_path_lang_subdomain_ko_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://KO.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ko', h.path_lang)
    end

    def test_path_lang_subdomain_ms
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://ms.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ms', h.path_lang)
    end

    def test_path_lang_subdomain_ms_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://MS.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ms', h.path_lang)
    end

    def test_path_lang_subdomain_no
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://no.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('no', h.path_lang)
    end

    def test_path_lang_subdomain_no_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://NO.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('no', h.path_lang)
    end

    def test_path_lang_subdomain_pl
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://pl.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('pl', h.path_lang)
    end

    def test_path_lang_subdomain_pl_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://PL.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('pl', h.path_lang)
    end

    def test_path_lang_subdomain_pt
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://pt.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('pt', h.path_lang)
    end

    def test_path_lang_subdomain_pt_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://PT.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('pt', h.path_lang)
    end

    def test_path_lang_subdomain_ru
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://ru.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ru', h.path_lang)
    end

    def test_path_lang_subdomain_ru_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://RU.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ru', h.path_lang)
    end

    def test_path_lang_subdomain_es
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://es.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('es', h.path_lang)
    end

    def test_path_lang_subdomain_es_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://ES.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('es', h.path_lang)
    end

    def test_path_lang_subdomain_sv
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://sv.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('sv', h.path_lang)
    end

    def test_path_lang_subdomain_sv_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://SV.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('sv', h.path_lang)
    end

    def test_path_lang_subdomain_th
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://th.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('th', h.path_lang)
    end

    def test_path_lang_subdomain_th_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://TH.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('th', h.path_lang)
    end

    def test_path_lang_subdomain_hi
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://hi.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('hi', h.path_lang)
    end

    def test_path_lang_subdomain_hi_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://HI.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('hi', h.path_lang)
    end

    def test_path_lang_subdomain_tr
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://tr.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('tr', h.path_lang)
    end

    def test_path_lang_subdomain_tr_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://TR.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('tr', h.path_lang)
    end

    def test_path_lang_subdomain_uk
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://uk.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('uk', h.path_lang)
    end

    def test_path_lang_subdomain_uk_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://UK.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('uk', h.path_lang)
    end

    def test_path_lang_subdomain_vi
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://vi.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('vi', h.path_lang)
    end

    def test_path_lang_subdomain_vi_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://VI.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('vi', h.path_lang)
    end

    def test_path_lang_subdomain_zh_CHS
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://zh-CHS.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('zh-CHS', h.path_lang)
    end

    def test_path_lang_subdomain_zh_CHS_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://ZH-CHS.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('zh-CHS', h.path_lang)
    end

    def test_path_lang_subdomain_zh_CHS_lowercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://zh-chs.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('zh-CHS', h.path_lang)
    end

    def test_path_lang_subdomain_zh_CHT
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://zh-CHT.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('zh-CHT', h.path_lang)
    end

    def test_path_lang_subdomain_zh_CHT_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://ZH-CHT.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('zh-CHT', h.path_lang)
    end

    def test_path_lang_subdomain_zh_CHT_lowercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://zh-cht.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('zh-CHT', h.path_lang)
    end

    def test_path_lang_subdomain_empty_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+)\.'))
      assert_equal('', h.path_lang)
    end

    def test_path_lang_subdomain_ar_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://ar.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ar', h.path_lang)
    end

    def test_path_lang_subdomain_ar_uppercase_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://AR.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ar', h.path_lang)
    end

    def test_path_lang_subdomain_da_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://da.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('da', h.path_lang)
    end

    def test_path_lang_subdomain_da_uppercase_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://DA.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('da', h.path_lang)
    end

    def test_path_lang_subdomain_nl_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://nl.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('nl', h.path_lang)
    end

    def test_path_lang_subdomain_nl_uppercase_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://NL.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('nl', h.path_lang)
    end

    def test_path_lang_subdomain_en_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://en.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('en', h.path_lang)
    end

    def test_path_lang_subdomain_en_uppercase_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://EN.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('en', h.path_lang)
    end

    def test_path_lang_subdomain_fi_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://fi.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('fi', h.path_lang)
    end

    def test_path_lang_subdomain_fi_uppercase_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://FI.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('fi', h.path_lang)
    end

    def test_path_lang_subdomain_fr_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://fr.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('fr', h.path_lang)
    end

    def test_path_lang_subdomain_fr_uppercase_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://FR.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('fr', h.path_lang)
    end

    def test_path_lang_subdomain_de_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://de.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('de', h.path_lang)
    end

    def test_path_lang_subdomain_de_uppercase_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://DE.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('de', h.path_lang)
    end

    def test_path_lang_subdomain_el_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://el.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('el', h.path_lang)
    end

    def test_path_lang_subdomain_el_uppercase_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://EL.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('el', h.path_lang)
    end

    def test_path_lang_subdomain_he_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://he.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('he', h.path_lang)
    end

    def test_path_lang_subdomain_he_uppercase_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://HE.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('he', h.path_lang)
    end

    def test_path_lang_subdomain_id_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://id.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('id', h.path_lang)
    end

    def test_path_lang_subdomain_id_uppercase_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://ID.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('id', h.path_lang)
    end

    def test_path_lang_subdomain_it_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://it.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('it', h.path_lang)
    end

    def test_path_lang_subdomain_it_uppercase_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://IT.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('it', h.path_lang)
    end

    def test_path_lang_subdomain_ja_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://ja.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ja', h.path_lang)
    end

    def test_path_lang_subdomain_ja_uppercase_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://JA.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ja', h.path_lang)
    end

    def test_path_lang_subdomain_ko_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://ko.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ko', h.path_lang)
    end

    def test_path_lang_subdomain_ko_uppercase_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://KO.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ko', h.path_lang)
    end

    def test_path_lang_subdomain_ms_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://ms.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ms', h.path_lang)
    end

    def test_path_lang_subdomain_ms_uppercase_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://MS.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ms', h.path_lang)
    end

    def test_path_lang_subdomain_no_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://no.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('no', h.path_lang)
    end

    def test_path_lang_subdomain_no_uppercase_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://NO.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('no', h.path_lang)
    end

    def test_path_lang_subdomain_pl_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://pl.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('pl', h.path_lang)
    end

    def test_path_lang_subdomain_pl_uppercase_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://PL.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('pl', h.path_lang)
    end

    def test_path_lang_subdomain_pt_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://pt.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('pt', h.path_lang)
    end

    def test_path_lang_subdomain_pt_uppercase_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://PT.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('pt', h.path_lang)
    end

    def test_path_lang_subdomain_ru_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://ru.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ru', h.path_lang)
    end

    def test_path_lang_subdomain_ru_uppercase_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://RU.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ru', h.path_lang)
    end

    def test_path_lang_subdomain_es_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://es.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('es', h.path_lang)
    end

    def test_path_lang_subdomain_es_uppercase_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://ES.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('es', h.path_lang)
    end

    def test_path_lang_subdomain_sv_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://sv.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('sv', h.path_lang)
    end

    def test_path_lang_subdomain_sv_uppercase_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://SV.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('sv', h.path_lang)
    end

    def test_path_lang_subdomain_th_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://th.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('th', h.path_lang)
    end

    def test_path_lang_subdomain_th_uppercase_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://TH.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('th', h.path_lang)
    end

    def test_path_lang_subdomain_hi_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://hi.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('hi', h.path_lang)
    end

    def test_path_lang_subdomain_hi_uppercase_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://HI.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('hi', h.path_lang)
    end

    def test_path_lang_subdomain_tr_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://tr.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('tr', h.path_lang)
    end

    def test_path_lang_subdomain_tr_uppercase_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://TR.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('tr', h.path_lang)
    end

    def test_path_lang_subdomain_uk_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://uk.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('uk', h.path_lang)
    end

    def test_path_lang_subdomain_uk_uppercase_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://UK.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('uk', h.path_lang)
    end

    def test_path_lang_subdomain_vi_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://vi.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('vi', h.path_lang)
    end

    def test_path_lang_subdomain_vi_uppercase_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://VI.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('vi', h.path_lang)
    end

    def test_path_lang_subdomain_zh_CHS_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://zh-CHS.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('zh-CHS', h.path_lang)
    end

    def test_path_lang_subdomain_zh_CHS_uppercase_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://ZH-CHS.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('zh-CHS', h.path_lang)
    end

    def test_path_lang_subdomain_zh_CHS_lowercase_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://zh-chs.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('zh-CHS', h.path_lang)
    end

    def test_path_lang_subdomain_zh_CHT_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://zh-CHT.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('zh-CHT', h.path_lang)
    end

    def test_path_lang_subdomain_zh_CHT_uppercase_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://ZH-CHT.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('zh-CHT', h.path_lang)
    end

    def test_path_lang_subdomain_zh_CHT_lowercase_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://zh-cht.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('zh-CHT', h.path_lang)
    end

    def test_path_lang_subdomain_empty_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+)\.'))
      assert_equal('', h.path_lang)
    end

    def test_path_lang_subdomain_ar_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://ar.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ar', h.path_lang)
    end

    def test_path_lang_subdomain_ar_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://AR.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ar', h.path_lang)
    end

    def test_path_lang_subdomain_da_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://da.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('da', h.path_lang)
    end

    def test_path_lang_subdomain_da_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://DA.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('da', h.path_lang)
    end

    def test_path_lang_subdomain_nl_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://nl.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('nl', h.path_lang)
    end

    def test_path_lang_subdomain_nl_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://NL.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('nl', h.path_lang)
    end

    def test_path_lang_subdomain_en_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://en.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('en', h.path_lang)
    end

    def test_path_lang_subdomain_en_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://EN.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('en', h.path_lang)
    end

    def test_path_lang_subdomain_fi_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://fi.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('fi', h.path_lang)
    end

    def test_path_lang_subdomain_fi_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://FI.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('fi', h.path_lang)
    end

    def test_path_lang_subdomain_fr_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://fr.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('fr', h.path_lang)
    end

    def test_path_lang_subdomain_fr_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://FR.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('fr', h.path_lang)
    end

    def test_path_lang_subdomain_de_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://de.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('de', h.path_lang)
    end

    def test_path_lang_subdomain_de_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://DE.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('de', h.path_lang)
    end

    def test_path_lang_subdomain_el_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://el.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('el', h.path_lang)
    end

    def test_path_lang_subdomain_el_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://EL.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('el', h.path_lang)
    end

    def test_path_lang_subdomain_he_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://he.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('he', h.path_lang)
    end

    def test_path_lang_subdomain_he_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://HE.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('he', h.path_lang)
    end

    def test_path_lang_subdomain_id_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://id.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('id', h.path_lang)
    end

    def test_path_lang_subdomain_id_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://ID.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('id', h.path_lang)
    end

    def test_path_lang_subdomain_it_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://it.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('it', h.path_lang)
    end

    def test_path_lang_subdomain_it_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://IT.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('it', h.path_lang)
    end

    def test_path_lang_subdomain_ja_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://ja.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ja', h.path_lang)
    end

    def test_path_lang_subdomain_ja_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://JA.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ja', h.path_lang)
    end

    def test_path_lang_subdomain_ko_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://ko.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ko', h.path_lang)
    end

    def test_path_lang_subdomain_ko_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://KO.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ko', h.path_lang)
    end

    def test_path_lang_subdomain_ms_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://ms.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ms', h.path_lang)
    end

    def test_path_lang_subdomain_ms_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://MS.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ms', h.path_lang)
    end

    def test_path_lang_subdomain_no_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://no.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('no', h.path_lang)
    end

    def test_path_lang_subdomain_no_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://NO.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('no', h.path_lang)
    end

    def test_path_lang_subdomain_pl_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://pl.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('pl', h.path_lang)
    end

    def test_path_lang_subdomain_pl_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://PL.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('pl', h.path_lang)
    end

    def test_path_lang_subdomain_pt_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://pt.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('pt', h.path_lang)
    end

    def test_path_lang_subdomain_pt_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://PT.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('pt', h.path_lang)
    end

    def test_path_lang_subdomain_ru_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://ru.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ru', h.path_lang)
    end

    def test_path_lang_subdomain_ru_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://RU.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ru', h.path_lang)
    end

    def test_path_lang_subdomain_es_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://es.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('es', h.path_lang)
    end

    def test_path_lang_subdomain_es_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://ES.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('es', h.path_lang)
    end

    def test_path_lang_subdomain_sv_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://sv.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('sv', h.path_lang)
    end

    def test_path_lang_subdomain_sv_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://SV.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('sv', h.path_lang)
    end

    def test_path_lang_subdomain_th_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://th.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('th', h.path_lang)
    end

    def test_path_lang_subdomain_th_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://TH.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('th', h.path_lang)
    end

    def test_path_lang_subdomain_hi_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://hi.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('hi', h.path_lang)
    end

    def test_path_lang_subdomain_hi_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://HI.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('hi', h.path_lang)
    end

    def test_path_lang_subdomain_tr_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://tr.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('tr', h.path_lang)
    end

    def test_path_lang_subdomain_tr_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://TR.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('tr', h.path_lang)
    end

    def test_path_lang_subdomain_uk_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://uk.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('uk', h.path_lang)
    end

    def test_path_lang_subdomain_uk_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://UK.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('uk', h.path_lang)
    end

    def test_path_lang_subdomain_vi_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://vi.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('vi', h.path_lang)
    end

    def test_path_lang_subdomain_vi_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://VI.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('vi', h.path_lang)
    end

    def test_path_lang_subdomain_zh_CHS_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://zh-CHS.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('zh-CHS', h.path_lang)
    end

    def test_path_lang_subdomain_zh_CHS_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://ZH-CHS.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('zh-CHS', h.path_lang)
    end

    def test_path_lang_subdomain_zh_CHS_lowercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://zh-chs.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('zh-CHS', h.path_lang)
    end

    def test_path_lang_subdomain_zh_CHT_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://zh-CHT.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('zh-CHT', h.path_lang)
    end

    def test_path_lang_subdomain_zh_CHT_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://ZH-CHT.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('zh-CHT', h.path_lang)
    end

    def test_path_lang_subdomain_zh_CHT_lowercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://zh-cht.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('zh-CHT', h.path_lang)
    end

    def test_path_lang_subdomain_empty_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+)\.'))
      assert_equal('', h.path_lang)
    end

    def test_path_lang_subdomain_ar_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://ar.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ar', h.path_lang)
    end

    def test_path_lang_subdomain_ar_uppercase_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://AR.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ar', h.path_lang)
    end

    def test_path_lang_subdomain_da_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://da.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('da', h.path_lang)
    end

    def test_path_lang_subdomain_da_uppercase_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://DA.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('da', h.path_lang)
    end

    def test_path_lang_subdomain_nl_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://nl.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('nl', h.path_lang)
    end

    def test_path_lang_subdomain_nl_uppercase_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://NL.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('nl', h.path_lang)
    end

    def test_path_lang_subdomain_en_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://en.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('en', h.path_lang)
    end

    def test_path_lang_subdomain_en_uppercase_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://EN.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('en', h.path_lang)
    end

    def test_path_lang_subdomain_fi_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://fi.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('fi', h.path_lang)
    end

    def test_path_lang_subdomain_fi_uppercase_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://FI.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('fi', h.path_lang)
    end

    def test_path_lang_subdomain_fr_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://fr.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('fr', h.path_lang)
    end

    def test_path_lang_subdomain_fr_uppercase_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://FR.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('fr', h.path_lang)
    end

    def test_path_lang_subdomain_de_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://de.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('de', h.path_lang)
    end

    def test_path_lang_subdomain_de_uppercase_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://DE.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('de', h.path_lang)
    end

    def test_path_lang_subdomain_el_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://el.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('el', h.path_lang)
    end

    def test_path_lang_subdomain_el_uppercase_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://EL.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('el', h.path_lang)
    end

    def test_path_lang_subdomain_he_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://he.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('he', h.path_lang)
    end

    def test_path_lang_subdomain_he_uppercase_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://HE.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('he', h.path_lang)
    end

    def test_path_lang_subdomain_id_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://id.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('id', h.path_lang)
    end

    def test_path_lang_subdomain_id_uppercase_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://ID.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('id', h.path_lang)
    end

    def test_path_lang_subdomain_it_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://it.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('it', h.path_lang)
    end

    def test_path_lang_subdomain_it_uppercase_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://IT.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('it', h.path_lang)
    end

    def test_path_lang_subdomain_ja_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://ja.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ja', h.path_lang)
    end

    def test_path_lang_subdomain_ja_uppercase_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://JA.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ja', h.path_lang)
    end

    def test_path_lang_subdomain_ko_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://ko.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ko', h.path_lang)
    end

    def test_path_lang_subdomain_ko_uppercase_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://KO.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ko', h.path_lang)
    end

    def test_path_lang_subdomain_ms_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://ms.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ms', h.path_lang)
    end

    def test_path_lang_subdomain_ms_uppercase_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://MS.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ms', h.path_lang)
    end

    def test_path_lang_subdomain_no_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://no.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('no', h.path_lang)
    end

    def test_path_lang_subdomain_no_uppercase_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://NO.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('no', h.path_lang)
    end

    def test_path_lang_subdomain_pl_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://pl.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('pl', h.path_lang)
    end

    def test_path_lang_subdomain_pl_uppercase_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://PL.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('pl', h.path_lang)
    end

    def test_path_lang_subdomain_pt_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://pt.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('pt', h.path_lang)
    end

    def test_path_lang_subdomain_pt_uppercase_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://PT.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('pt', h.path_lang)
    end

    def test_path_lang_subdomain_ru_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://ru.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ru', h.path_lang)
    end

    def test_path_lang_subdomain_ru_uppercase_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://RU.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ru', h.path_lang)
    end

    def test_path_lang_subdomain_es_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://es.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('es', h.path_lang)
    end

    def test_path_lang_subdomain_es_uppercase_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://ES.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('es', h.path_lang)
    end

    def test_path_lang_subdomain_sv_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://sv.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('sv', h.path_lang)
    end

    def test_path_lang_subdomain_sv_uppercase_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://SV.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('sv', h.path_lang)
    end

    def test_path_lang_subdomain_th_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://th.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('th', h.path_lang)
    end

    def test_path_lang_subdomain_th_uppercase_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://TH.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('th', h.path_lang)
    end

    def test_path_lang_subdomain_hi_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://hi.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('hi', h.path_lang)
    end

    def test_path_lang_subdomain_hi_uppercase_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://HI.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('hi', h.path_lang)
    end

    def test_path_lang_subdomain_tr_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://tr.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('tr', h.path_lang)
    end

    def test_path_lang_subdomain_tr_uppercase_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://TR.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('tr', h.path_lang)
    end

    def test_path_lang_subdomain_uk_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://uk.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('uk', h.path_lang)
    end

    def test_path_lang_subdomain_uk_uppercase_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://UK.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('uk', h.path_lang)
    end

    def test_path_lang_subdomain_vi_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://vi.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('vi', h.path_lang)
    end

    def test_path_lang_subdomain_vi_uppercase_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://VI.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('vi', h.path_lang)
    end

    def test_path_lang_subdomain_zh_CHS_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://zh-CHS.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('zh-CHS', h.path_lang)
    end

    def test_path_lang_subdomain_zh_CHS_uppercase_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://ZH-CHS.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('zh-CHS', h.path_lang)
    end

    def test_path_lang_subdomain_zh_CHS_lowercase_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://zh-chs.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('zh-CHS', h.path_lang)
    end

    def test_path_lang_subdomain_zh_CHT_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://zh-CHT.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('zh-CHT', h.path_lang)
    end

    def test_path_lang_subdomain_zh_CHT_uppercase_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://ZH-CHT.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('zh-CHT', h.path_lang)
    end

    def test_path_lang_subdomain_zh_CHT_lowercase_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://zh-cht.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('zh-CHT', h.path_lang)
    end

    def test_path_lang_subdomain_empty_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+)\.'))
      assert_equal('', h.path_lang)
    end

    def test_path_lang_subdomain_ar_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://ar.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ar', h.path_lang)
    end

    def test_path_lang_subdomain_ar_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://AR.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ar', h.path_lang)
    end

    def test_path_lang_subdomain_da_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://da.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('da', h.path_lang)
    end

    def test_path_lang_subdomain_da_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://DA.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('da', h.path_lang)
    end

    def test_path_lang_subdomain_nl_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://nl.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('nl', h.path_lang)
    end

    def test_path_lang_subdomain_nl_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://NL.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('nl', h.path_lang)
    end

    def test_path_lang_subdomain_en_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://en.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('en', h.path_lang)
    end

    def test_path_lang_subdomain_en_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://EN.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('en', h.path_lang)
    end

    def test_path_lang_subdomain_fi_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://fi.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('fi', h.path_lang)
    end

    def test_path_lang_subdomain_fi_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://FI.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('fi', h.path_lang)
    end

    def test_path_lang_subdomain_fr_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://fr.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('fr', h.path_lang)
    end

    def test_path_lang_subdomain_fr_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://FR.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('fr', h.path_lang)
    end

    def test_path_lang_subdomain_de_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://de.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('de', h.path_lang)
    end

    def test_path_lang_subdomain_de_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://DE.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('de', h.path_lang)
    end

    def test_path_lang_subdomain_el_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://el.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('el', h.path_lang)
    end

    def test_path_lang_subdomain_el_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://EL.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('el', h.path_lang)
    end

    def test_path_lang_subdomain_he_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://he.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('he', h.path_lang)
    end

    def test_path_lang_subdomain_he_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://HE.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('he', h.path_lang)
    end

    def test_path_lang_subdomain_id_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://id.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('id', h.path_lang)
    end

    def test_path_lang_subdomain_id_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://ID.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('id', h.path_lang)
    end

    def test_path_lang_subdomain_it_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://it.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('it', h.path_lang)
    end

    def test_path_lang_subdomain_it_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://IT.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('it', h.path_lang)
    end

    def test_path_lang_subdomain_ja_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://ja.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ja', h.path_lang)
    end

    def test_path_lang_subdomain_ja_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://JA.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ja', h.path_lang)
    end

    def test_path_lang_subdomain_ko_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://ko.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ko', h.path_lang)
    end

    def test_path_lang_subdomain_ko_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://KO.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ko', h.path_lang)
    end

    def test_path_lang_subdomain_ms_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://ms.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ms', h.path_lang)
    end

    def test_path_lang_subdomain_ms_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://MS.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ms', h.path_lang)
    end

    def test_path_lang_subdomain_no_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://no.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('no', h.path_lang)
    end

    def test_path_lang_subdomain_no_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://NO.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('no', h.path_lang)
    end

    def test_path_lang_subdomain_pl_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://pl.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('pl', h.path_lang)
    end

    def test_path_lang_subdomain_pl_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://PL.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('pl', h.path_lang)
    end

    def test_path_lang_subdomain_pt_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://pt.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('pt', h.path_lang)
    end

    def test_path_lang_subdomain_pt_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://PT.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('pt', h.path_lang)
    end

    def test_path_lang_subdomain_ru_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://ru.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ru', h.path_lang)
    end

    def test_path_lang_subdomain_ru_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://RU.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ru', h.path_lang)
    end

    def test_path_lang_subdomain_es_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://es.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('es', h.path_lang)
    end

    def test_path_lang_subdomain_es_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://ES.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('es', h.path_lang)
    end

    def test_path_lang_subdomain_sv_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://sv.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('sv', h.path_lang)
    end

    def test_path_lang_subdomain_sv_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://SV.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('sv', h.path_lang)
    end

    def test_path_lang_subdomain_th_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://th.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('th', h.path_lang)
    end

    def test_path_lang_subdomain_th_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://TH.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('th', h.path_lang)
    end

    def test_path_lang_subdomain_hi_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://hi.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('hi', h.path_lang)
    end

    def test_path_lang_subdomain_hi_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://HI.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('hi', h.path_lang)
    end

    def test_path_lang_subdomain_tr_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://tr.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('tr', h.path_lang)
    end

    def test_path_lang_subdomain_tr_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://TR.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('tr', h.path_lang)
    end

    def test_path_lang_subdomain_uk_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://uk.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('uk', h.path_lang)
    end

    def test_path_lang_subdomain_uk_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://UK.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('uk', h.path_lang)
    end

    def test_path_lang_subdomain_vi_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://vi.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('vi', h.path_lang)
    end

    def test_path_lang_subdomain_vi_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://VI.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('vi', h.path_lang)
    end

    def test_path_lang_subdomain_zh_CHS_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://zh-CHS.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('zh-CHS', h.path_lang)
    end

    def test_path_lang_subdomain_zh_CHS_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://ZH-CHS.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('zh-CHS', h.path_lang)
    end

    def test_path_lang_subdomain_zh_CHS_lowercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://zh-chs.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('zh-CHS', h.path_lang)
    end

    def test_path_lang_subdomain_zh_CHT_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://zh-CHT.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('zh-CHT', h.path_lang)
    end

    def test_path_lang_subdomain_zh_CHT_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://ZH-CHT.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('zh-CHT', h.path_lang)
    end

    def test_path_lang_subdomain_zh_CHT_lowercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://zh-cht.wovn.io'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('zh-CHT', h.path_lang)
    end

    def test_path_lang_subdomain_empty_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+)\.'))
      assert_equal('', h.path_lang)
    end

    def test_path_lang_subdomain_ar_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://ar.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ar', h.path_lang)
    end

    def test_path_lang_subdomain_ar_uppercase_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://AR.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ar', h.path_lang)
    end

    def test_path_lang_subdomain_da_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://da.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('da', h.path_lang)
    end

    def test_path_lang_subdomain_da_uppercase_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://DA.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('da', h.path_lang)
    end

    def test_path_lang_subdomain_nl_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://nl.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('nl', h.path_lang)
    end

    def test_path_lang_subdomain_nl_uppercase_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://NL.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('nl', h.path_lang)
    end

    def test_path_lang_subdomain_en_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://en.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('en', h.path_lang)
    end

    def test_path_lang_subdomain_en_uppercase_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://EN.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('en', h.path_lang)
    end

    def test_path_lang_subdomain_fi_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://fi.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('fi', h.path_lang)
    end

    def test_path_lang_subdomain_fi_uppercase_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://FI.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('fi', h.path_lang)
    end

    def test_path_lang_subdomain_fr_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://fr.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('fr', h.path_lang)
    end

    def test_path_lang_subdomain_fr_uppercase_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://FR.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('fr', h.path_lang)
    end

    def test_path_lang_subdomain_de_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://de.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('de', h.path_lang)
    end

    def test_path_lang_subdomain_de_uppercase_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://DE.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('de', h.path_lang)
    end

    def test_path_lang_subdomain_el_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://el.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('el', h.path_lang)
    end

    def test_path_lang_subdomain_el_uppercase_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://EL.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('el', h.path_lang)
    end

    def test_path_lang_subdomain_he_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://he.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('he', h.path_lang)
    end

    def test_path_lang_subdomain_he_uppercase_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://HE.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('he', h.path_lang)
    end

    def test_path_lang_subdomain_id_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://id.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('id', h.path_lang)
    end

    def test_path_lang_subdomain_id_uppercase_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://ID.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('id', h.path_lang)
    end

    def test_path_lang_subdomain_it_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://it.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('it', h.path_lang)
    end

    def test_path_lang_subdomain_it_uppercase_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://IT.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('it', h.path_lang)
    end

    def test_path_lang_subdomain_ja_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://ja.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ja', h.path_lang)
    end

    def test_path_lang_subdomain_ja_uppercase_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://JA.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ja', h.path_lang)
    end

    def test_path_lang_subdomain_ko_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://ko.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ko', h.path_lang)
    end

    def test_path_lang_subdomain_ko_uppercase_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://KO.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ko', h.path_lang)
    end

    def test_path_lang_subdomain_ms_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://ms.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ms', h.path_lang)
    end

    def test_path_lang_subdomain_ms_uppercase_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://MS.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ms', h.path_lang)
    end

    def test_path_lang_subdomain_no_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://no.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('no', h.path_lang)
    end

    def test_path_lang_subdomain_no_uppercase_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://NO.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('no', h.path_lang)
    end

    def test_path_lang_subdomain_pl_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://pl.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('pl', h.path_lang)
    end

    def test_path_lang_subdomain_pl_uppercase_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://PL.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('pl', h.path_lang)
    end

    def test_path_lang_subdomain_pt_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://pt.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('pt', h.path_lang)
    end

    def test_path_lang_subdomain_pt_uppercase_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://PT.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('pt', h.path_lang)
    end

    def test_path_lang_subdomain_ru_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://ru.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ru', h.path_lang)
    end

    def test_path_lang_subdomain_ru_uppercase_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://RU.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ru', h.path_lang)
    end

    def test_path_lang_subdomain_es_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://es.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('es', h.path_lang)
    end

    def test_path_lang_subdomain_es_uppercase_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://ES.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('es', h.path_lang)
    end

    def test_path_lang_subdomain_sv_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://sv.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('sv', h.path_lang)
    end

    def test_path_lang_subdomain_sv_uppercase_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://SV.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('sv', h.path_lang)
    end

    def test_path_lang_subdomain_th_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://th.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('th', h.path_lang)
    end

    def test_path_lang_subdomain_th_uppercase_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://TH.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('th', h.path_lang)
    end

    def test_path_lang_subdomain_hi_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://hi.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('hi', h.path_lang)
    end

    def test_path_lang_subdomain_hi_uppercase_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://HI.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('hi', h.path_lang)
    end

    def test_path_lang_subdomain_tr_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://tr.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('tr', h.path_lang)
    end

    def test_path_lang_subdomain_tr_uppercase_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://TR.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('tr', h.path_lang)
    end

    def test_path_lang_subdomain_uk_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://uk.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('uk', h.path_lang)
    end

    def test_path_lang_subdomain_uk_uppercase_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://UK.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('uk', h.path_lang)
    end

    def test_path_lang_subdomain_vi_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://vi.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('vi', h.path_lang)
    end

    def test_path_lang_subdomain_vi_uppercase_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://VI.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('vi', h.path_lang)
    end

    def test_path_lang_subdomain_zh_CHS_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://zh-CHS.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('zh-CHS', h.path_lang)
    end

    def test_path_lang_subdomain_zh_CHS_uppercase_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://ZH-CHS.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('zh-CHS', h.path_lang)
    end

    def test_path_lang_subdomain_zh_CHS_lowercase_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://zh-chs.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('zh-CHS', h.path_lang)
    end

    def test_path_lang_subdomain_zh_CHT_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://zh-CHT.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('zh-CHT', h.path_lang)
    end

    def test_path_lang_subdomain_zh_CHT_uppercase_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://ZH-CHT.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('zh-CHT', h.path_lang)
    end

    def test_path_lang_subdomain_zh_CHT_lowercase_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://zh-cht.wovn.io/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('zh-CHT', h.path_lang)
    end

    def test_path_lang_subdomain_empty_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+)\.'))
      assert_equal('', h.path_lang)
    end

    def test_path_lang_subdomain_ar_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://ar.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ar', h.path_lang)
    end

    def test_path_lang_subdomain_ar_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://AR.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ar', h.path_lang)
    end

    def test_path_lang_subdomain_da_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://da.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('da', h.path_lang)
    end

    def test_path_lang_subdomain_da_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://DA.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('da', h.path_lang)
    end

    def test_path_lang_subdomain_nl_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://nl.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('nl', h.path_lang)
    end

    def test_path_lang_subdomain_nl_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://NL.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('nl', h.path_lang)
    end

    def test_path_lang_subdomain_en_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://en.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('en', h.path_lang)
    end

    def test_path_lang_subdomain_en_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://EN.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('en', h.path_lang)
    end

    def test_path_lang_subdomain_fi_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://fi.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('fi', h.path_lang)
    end

    def test_path_lang_subdomain_fi_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://FI.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('fi', h.path_lang)
    end

    def test_path_lang_subdomain_fr_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://fr.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('fr', h.path_lang)
    end

    def test_path_lang_subdomain_fr_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://FR.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('fr', h.path_lang)
    end

    def test_path_lang_subdomain_de_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://de.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('de', h.path_lang)
    end

    def test_path_lang_subdomain_de_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://DE.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('de', h.path_lang)
    end

    def test_path_lang_subdomain_el_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://el.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('el', h.path_lang)
    end

    def test_path_lang_subdomain_el_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://EL.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('el', h.path_lang)
    end

    def test_path_lang_subdomain_he_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://he.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('he', h.path_lang)
    end

    def test_path_lang_subdomain_he_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://HE.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('he', h.path_lang)
    end

    def test_path_lang_subdomain_id_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://id.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('id', h.path_lang)
    end

    def test_path_lang_subdomain_id_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://ID.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('id', h.path_lang)
    end

    def test_path_lang_subdomain_it_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://it.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('it', h.path_lang)
    end

    def test_path_lang_subdomain_it_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://IT.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('it', h.path_lang)
    end

    def test_path_lang_subdomain_ja_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://ja.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ja', h.path_lang)
    end

    def test_path_lang_subdomain_ja_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://JA.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ja', h.path_lang)
    end

    def test_path_lang_subdomain_ko_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://ko.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ko', h.path_lang)
    end

    def test_path_lang_subdomain_ko_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://KO.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ko', h.path_lang)
    end

    def test_path_lang_subdomain_ms_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://ms.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ms', h.path_lang)
    end

    def test_path_lang_subdomain_ms_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://MS.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ms', h.path_lang)
    end

    def test_path_lang_subdomain_no_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://no.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('no', h.path_lang)
    end

    def test_path_lang_subdomain_no_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://NO.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('no', h.path_lang)
    end

    def test_path_lang_subdomain_pl_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://pl.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('pl', h.path_lang)
    end

    def test_path_lang_subdomain_pl_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://PL.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('pl', h.path_lang)
    end

    def test_path_lang_subdomain_pt_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://pt.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('pt', h.path_lang)
    end

    def test_path_lang_subdomain_pt_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://PT.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('pt', h.path_lang)
    end

    def test_path_lang_subdomain_ru_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://ru.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ru', h.path_lang)
    end

    def test_path_lang_subdomain_ru_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://RU.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ru', h.path_lang)
    end

    def test_path_lang_subdomain_es_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://es.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('es', h.path_lang)
    end

    def test_path_lang_subdomain_es_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://ES.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('es', h.path_lang)
    end

    def test_path_lang_subdomain_sv_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://sv.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('sv', h.path_lang)
    end

    def test_path_lang_subdomain_sv_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://SV.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('sv', h.path_lang)
    end

    def test_path_lang_subdomain_th_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://th.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('th', h.path_lang)
    end

    def test_path_lang_subdomain_th_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://TH.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('th', h.path_lang)
    end

    def test_path_lang_subdomain_hi_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://hi.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('hi', h.path_lang)
    end

    def test_path_lang_subdomain_hi_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://HI.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('hi', h.path_lang)
    end

    def test_path_lang_subdomain_tr_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://tr.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('tr', h.path_lang)
    end

    def test_path_lang_subdomain_tr_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://TR.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('tr', h.path_lang)
    end

    def test_path_lang_subdomain_uk_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://uk.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('uk', h.path_lang)
    end

    def test_path_lang_subdomain_uk_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://UK.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('uk', h.path_lang)
    end

    def test_path_lang_subdomain_vi_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://vi.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('vi', h.path_lang)
    end

    def test_path_lang_subdomain_vi_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://VI.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('vi', h.path_lang)
    end

    def test_path_lang_subdomain_zh_CHS_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://zh-CHS.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('zh-CHS', h.path_lang)
    end

    def test_path_lang_subdomain_zh_CHS_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://ZH-CHS.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('zh-CHS', h.path_lang)
    end

    def test_path_lang_subdomain_zh_CHS_lowercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://zh-chs.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('zh-CHS', h.path_lang)
    end

    def test_path_lang_subdomain_zh_CHT_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://zh-CHT.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('zh-CHT', h.path_lang)
    end

    def test_path_lang_subdomain_zh_CHT_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://ZH-CHT.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('zh-CHT', h.path_lang)
    end

    def test_path_lang_subdomain_zh_CHT_lowercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://zh-cht.wovn.io:1234'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('zh-CHT', h.path_lang)
    end

    def test_path_lang_subdomain_empty_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+)\.'))
      assert_equal('', h.path_lang)
    end

    def test_path_lang_subdomain_ar_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://ar.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ar', h.path_lang)
    end

    def test_path_lang_subdomain_ar_uppercase_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://AR.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ar', h.path_lang)
    end

    def test_path_lang_subdomain_da_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://da.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('da', h.path_lang)
    end

    def test_path_lang_subdomain_da_uppercase_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://DA.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('da', h.path_lang)
    end

    def test_path_lang_subdomain_nl_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://nl.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('nl', h.path_lang)
    end

    def test_path_lang_subdomain_nl_uppercase_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://NL.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('nl', h.path_lang)
    end

    def test_path_lang_subdomain_en_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://en.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('en', h.path_lang)
    end

    def test_path_lang_subdomain_en_uppercase_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://EN.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('en', h.path_lang)
    end

    def test_path_lang_subdomain_fi_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://fi.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('fi', h.path_lang)
    end

    def test_path_lang_subdomain_fi_uppercase_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://FI.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('fi', h.path_lang)
    end

    def test_path_lang_subdomain_fr_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://fr.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('fr', h.path_lang)
    end

    def test_path_lang_subdomain_fr_uppercase_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://FR.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('fr', h.path_lang)
    end

    def test_path_lang_subdomain_de_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://de.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('de', h.path_lang)
    end

    def test_path_lang_subdomain_de_uppercase_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://DE.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('de', h.path_lang)
    end

    def test_path_lang_subdomain_el_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://el.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('el', h.path_lang)
    end

    def test_path_lang_subdomain_el_uppercase_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://EL.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('el', h.path_lang)
    end

    def test_path_lang_subdomain_he_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://he.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('he', h.path_lang)
    end

    def test_path_lang_subdomain_he_uppercase_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://HE.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('he', h.path_lang)
    end

    def test_path_lang_subdomain_id_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://id.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('id', h.path_lang)
    end

    def test_path_lang_subdomain_id_uppercase_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://ID.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('id', h.path_lang)
    end

    def test_path_lang_subdomain_it_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://it.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('it', h.path_lang)
    end

    def test_path_lang_subdomain_it_uppercase_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://IT.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('it', h.path_lang)
    end

    def test_path_lang_subdomain_ja_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://ja.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ja', h.path_lang)
    end

    def test_path_lang_subdomain_ja_uppercase_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://JA.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ja', h.path_lang)
    end

    def test_path_lang_subdomain_ko_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://ko.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ko', h.path_lang)
    end

    def test_path_lang_subdomain_ko_uppercase_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://KO.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ko', h.path_lang)
    end

    def test_path_lang_subdomain_ms_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://ms.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ms', h.path_lang)
    end

    def test_path_lang_subdomain_ms_uppercase_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://MS.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ms', h.path_lang)
    end

    def test_path_lang_subdomain_no_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://no.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('no', h.path_lang)
    end

    def test_path_lang_subdomain_no_uppercase_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://NO.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('no', h.path_lang)
    end

    def test_path_lang_subdomain_pl_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://pl.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('pl', h.path_lang)
    end

    def test_path_lang_subdomain_pl_uppercase_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://PL.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('pl', h.path_lang)
    end

    def test_path_lang_subdomain_pt_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://pt.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('pt', h.path_lang)
    end

    def test_path_lang_subdomain_pt_uppercase_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://PT.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('pt', h.path_lang)
    end

    def test_path_lang_subdomain_ru_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://ru.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ru', h.path_lang)
    end

    def test_path_lang_subdomain_ru_uppercase_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://RU.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('ru', h.path_lang)
    end

    def test_path_lang_subdomain_es_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://es.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('es', h.path_lang)
    end

    def test_path_lang_subdomain_es_uppercase_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://ES.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('es', h.path_lang)
    end

    def test_path_lang_subdomain_sv_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://sv.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('sv', h.path_lang)
    end

    def test_path_lang_subdomain_sv_uppercase_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://SV.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('sv', h.path_lang)
    end

    def test_path_lang_subdomain_th_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://th.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('th', h.path_lang)
    end

    def test_path_lang_subdomain_th_uppercase_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://TH.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('th', h.path_lang)
    end

    def test_path_lang_subdomain_hi_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://hi.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('hi', h.path_lang)
    end

    def test_path_lang_subdomain_hi_uppercase_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://HI.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('hi', h.path_lang)
    end

    def test_path_lang_subdomain_tr_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://tr.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('tr', h.path_lang)
    end

    def test_path_lang_subdomain_tr_uppercase_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://TR.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('tr', h.path_lang)
    end

    def test_path_lang_subdomain_uk_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://uk.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('uk', h.path_lang)
    end

    def test_path_lang_subdomain_uk_uppercase_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://UK.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('uk', h.path_lang)
    end

    def test_path_lang_subdomain_vi_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://vi.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('vi', h.path_lang)
    end

    def test_path_lang_subdomain_vi_uppercase_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://VI.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('vi', h.path_lang)
    end

    def test_path_lang_subdomain_zh_CHS_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://zh-CHS.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('zh-CHS', h.path_lang)
    end

    def test_path_lang_subdomain_zh_CHS_uppercase_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://ZH-CHS.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('zh-CHS', h.path_lang)
    end

    def test_path_lang_subdomain_zh_CHS_lowercase_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://zh-chs.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('zh-CHS', h.path_lang)
    end

    def test_path_lang_subdomain_zh_CHT_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://zh-CHT.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('zh-CHT', h.path_lang)
    end

    def test_path_lang_subdomain_zh_CHT_uppercase_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://ZH-CHT.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('zh-CHT', h.path_lang)
    end

    def test_path_lang_subdomain_zh_CHT_lowercase_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://zh-cht.wovn.io:1234/'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
      assert_equal('zh-CHT', h.path_lang)
    end

    def test_path_lang_sudomain_with_use_proxy_false
      h = Wovnrb::Headers.new(
        Wovnrb.get_env('url' => 'http://localhost:1234/test', 'HTTP_X_FORWARDED_HOST' => 'zh-cht.wovn.io'),
        Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'),
      )
      assert_equal('', h.path_lang)
    end

    def test_path_lang_sudomain_with_use_proxy_true
      env = Wovnrb.get_env('url' => 'http://localhost:1234/test', 'HTTP_X_FORWARDED_HOST' => 'zh-cht.wovn.io')
      h = Wovnrb::Headers.new(
        env,
        Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).', 'use_proxy' => true),
      )
      assert_equal('zh-CHT', h.path_lang)
    end

    #########################
    # PATH LANG: QUERY
    #########################

    def test_path_lang_query_empty
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io?wovn='), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\\?.*&)|\\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('', h.path_lang)
    end

    def test_path_lang_query_ar
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io?wovn=ar'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ar', h.path_lang)
    end

    def test_path_lang_query_ar_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io?wovn=AR'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ar', h.path_lang)
    end

    def test_path_lang_query_da
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io?wovn=da'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('da', h.path_lang)
    end

    def test_path_lang_query_da_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io?wovn=DA'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('da', h.path_lang)
    end

    def test_path_lang_query_nl
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io?wovn=nl'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('nl', h.path_lang)
    end

    def test_path_lang_query_nl_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io?wovn=NL'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('nl', h.path_lang)
    end

    def test_path_lang_query_en
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io?wovn=en'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('en', h.path_lang)
    end

    def test_path_lang_query_en_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io?wovn=EN'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('en', h.path_lang)
    end

    def test_path_lang_query_fi
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io?wovn=fi'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('fi', h.path_lang)
    end

    def test_path_lang_query_fi_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io?wovn=FI'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('fi', h.path_lang)
    end

    def test_path_lang_query_fr
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io?wovn=fr'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('fr', h.path_lang)
    end

    def test_path_lang_query_fr_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io?wovn=FR'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('fr', h.path_lang)
    end

    def test_path_lang_query_de
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io?wovn=de'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('de', h.path_lang)
    end

    def test_path_lang_query_de_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io?wovn=DE'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('de', h.path_lang)
    end

    def test_path_lang_query_el
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io?wovn=el'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('el', h.path_lang)
    end

    def test_path_lang_query_el_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io?wovn=EL'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('el', h.path_lang)
    end

    def test_path_lang_query_he
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io?wovn=he'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('he', h.path_lang)
    end

    def test_path_lang_query_he_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io?wovn=HE'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('he', h.path_lang)
    end

    def test_path_lang_query_id
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io?wovn=id'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('id', h.path_lang)
    end

    def test_path_lang_query_id_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io?wovn=ID'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('id', h.path_lang)
    end

    def test_path_lang_query_it
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io?wovn=it'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('it', h.path_lang)
    end

    def test_path_lang_query_it_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io?wovn=IT'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('it', h.path_lang)
    end

    def test_path_lang_query_ja
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io?wovn=ja'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ja', h.path_lang)
    end

    def test_path_lang_query_ja_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io?wovn=JA'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ja', h.path_lang)
    end

    def test_path_lang_query_ko
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io?wovn=ko'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ko', h.path_lang)
    end

    def test_path_lang_query_ko_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io?wovn=KO'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ko', h.path_lang)
    end

    def test_path_lang_query_ms
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io?wovn=ms'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ms', h.path_lang)
    end

    def test_path_lang_query_ms_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io?wovn=MS'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ms', h.path_lang)
    end

    def test_path_lang_query_no
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io?wovn=no'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('no', h.path_lang)
    end

    def test_path_lang_query_no_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io?wovn=NO'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('no', h.path_lang)
    end

    def test_path_lang_query_pl
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io?wovn=pl'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('pl', h.path_lang)
    end

    def test_path_lang_query_pl_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io?wovn=PL'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('pl', h.path_lang)
    end

    def test_path_lang_query_pt
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io?wovn=pt'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('pt', h.path_lang)
    end

    def test_path_lang_query_pt_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io?wovn=PT'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('pt', h.path_lang)
    end

    def test_path_lang_query_ru
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io?wovn=ru'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ru', h.path_lang)
    end

    def test_path_lang_query_ru_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io?wovn=RU'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ru', h.path_lang)
    end

    def test_path_lang_query_es
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io?wovn=es'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('es', h.path_lang)
    end

    def test_path_lang_query_es_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io?wovn=ES'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('es', h.path_lang)
    end

    def test_path_lang_query_sv
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io?wovn=sv'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('sv', h.path_lang)
    end

    def test_path_lang_query_sv_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io?wovn=SV'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('sv', h.path_lang)
    end

    def test_path_lang_query_th
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io?wovn=th'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('th', h.path_lang)
    end

    def test_path_lang_query_th_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io?wovn=TH'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('th', h.path_lang)
    end

    def test_path_lang_query_hi
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io?wovn=hi'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('hi', h.path_lang)
    end

    def test_path_lang_query_hi_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io?wovn=HI'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('hi', h.path_lang)
    end

    def test_path_lang_query_tr
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io?wovn=tr'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('tr', h.path_lang)
    end

    def test_path_lang_query_tr_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io?wovn=TR'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('tr', h.path_lang)
    end

    def test_path_lang_query_uk
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io?wovn=uk'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('uk', h.path_lang)
    end

    def test_path_lang_query_uk_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io?wovn=UK'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('uk', h.path_lang)
    end

    def test_path_lang_query_vi
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io?wovn=vi'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('vi', h.path_lang)
    end

    def test_path_lang_query_vi_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io?wovn=VI'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('vi', h.path_lang)
    end

    def test_path_lang_query_zh_CHS
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io?wovn=zh-CHS'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('zh-CHS', h.path_lang)
    end

    def test_path_lang_query_zh_CHS_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io?wovn=ZH-CHS'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('zh-CHS', h.path_lang)
    end

    def test_path_lang_query_zh_CHS_lowercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io?wovn=zh-chs'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('zh-CHS', h.path_lang)
    end

    def test_path_lang_query_zh_CHT
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io?wovn=zh-CHT'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('zh-CHT', h.path_lang)
    end

    def test_path_lang_query_zh_CHT_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io?wovn=ZH-CHT'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('zh-CHT', h.path_lang)
    end

    def test_path_lang_query_zh_CHT_lowercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io?wovn=zh-cht'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('zh-CHT', h.path_lang)
    end

    def test_path_lang_query_empty_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/?wovn='), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\\?.*&)|\\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('', h.path_lang)
    end

    def test_path_lang_query_ar_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/?wovn=ar'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ar', h.path_lang)
    end

    def test_path_lang_query_ar_uppercase_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/?wovn=AR'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ar', h.path_lang)
    end

    def test_path_lang_query_da_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/?wovn=da'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('da', h.path_lang)
    end

    def test_path_lang_query_da_uppercase_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/?wovn=DA'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('da', h.path_lang)
    end

    def test_path_lang_query_nl_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/?wovn=nl'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('nl', h.path_lang)
    end

    def test_path_lang_query_nl_uppercase_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/?wovn=NL'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('nl', h.path_lang)
    end

    def test_path_lang_query_en_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/?wovn=en'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('en', h.path_lang)
    end

    def test_path_lang_query_en_uppercase_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/?wovn=EN'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('en', h.path_lang)
    end

    def test_path_lang_query_fi_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/?wovn=fi'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('fi', h.path_lang)
    end

    def test_path_lang_query_fi_uppercase_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/?wovn=FI'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('fi', h.path_lang)
    end

    def test_path_lang_query_fr_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/?wovn=fr'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('fr', h.path_lang)
    end

    def test_path_lang_query_fr_uppercase_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/?wovn=FR'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('fr', h.path_lang)
    end

    def test_path_lang_query_de_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/?wovn=de'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('de', h.path_lang)
    end

    def test_path_lang_query_de_uppercase_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/?wovn=DE'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('de', h.path_lang)
    end

    def test_path_lang_query_el_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/?wovn=el'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('el', h.path_lang)
    end

    def test_path_lang_query_el_uppercase_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/?wovn=EL'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('el', h.path_lang)
    end

    def test_path_lang_query_he_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/?wovn=he'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('he', h.path_lang)
    end

    def test_path_lang_query_he_uppercase_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/?wovn=HE'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('he', h.path_lang)
    end

    def test_path_lang_query_id_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/?wovn=id'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('id', h.path_lang)
    end

    def test_path_lang_query_id_uppercase_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/?wovn=ID'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('id', h.path_lang)
    end

    def test_path_lang_query_it_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/?wovn=it'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('it', h.path_lang)
    end

    def test_path_lang_query_it_uppercase_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/?wovn=IT'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('it', h.path_lang)
    end

    def test_path_lang_query_ja_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/?wovn=ja'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ja', h.path_lang)
    end

    def test_path_lang_query_ja_uppercase_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/?wovn=JA'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ja', h.path_lang)
    end

    def test_path_lang_query_ko_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/?wovn=ko'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ko', h.path_lang)
    end

    def test_path_lang_query_ko_uppercase_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/?wovn=KO'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ko', h.path_lang)
    end

    def test_path_lang_query_ms_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/?wovn=ms'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ms', h.path_lang)
    end

    def test_path_lang_query_ms_uppercase_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/?wovn=MS'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ms', h.path_lang)
    end

    def test_path_lang_query_no_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/?wovn=no'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('no', h.path_lang)
    end

    def test_path_lang_query_no_uppercase_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/?wovn=NO'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('no', h.path_lang)
    end

    def test_path_lang_query_pl_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/?wovn=pl'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('pl', h.path_lang)
    end

    def test_path_lang_query_pl_uppercase_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/?wovn=PL'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('pl', h.path_lang)
    end

    def test_path_lang_query_pt_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/?wovn=pt'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('pt', h.path_lang)
    end

    def test_path_lang_query_pt_uppercase_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/?wovn=PT'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('pt', h.path_lang)
    end

    def test_path_lang_query_ru_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/?wovn=ru'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ru', h.path_lang)
    end

    def test_path_lang_query_ru_uppercase_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/?wovn=RU'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ru', h.path_lang)
    end

    def test_path_lang_query_es_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/?wovn=es'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('es', h.path_lang)
    end

    def test_path_lang_query_es_uppercase_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/?wovn=ES'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('es', h.path_lang)
    end

    def test_path_lang_query_sv_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/?wovn=sv'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('sv', h.path_lang)
    end

    def test_path_lang_query_sv_uppercase_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/?wovn=SV'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('sv', h.path_lang)
    end

    def test_path_lang_query_th_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/?wovn=th'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('th', h.path_lang)
    end

    def test_path_lang_query_th_uppercase_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/?wovn=TH'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('th', h.path_lang)
    end

    def test_path_lang_query_hi_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/?wovn=hi'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('hi', h.path_lang)
    end

    def test_path_lang_query_hi_uppercase_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/?wovn=HI'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('hi', h.path_lang)
    end

    def test_path_lang_query_tr_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/?wovn=tr'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('tr', h.path_lang)
    end

    def test_path_lang_query_tr_uppercase_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/?wovn=TR'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('tr', h.path_lang)
    end

    def test_path_lang_query_uk_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/?wovn=uk'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('uk', h.path_lang)
    end

    def test_path_lang_query_uk_uppercase_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/?wovn=UK'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('uk', h.path_lang)
    end

    def test_path_lang_query_vi_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/?wovn=vi'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('vi', h.path_lang)
    end

    def test_path_lang_query_vi_uppercase_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/?wovn=VI'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('vi', h.path_lang)
    end

    def test_path_lang_query_zh_CHS_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/?wovn=zh-CHS'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('zh-CHS', h.path_lang)
    end

    def test_path_lang_query_zh_CHS_uppercase_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/?wovn=ZH-CHS'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('zh-CHS', h.path_lang)
    end

    def test_path_lang_query_zh_CHS_lowercase_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/?wovn=zh-chs'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('zh-CHS', h.path_lang)
    end

    def test_path_lang_query_zh_CHT_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/?wovn=zh-CHT'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('zh-CHT', h.path_lang)
    end

    def test_path_lang_query_zh_CHT_uppercase_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/?wovn=ZH-CHT'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('zh-CHT', h.path_lang)
    end

    def test_path_lang_query_zh_CHT_lowercase_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/?wovn=zh-cht'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('zh-CHT', h.path_lang)
    end

    def test_path_lang_query_empty_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234?wovn='), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\\?.*&)|\\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('', h.path_lang)
    end

    def test_path_lang_query_ar_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234?wovn=ar'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ar', h.path_lang)
    end

    def test_path_lang_query_ar_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234?wovn=AR'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ar', h.path_lang)
    end

    def test_path_lang_query_da_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234?wovn=da'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('da', h.path_lang)
    end

    def test_path_lang_query_da_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234?wovn=DA'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('da', h.path_lang)
    end

    def test_path_lang_query_nl_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234?wovn=nl'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('nl', h.path_lang)
    end

    def test_path_lang_query_nl_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234?wovn=NL'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('nl', h.path_lang)
    end

    def test_path_lang_query_en_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234?wovn=en'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('en', h.path_lang)
    end

    def test_path_lang_query_en_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234?wovn=EN'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('en', h.path_lang)
    end

    def test_path_lang_query_fi_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234?wovn=fi'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('fi', h.path_lang)
    end

    def test_path_lang_query_fi_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234?wovn=FI'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('fi', h.path_lang)
    end

    def test_path_lang_query_fr_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234?wovn=fr'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('fr', h.path_lang)
    end

    def test_path_lang_query_fr_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234?wovn=FR'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('fr', h.path_lang)
    end

    def test_path_lang_query_de_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234?wovn=de'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('de', h.path_lang)
    end

    def test_path_lang_query_de_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234?wovn=DE'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('de', h.path_lang)
    end

    def test_path_lang_query_el_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234?wovn=el'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('el', h.path_lang)
    end

    def test_path_lang_query_el_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234?wovn=EL'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('el', h.path_lang)
    end

    def test_path_lang_query_he_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234?wovn=he'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('he', h.path_lang)
    end

    def test_path_lang_query_he_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234?wovn=HE'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('he', h.path_lang)
    end

    def test_path_lang_query_id_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234?wovn=id'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('id', h.path_lang)
    end

    def test_path_lang_query_id_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234?wovn=ID'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('id', h.path_lang)
    end

    def test_path_lang_query_it_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234?wovn=it'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('it', h.path_lang)
    end

    def test_path_lang_query_it_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234?wovn=IT'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('it', h.path_lang)
    end

    def test_path_lang_query_ja_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234?wovn=ja'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ja', h.path_lang)
    end

    def test_path_lang_query_ja_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234?wovn=JA'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ja', h.path_lang)
    end

    def test_path_lang_query_ko_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234?wovn=ko'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ko', h.path_lang)
    end

    def test_path_lang_query_ko_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234?wovn=KO'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ko', h.path_lang)
    end

    def test_path_lang_query_ms_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234?wovn=ms'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ms', h.path_lang)
    end

    def test_path_lang_query_ms_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234?wovn=MS'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ms', h.path_lang)
    end

    def test_path_lang_query_no_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234?wovn=no'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('no', h.path_lang)
    end

    def test_path_lang_query_no_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234?wovn=NO'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('no', h.path_lang)
    end

    def test_path_lang_query_pl_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234?wovn=pl'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('pl', h.path_lang)
    end

    def test_path_lang_query_pl_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234?wovn=PL'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('pl', h.path_lang)
    end

    def test_path_lang_query_pt_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234?wovn=pt'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('pt', h.path_lang)
    end

    def test_path_lang_query_pt_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234?wovn=PT'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('pt', h.path_lang)
    end

    def test_path_lang_query_ru_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234?wovn=ru'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ru', h.path_lang)
    end

    def test_path_lang_query_ru_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234?wovn=RU'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ru', h.path_lang)
    end

    def test_path_lang_query_es_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234?wovn=es'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('es', h.path_lang)
    end

    def test_path_lang_query_es_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234?wovn=ES'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('es', h.path_lang)
    end

    def test_path_lang_query_sv_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234?wovn=sv'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('sv', h.path_lang)
    end

    def test_path_lang_query_sv_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234?wovn=SV'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('sv', h.path_lang)
    end

    def test_path_lang_query_th_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234?wovn=th'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('th', h.path_lang)
    end

    def test_path_lang_query_th_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234?wovn=TH'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('th', h.path_lang)
    end

    def test_path_lang_query_hi_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234?wovn=hi'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('hi', h.path_lang)
    end

    def test_path_lang_query_hi_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234?wovn=HI'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('hi', h.path_lang)
    end

    def test_path_lang_query_tr_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234?wovn=tr'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('tr', h.path_lang)
    end

    def test_path_lang_query_tr_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234?wovn=TR'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('tr', h.path_lang)
    end

    def test_path_lang_query_uk_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234?wovn=uk'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('uk', h.path_lang)
    end

    def test_path_lang_query_uk_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234?wovn=UK'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('uk', h.path_lang)
    end

    def test_path_lang_query_vi_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234?wovn=vi'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('vi', h.path_lang)
    end

    def test_path_lang_query_vi_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234?wovn=VI'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('vi', h.path_lang)
    end

    def test_path_lang_query_zh_CHS_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234?wovn=zh-CHS'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('zh-CHS', h.path_lang)
    end

    def test_path_lang_query_zh_CHS_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234?wovn=ZH-CHS'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('zh-CHS', h.path_lang)
    end

    def test_path_lang_query_zh_CHS_lowercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234?wovn=zh-chs'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('zh-CHS', h.path_lang)
    end

    def test_path_lang_query_zh_CHT_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234?wovn=zh-CHT'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('zh-CHT', h.path_lang)
    end

    def test_path_lang_query_zh_CHT_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234?wovn=ZH-CHT'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('zh-CHT', h.path_lang)
    end

    def test_path_lang_query_zh_CHT_lowercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234?wovn=zh-cht'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('zh-CHT', h.path_lang)
    end

    def test_path_lang_query_empty_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/?wovn='), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\\?.*&)|\\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('', h.path_lang)
    end

    def test_path_lang_query_ar_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/?wovn=ar'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ar', h.path_lang)
    end

    def test_path_lang_query_ar_uppercase_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/?wovn=AR'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ar', h.path_lang)
    end

    def test_path_lang_query_da_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/?wovn=da'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('da', h.path_lang)
    end

    def test_path_lang_query_da_uppercase_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/?wovn=DA'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('da', h.path_lang)
    end

    def test_path_lang_query_nl_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/?wovn=nl'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('nl', h.path_lang)
    end

    def test_path_lang_query_nl_uppercase_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/?wovn=NL'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('nl', h.path_lang)
    end

    def test_path_lang_query_en_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/?wovn=en'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('en', h.path_lang)
    end

    def test_path_lang_query_en_uppercase_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/?wovn=EN'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('en', h.path_lang)
    end

    def test_path_lang_query_fi_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/?wovn=fi'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('fi', h.path_lang)
    end

    def test_path_lang_query_fi_uppercase_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/?wovn=FI'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('fi', h.path_lang)
    end

    def test_path_lang_query_fr_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/?wovn=fr'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('fr', h.path_lang)
    end

    def test_path_lang_query_fr_uppercase_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/?wovn=FR'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('fr', h.path_lang)
    end

    def test_path_lang_query_de_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/?wovn=de'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('de', h.path_lang)
    end

    def test_path_lang_query_de_uppercase_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/?wovn=DE'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('de', h.path_lang)
    end

    def test_path_lang_query_el_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/?wovn=el'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('el', h.path_lang)
    end

    def test_path_lang_query_el_uppercase_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/?wovn=EL'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('el', h.path_lang)
    end

    def test_path_lang_query_he_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/?wovn=he'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('he', h.path_lang)
    end

    def test_path_lang_query_he_uppercase_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/?wovn=HE'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('he', h.path_lang)
    end

    def test_path_lang_query_id_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/?wovn=id'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('id', h.path_lang)
    end

    def test_path_lang_query_id_uppercase_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/?wovn=ID'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('id', h.path_lang)
    end

    def test_path_lang_query_it_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/?wovn=it'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('it', h.path_lang)
    end

    def test_path_lang_query_it_uppercase_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/?wovn=IT'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('it', h.path_lang)
    end

    def test_path_lang_query_ja_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/?wovn=ja'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ja', h.path_lang)
    end

    def test_path_lang_query_ja_uppercase_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/?wovn=JA'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ja', h.path_lang)
    end

    def test_path_lang_query_ko_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/?wovn=ko'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ko', h.path_lang)
    end

    def test_path_lang_query_ko_uppercase_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/?wovn=KO'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ko', h.path_lang)
    end

    def test_path_lang_query_ms_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/?wovn=ms'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ms', h.path_lang)
    end

    def test_path_lang_query_ms_uppercase_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/?wovn=MS'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ms', h.path_lang)
    end

    def test_path_lang_query_no_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/?wovn=no'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('no', h.path_lang)
    end

    def test_path_lang_query_no_uppercase_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/?wovn=NO'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('no', h.path_lang)
    end

    def test_path_lang_query_pl_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/?wovn=pl'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('pl', h.path_lang)
    end

    def test_path_lang_query_pl_uppercase_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/?wovn=PL'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('pl', h.path_lang)
    end

    def test_path_lang_query_pt_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/?wovn=pt'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('pt', h.path_lang)
    end

    def test_path_lang_query_pt_uppercase_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/?wovn=PT'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('pt', h.path_lang)
    end

    def test_path_lang_query_ru_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/?wovn=ru'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ru', h.path_lang)
    end

    def test_path_lang_query_ru_uppercase_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/?wovn=RU'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ru', h.path_lang)
    end

    def test_path_lang_query_es_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/?wovn=es'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('es', h.path_lang)
    end

    def test_path_lang_query_es_uppercase_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/?wovn=ES'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('es', h.path_lang)
    end

    def test_path_lang_query_sv_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/?wovn=sv'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('sv', h.path_lang)
    end

    def test_path_lang_query_sv_uppercase_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/?wovn=SV'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('sv', h.path_lang)
    end

    def test_path_lang_query_th_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/?wovn=th'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('th', h.path_lang)
    end

    def test_path_lang_query_th_uppercase_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/?wovn=TH'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('th', h.path_lang)
    end

    def test_path_lang_query_hi_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/?wovn=hi'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('hi', h.path_lang)
    end

    def test_path_lang_query_hi_uppercase_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/?wovn=HI'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('hi', h.path_lang)
    end

    def test_path_lang_query_tr_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/?wovn=tr'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('tr', h.path_lang)
    end

    def test_path_lang_query_tr_uppercase_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/?wovn=TR'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('tr', h.path_lang)
    end

    def test_path_lang_query_uk_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/?wovn=uk'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('uk', h.path_lang)
    end

    def test_path_lang_query_uk_uppercase_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/?wovn=UK'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('uk', h.path_lang)
    end

    def test_path_lang_query_vi_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/?wovn=vi'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('vi', h.path_lang)
    end

    def test_path_lang_query_vi_uppercase_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/?wovn=VI'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('vi', h.path_lang)
    end

    def test_path_lang_query_zh_CHS_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/?wovn=zh-CHS'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('zh-CHS', h.path_lang)
    end

    def test_path_lang_query_zh_CHS_uppercase_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/?wovn=ZH-CHS'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('zh-CHS', h.path_lang)
    end

    def test_path_lang_query_zh_CHS_lowercase_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/?wovn=zh-chs'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('zh-CHS', h.path_lang)
    end

    def test_path_lang_query_zh_CHT_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/?wovn=zh-CHT'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('zh-CHT', h.path_lang)
    end

    def test_path_lang_query_zh_CHT_uppercase_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/?wovn=ZH-CHT'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('zh-CHT', h.path_lang)
    end

    def test_path_lang_query_zh_CHT_lowercase_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/?wovn=zh-cht'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('zh-CHT', h.path_lang)
    end

    def test_path_lang_query_empty_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io?wovn='), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\\?.*&)|\\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('', h.path_lang)
    end

    def test_path_lang_query_ar_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io?wovn=ar'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ar', h.path_lang)
    end

    def test_path_lang_query_ar_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io?wovn=AR'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ar', h.path_lang)
    end

    def test_path_lang_query_da_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io?wovn=da'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('da', h.path_lang)
    end

    def test_path_lang_query_da_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io?wovn=DA'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('da', h.path_lang)
    end

    def test_path_lang_query_nl_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io?wovn=nl'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('nl', h.path_lang)
    end

    def test_path_lang_query_nl_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io?wovn=NL'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('nl', h.path_lang)
    end

    def test_path_lang_query_en_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io?wovn=en'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('en', h.path_lang)
    end

    def test_path_lang_query_en_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io?wovn=EN'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('en', h.path_lang)
    end

    def test_path_lang_query_fi_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io?wovn=fi'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('fi', h.path_lang)
    end

    def test_path_lang_query_fi_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io?wovn=FI'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('fi', h.path_lang)
    end

    def test_path_lang_query_fr_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io?wovn=fr'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('fr', h.path_lang)
    end

    def test_path_lang_query_fr_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io?wovn=FR'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('fr', h.path_lang)
    end

    def test_path_lang_query_de_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io?wovn=de'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('de', h.path_lang)
    end

    def test_path_lang_query_de_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io?wovn=DE'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('de', h.path_lang)
    end

    def test_path_lang_query_el_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io?wovn=el'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('el', h.path_lang)
    end

    def test_path_lang_query_el_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io?wovn=EL'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('el', h.path_lang)
    end

    def test_path_lang_query_he_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io?wovn=he'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('he', h.path_lang)
    end

    def test_path_lang_query_he_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io?wovn=HE'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('he', h.path_lang)
    end

    def test_path_lang_query_id_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io?wovn=id'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('id', h.path_lang)
    end

    def test_path_lang_query_id_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io?wovn=ID'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('id', h.path_lang)
    end

    def test_path_lang_query_it_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io?wovn=it'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('it', h.path_lang)
    end

    def test_path_lang_query_it_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io?wovn=IT'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('it', h.path_lang)
    end

    def test_path_lang_query_ja_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io?wovn=ja'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ja', h.path_lang)
    end

    def test_path_lang_query_ja_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io?wovn=JA'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ja', h.path_lang)
    end

    def test_path_lang_query_ko_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io?wovn=ko'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ko', h.path_lang)
    end

    def test_path_lang_query_ko_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io?wovn=KO'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ko', h.path_lang)
    end

    def test_path_lang_query_ms_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io?wovn=ms'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ms', h.path_lang)
    end

    def test_path_lang_query_ms_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io?wovn=MS'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ms', h.path_lang)
    end

    def test_path_lang_query_no_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io?wovn=no'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('no', h.path_lang)
    end

    def test_path_lang_query_no_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io?wovn=NO'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('no', h.path_lang)
    end

    def test_path_lang_query_pl_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io?wovn=pl'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('pl', h.path_lang)
    end

    def test_path_lang_query_pl_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io?wovn=PL'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('pl', h.path_lang)
    end

    def test_path_lang_query_pt_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io?wovn=pt'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('pt', h.path_lang)
    end

    def test_path_lang_query_pt_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io?wovn=PT'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('pt', h.path_lang)
    end

    def test_path_lang_query_ru_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io?wovn=ru'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ru', h.path_lang)
    end

    def test_path_lang_query_ru_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io?wovn=RU'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ru', h.path_lang)
    end

    def test_path_lang_query_es_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io?wovn=es'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('es', h.path_lang)
    end

    def test_path_lang_query_es_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io?wovn=ES'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('es', h.path_lang)
    end

    def test_path_lang_query_sv_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io?wovn=sv'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('sv', h.path_lang)
    end

    def test_path_lang_query_sv_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io?wovn=SV'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('sv', h.path_lang)
    end

    def test_path_lang_query_th_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io?wovn=th'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('th', h.path_lang)
    end

    def test_path_lang_query_th_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io?wovn=TH'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('th', h.path_lang)
    end

    def test_path_lang_query_hi_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io?wovn=hi'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('hi', h.path_lang)
    end

    def test_path_lang_query_hi_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io?wovn=HI'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('hi', h.path_lang)
    end

    def test_path_lang_query_tr_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io?wovn=tr'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('tr', h.path_lang)
    end

    def test_path_lang_query_tr_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io?wovn=TR'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('tr', h.path_lang)
    end

    def test_path_lang_query_uk_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io?wovn=uk'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('uk', h.path_lang)
    end

    def test_path_lang_query_uk_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io?wovn=UK'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('uk', h.path_lang)
    end

    def test_path_lang_query_vi_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io?wovn=vi'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('vi', h.path_lang)
    end

    def test_path_lang_query_vi_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io?wovn=VI'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('vi', h.path_lang)
    end

    def test_path_lang_query_zh_CHS_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io?wovn=zh-CHS'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('zh-CHS', h.path_lang)
    end

    def test_path_lang_query_zh_CHS_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io?wovn=ZH-CHS'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('zh-CHS', h.path_lang)
    end

    def test_path_lang_query_zh_CHS_lowercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io?wovn=zh-chs'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('zh-CHS', h.path_lang)
    end

    def test_path_lang_query_zh_CHT_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io?wovn=zh-CHT'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('zh-CHT', h.path_lang)
    end

    def test_path_lang_query_zh_CHT_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io?wovn=ZH-CHT'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('zh-CHT', h.path_lang)
    end

    def test_path_lang_query_zh_CHT_lowercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io?wovn=zh-cht'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('zh-CHT', h.path_lang)
    end

    def test_path_lang_query_empty_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/?wovn='), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\\?.*&)|\\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('', h.path_lang)
    end

    def test_path_lang_query_ar_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/?wovn=ar'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ar', h.path_lang)
    end

    def test_path_lang_query_ar_uppercase_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/?wovn=AR'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ar', h.path_lang)
    end

    def test_path_lang_query_da_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/?wovn=da'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('da', h.path_lang)
    end

    def test_path_lang_query_da_uppercase_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/?wovn=DA'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('da', h.path_lang)
    end

    def test_path_lang_query_nl_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/?wovn=nl'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('nl', h.path_lang)
    end

    def test_path_lang_query_nl_uppercase_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/?wovn=NL'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('nl', h.path_lang)
    end

    def test_path_lang_query_en_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/?wovn=en'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('en', h.path_lang)
    end

    def test_path_lang_query_en_uppercase_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/?wovn=EN'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('en', h.path_lang)
    end

    def test_path_lang_query_fi_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/?wovn=fi'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('fi', h.path_lang)
    end

    def test_path_lang_query_fi_uppercase_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/?wovn=FI'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('fi', h.path_lang)
    end

    def test_path_lang_query_fr_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/?wovn=fr'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('fr', h.path_lang)
    end

    def test_path_lang_query_fr_uppercase_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/?wovn=FR'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('fr', h.path_lang)
    end

    def test_path_lang_query_de_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/?wovn=de'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('de', h.path_lang)
    end

    def test_path_lang_query_de_uppercase_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/?wovn=DE'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('de', h.path_lang)
    end

    def test_path_lang_query_el_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/?wovn=el'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('el', h.path_lang)
    end

    def test_path_lang_query_el_uppercase_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/?wovn=EL'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('el', h.path_lang)
    end

    def test_path_lang_query_he_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/?wovn=he'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('he', h.path_lang)
    end

    def test_path_lang_query_he_uppercase_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/?wovn=HE'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('he', h.path_lang)
    end

    def test_path_lang_query_id_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/?wovn=id'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('id', h.path_lang)
    end

    def test_path_lang_query_id_uppercase_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/?wovn=ID'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('id', h.path_lang)
    end

    def test_path_lang_query_it_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/?wovn=it'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('it', h.path_lang)
    end

    def test_path_lang_query_it_uppercase_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/?wovn=IT'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('it', h.path_lang)
    end

    def test_path_lang_query_ja_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/?wovn=ja'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ja', h.path_lang)
    end

    def test_path_lang_query_ja_uppercase_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/?wovn=JA'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ja', h.path_lang)
    end

    def test_path_lang_query_ko_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/?wovn=ko'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ko', h.path_lang)
    end

    def test_path_lang_query_ko_uppercase_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/?wovn=KO'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ko', h.path_lang)
    end

    def test_path_lang_query_ms_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/?wovn=ms'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ms', h.path_lang)
    end

    def test_path_lang_query_ms_uppercase_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/?wovn=MS'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ms', h.path_lang)
    end

    def test_path_lang_query_no_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/?wovn=no'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('no', h.path_lang)
    end

    def test_path_lang_query_no_uppercase_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/?wovn=NO'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('no', h.path_lang)
    end

    def test_path_lang_query_pl_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/?wovn=pl'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('pl', h.path_lang)
    end

    def test_path_lang_query_pl_uppercase_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/?wovn=PL'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('pl', h.path_lang)
    end

    def test_path_lang_query_pt_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/?wovn=pt'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('pt', h.path_lang)
    end

    def test_path_lang_query_pt_uppercase_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/?wovn=PT'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('pt', h.path_lang)
    end

    def test_path_lang_query_ru_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/?wovn=ru'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ru', h.path_lang)
    end

    def test_path_lang_query_ru_uppercase_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/?wovn=RU'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ru', h.path_lang)
    end

    def test_path_lang_query_es_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/?wovn=es'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('es', h.path_lang)
    end

    def test_path_lang_query_es_uppercase_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/?wovn=ES'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('es', h.path_lang)
    end

    def test_path_lang_query_sv_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/?wovn=sv'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('sv', h.path_lang)
    end

    def test_path_lang_query_sv_uppercase_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/?wovn=SV'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('sv', h.path_lang)
    end

    def test_path_lang_query_th_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/?wovn=th'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('th', h.path_lang)
    end

    def test_path_lang_query_th_uppercase_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/?wovn=TH'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('th', h.path_lang)
    end

    def test_path_lang_query_hi_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/?wovn=hi'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('hi', h.path_lang)
    end

    def test_path_lang_query_hi_uppercase_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/?wovn=HI'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('hi', h.path_lang)
    end

    def test_path_lang_query_tr_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/?wovn=tr'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('tr', h.path_lang)
    end

    def test_path_lang_query_tr_uppercase_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/?wovn=TR'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('tr', h.path_lang)
    end

    def test_path_lang_query_uk_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/?wovn=uk'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('uk', h.path_lang)
    end

    def test_path_lang_query_uk_uppercase_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/?wovn=UK'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('uk', h.path_lang)
    end

    def test_path_lang_query_vi_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/?wovn=vi'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('vi', h.path_lang)
    end

    def test_path_lang_query_vi_uppercase_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/?wovn=VI'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('vi', h.path_lang)
    end

    def test_path_lang_query_zh_CHS_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/?wovn=zh-CHS'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('zh-CHS', h.path_lang)
    end

    def test_path_lang_query_zh_CHS_uppercase_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/?wovn=ZH-CHS'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('zh-CHS', h.path_lang)
    end

    def test_path_lang_query_zh_CHS_lowercase_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/?wovn=zh-chs'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('zh-CHS', h.path_lang)
    end

    def test_path_lang_query_zh_CHT_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/?wovn=zh-CHT'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('zh-CHT', h.path_lang)
    end

    def test_path_lang_query_zh_CHT_uppercase_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/?wovn=ZH-CHT'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('zh-CHT', h.path_lang)
    end

    def test_path_lang_query_zh_CHT_lowercase_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/?wovn=zh-cht'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('zh-CHT', h.path_lang)
    end

    def test_path_lang_query_empty_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234?wovn='), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\\?.*&)|\\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('', h.path_lang)
    end

    def test_path_lang_query_ar_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234?wovn=ar'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ar', h.path_lang)
    end

    def test_path_lang_query_ar_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234?wovn=AR'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ar', h.path_lang)
    end

    def test_path_lang_query_da_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234?wovn=da'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('da', h.path_lang)
    end

    def test_path_lang_query_da_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234?wovn=DA'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('da', h.path_lang)
    end

    def test_path_lang_query_nl_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234?wovn=nl'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('nl', h.path_lang)
    end

    def test_path_lang_query_nl_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234?wovn=NL'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('nl', h.path_lang)
    end

    def test_path_lang_query_en_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234?wovn=en'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('en', h.path_lang)
    end

    def test_path_lang_query_en_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234?wovn=EN'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('en', h.path_lang)
    end

    def test_path_lang_query_fi_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234?wovn=fi'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('fi', h.path_lang)
    end

    def test_path_lang_query_fi_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234?wovn=FI'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('fi', h.path_lang)
    end

    def test_path_lang_query_fr_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234?wovn=fr'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('fr', h.path_lang)
    end

    def test_path_lang_query_fr_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234?wovn=FR'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('fr', h.path_lang)
    end

    def test_path_lang_query_de_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234?wovn=de'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('de', h.path_lang)
    end

    def test_path_lang_query_de_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234?wovn=DE'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('de', h.path_lang)
    end

    def test_path_lang_query_el_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234?wovn=el'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('el', h.path_lang)
    end

    def test_path_lang_query_el_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234?wovn=EL'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('el', h.path_lang)
    end

    def test_path_lang_query_he_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234?wovn=he'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('he', h.path_lang)
    end

    def test_path_lang_query_he_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234?wovn=HE'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('he', h.path_lang)
    end

    def test_path_lang_query_id_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234?wovn=id'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('id', h.path_lang)
    end

    def test_path_lang_query_id_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234?wovn=ID'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('id', h.path_lang)
    end

    def test_path_lang_query_it_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234?wovn=it'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('it', h.path_lang)
    end

    def test_path_lang_query_it_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234?wovn=IT'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('it', h.path_lang)
    end

    def test_path_lang_query_ja_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234?wovn=ja'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ja', h.path_lang)
    end

    def test_path_lang_query_ja_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234?wovn=JA'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ja', h.path_lang)
    end

    def test_path_lang_query_ko_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234?wovn=ko'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ko', h.path_lang)
    end

    def test_path_lang_query_ko_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234?wovn=KO'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ko', h.path_lang)
    end

    def test_path_lang_query_ms_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234?wovn=ms'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ms', h.path_lang)
    end

    def test_path_lang_query_ms_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234?wovn=MS'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ms', h.path_lang)
    end

    def test_path_lang_query_no_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234?wovn=no'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('no', h.path_lang)
    end

    def test_path_lang_query_no_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234?wovn=NO'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('no', h.path_lang)
    end

    def test_path_lang_query_pl_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234?wovn=pl'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('pl', h.path_lang)
    end

    def test_path_lang_query_pl_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234?wovn=PL'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('pl', h.path_lang)
    end

    def test_path_lang_query_pt_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234?wovn=pt'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('pt', h.path_lang)
    end

    def test_path_lang_query_pt_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234?wovn=PT'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('pt', h.path_lang)
    end

    def test_path_lang_query_ru_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234?wovn=ru'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ru', h.path_lang)
    end

    def test_path_lang_query_ru_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234?wovn=RU'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ru', h.path_lang)
    end

    def test_path_lang_query_es_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234?wovn=es'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('es', h.path_lang)
    end

    def test_path_lang_query_es_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234?wovn=ES'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('es', h.path_lang)
    end

    def test_path_lang_query_sv_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234?wovn=sv'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('sv', h.path_lang)
    end

    def test_path_lang_query_sv_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234?wovn=SV'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('sv', h.path_lang)
    end

    def test_path_lang_query_th_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234?wovn=th'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('th', h.path_lang)
    end

    def test_path_lang_query_th_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234?wovn=TH'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('th', h.path_lang)
    end

    def test_path_lang_query_hi_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234?wovn=hi'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('hi', h.path_lang)
    end

    def test_path_lang_query_hi_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234?wovn=HI'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('hi', h.path_lang)
    end

    def test_path_lang_query_tr_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234?wovn=tr'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('tr', h.path_lang)
    end

    def test_path_lang_query_tr_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234?wovn=TR'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('tr', h.path_lang)
    end

    def test_path_lang_query_uk_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234?wovn=uk'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('uk', h.path_lang)
    end

    def test_path_lang_query_uk_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234?wovn=UK'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('uk', h.path_lang)
    end

    def test_path_lang_query_vi_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234?wovn=vi'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('vi', h.path_lang)
    end

    def test_path_lang_query_vi_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234?wovn=VI'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('vi', h.path_lang)
    end

    def test_path_lang_query_zh_CHS_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234?wovn=zh-CHS'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('zh-CHS', h.path_lang)
    end

    def test_path_lang_query_zh_CHS_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234?wovn=ZH-CHS'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('zh-CHS', h.path_lang)
    end

    def test_path_lang_query_zh_CHS_lowercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234?wovn=zh-chs'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('zh-CHS', h.path_lang)
    end

    def test_path_lang_query_zh_CHT_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234?wovn=zh-CHT'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('zh-CHT', h.path_lang)
    end

    def test_path_lang_query_zh_CHT_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234?wovn=ZH-CHT'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('zh-CHT', h.path_lang)
    end

    def test_path_lang_query_zh_CHT_lowercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234?wovn=zh-cht'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('zh-CHT', h.path_lang)
    end

    def test_path_lang_query_empty_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/?wovn='), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\\?.*&)|\\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('', h.path_lang)
    end

    def test_path_lang_query_ar_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/?wovn=ar'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ar', h.path_lang)
    end

    def test_path_lang_query_ar_uppercase_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/?wovn=AR'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ar', h.path_lang)
    end

    def test_path_lang_query_da_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/?wovn=da'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('da', h.path_lang)
    end

    def test_path_lang_query_da_uppercase_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/?wovn=DA'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('da', h.path_lang)
    end

    def test_path_lang_query_nl_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/?wovn=nl'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('nl', h.path_lang)
    end

    def test_path_lang_query_nl_uppercase_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/?wovn=NL'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('nl', h.path_lang)
    end

    def test_path_lang_query_en_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/?wovn=en'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('en', h.path_lang)
    end

    def test_path_lang_query_en_uppercase_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/?wovn=EN'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('en', h.path_lang)
    end

    def test_path_lang_query_fi_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/?wovn=fi'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('fi', h.path_lang)
    end

    def test_path_lang_query_fi_uppercase_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/?wovn=FI'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('fi', h.path_lang)
    end

    def test_path_lang_query_fr_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/?wovn=fr'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('fr', h.path_lang)
    end

    def test_path_lang_query_fr_uppercase_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/?wovn=FR'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('fr', h.path_lang)
    end

    def test_path_lang_query_de_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/?wovn=de'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('de', h.path_lang)
    end

    def test_path_lang_query_de_uppercase_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/?wovn=DE'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('de', h.path_lang)
    end

    def test_path_lang_query_el_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/?wovn=el'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('el', h.path_lang)
    end

    def test_path_lang_query_el_uppercase_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/?wovn=EL'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('el', h.path_lang)
    end

    def test_path_lang_query_he_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/?wovn=he'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('he', h.path_lang)
    end

    def test_path_lang_query_he_uppercase_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/?wovn=HE'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('he', h.path_lang)
    end

    def test_path_lang_query_id_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/?wovn=id'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('id', h.path_lang)
    end

    def test_path_lang_query_id_uppercase_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/?wovn=ID'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('id', h.path_lang)
    end

    def test_path_lang_query_it_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/?wovn=it'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('it', h.path_lang)
    end

    def test_path_lang_query_it_uppercase_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/?wovn=IT'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('it', h.path_lang)
    end

    def test_path_lang_query_ja_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/?wovn=ja'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ja', h.path_lang)
    end

    def test_path_lang_query_ja_uppercase_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/?wovn=JA'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ja', h.path_lang)
    end

    def test_path_lang_query_ko_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/?wovn=ko'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ko', h.path_lang)
    end

    def test_path_lang_query_ko_uppercase_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/?wovn=KO'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ko', h.path_lang)
    end

    def test_path_lang_query_ms_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/?wovn=ms'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ms', h.path_lang)
    end

    def test_path_lang_query_ms_uppercase_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/?wovn=MS'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ms', h.path_lang)
    end

    def test_path_lang_query_no_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/?wovn=no'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('no', h.path_lang)
    end

    def test_path_lang_query_no_uppercase_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/?wovn=NO'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('no', h.path_lang)
    end

    def test_path_lang_query_pl_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/?wovn=pl'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('pl', h.path_lang)
    end

    def test_path_lang_query_pl_uppercase_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/?wovn=PL'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('pl', h.path_lang)
    end

    def test_path_lang_query_pt_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/?wovn=pt'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('pt', h.path_lang)
    end

    def test_path_lang_query_pt_uppercase_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/?wovn=PT'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('pt', h.path_lang)
    end

    def test_path_lang_query_ru_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/?wovn=ru'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ru', h.path_lang)
    end

    def test_path_lang_query_ru_uppercase_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/?wovn=RU'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('ru', h.path_lang)
    end

    def test_path_lang_query_es_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/?wovn=es'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('es', h.path_lang)
    end

    def test_path_lang_query_es_uppercase_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/?wovn=ES'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('es', h.path_lang)
    end

    def test_path_lang_query_sv_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/?wovn=sv'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('sv', h.path_lang)
    end

    def test_path_lang_query_sv_uppercase_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/?wovn=SV'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('sv', h.path_lang)
    end

    def test_path_lang_query_th_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/?wovn=th'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('th', h.path_lang)
    end

    def test_path_lang_query_th_uppercase_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/?wovn=TH'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('th', h.path_lang)
    end

    def test_path_lang_query_hi_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/?wovn=hi'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('hi', h.path_lang)
    end

    def test_path_lang_query_hi_uppercase_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/?wovn=HI'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('hi', h.path_lang)
    end

    def test_path_lang_query_tr_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/?wovn=tr'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('tr', h.path_lang)
    end

    def test_path_lang_query_tr_uppercase_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/?wovn=TR'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('tr', h.path_lang)
    end

    def test_path_lang_query_uk_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/?wovn=uk'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('uk', h.path_lang)
    end

    def test_path_lang_query_uk_uppercase_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/?wovn=UK'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('uk', h.path_lang)
    end

    def test_path_lang_query_vi_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/?wovn=vi'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('vi', h.path_lang)
    end

    def test_path_lang_query_vi_uppercase_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/?wovn=VI'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('vi', h.path_lang)
    end

    def test_path_lang_query_zh_CHS_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/?wovn=zh-CHS'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('zh-CHS', h.path_lang)
    end

    def test_path_lang_query_zh_CHS_uppercase_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/?wovn=ZH-CHS'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('zh-CHS', h.path_lang)
    end

    def test_path_lang_query_zh_CHS_lowercase_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/?wovn=zh-chs'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('zh-CHS', h.path_lang)
    end

    def test_path_lang_query_zh_CHT_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/?wovn=zh-CHT'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('zh-CHT', h.path_lang)
    end

    def test_path_lang_query_zh_CHT_uppercase_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/?wovn=ZH-CHT'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('zh-CHT', h.path_lang)
    end

    def test_path_lang_query_zh_CHT_lowercase_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/?wovn=zh-cht'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'))
      assert_equal('zh-CHT', h.path_lang)
    end

    #########################
    # PATH LANG: PATH
    #########################

    def test_path_lang_path_empty
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io'), Wovnrb.get_settings)
      assert_equal('', h.path_lang)
    end

    def test_path_lang_path_empty_with_slash
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/'), Wovnrb.get_settings)
      assert_equal('', h.path_lang)
    end

    def test_path_lang_path_ar
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/ar'), Wovnrb.get_settings)
      assert_equal('ar', h.path_lang)
    end

    def test_path_lang_path_ar_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/AR'), Wovnrb.get_settings)
      assert_equal('ar', h.path_lang)
    end

    def test_path_lang_path_da
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/da'), Wovnrb.get_settings)
      assert_equal('da', h.path_lang)
    end

    def test_path_lang_path_da_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/DA'), Wovnrb.get_settings)
      assert_equal('da', h.path_lang)
    end

    def test_path_lang_path_nl
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/nl'), Wovnrb.get_settings)
      assert_equal('nl', h.path_lang)
    end

    def test_path_lang_path_nl_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/NL'), Wovnrb.get_settings)
      assert_equal('nl', h.path_lang)
    end

    def test_path_lang_path_en
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/en'), Wovnrb.get_settings)
      assert_equal('en', h.path_lang)
    end

    def test_path_lang_path_en_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/EN'), Wovnrb.get_settings)
      assert_equal('en', h.path_lang)
    end

    def test_path_lang_path_fi
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/fi'), Wovnrb.get_settings)
      assert_equal('fi', h.path_lang)
    end

    def test_path_lang_path_fi_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/FI'), Wovnrb.get_settings)
      assert_equal('fi', h.path_lang)
    end

    def test_path_lang_path_fr
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/fr'), Wovnrb.get_settings)
      assert_equal('fr', h.path_lang)
    end

    def test_path_lang_path_fr_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/FR'), Wovnrb.get_settings)
      assert_equal('fr', h.path_lang)
    end

    def test_path_lang_path_de
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/de'), Wovnrb.get_settings)
      assert_equal('de', h.path_lang)
    end

    def test_path_lang_path_de_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/DE'), Wovnrb.get_settings)
      assert_equal('de', h.path_lang)
    end

    def test_path_lang_path_el
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/el'), Wovnrb.get_settings)
      assert_equal('el', h.path_lang)
    end

    def test_path_lang_path_el_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/EL'), Wovnrb.get_settings)
      assert_equal('el', h.path_lang)
    end

    def test_path_lang_path_he
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/he'), Wovnrb.get_settings)
      assert_equal('he', h.path_lang)
    end

    def test_path_lang_path_he_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/HE'), Wovnrb.get_settings)
      assert_equal('he', h.path_lang)
    end

    def test_path_lang_path_id
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/id'), Wovnrb.get_settings)
      assert_equal('id', h.path_lang)
    end

    def test_path_lang_path_id_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/ID'), Wovnrb.get_settings)
      assert_equal('id', h.path_lang)
    end

    def test_path_lang_path_it
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/it'), Wovnrb.get_settings)
      assert_equal('it', h.path_lang)
    end

    def test_path_lang_path_it_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/IT'), Wovnrb.get_settings)
      assert_equal('it', h.path_lang)
    end

    def test_path_lang_path_ja
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/ja'), Wovnrb.get_settings)
      assert_equal('ja', h.path_lang)
    end

    def test_path_lang_path_ja_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/JA'), Wovnrb.get_settings)
      assert_equal('ja', h.path_lang)
    end

    def test_path_lang_path_ko
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/ko'), Wovnrb.get_settings)
      assert_equal('ko', h.path_lang)
    end

    def test_path_lang_path_ko_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/KO'), Wovnrb.get_settings)
      assert_equal('ko', h.path_lang)
    end

    def test_path_lang_path_ms
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/ms'), Wovnrb.get_settings)
      assert_equal('ms', h.path_lang)
    end

    def test_path_lang_path_ms_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/MS'), Wovnrb.get_settings)
      assert_equal('ms', h.path_lang)
    end

    def test_path_lang_path_no
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/no'), Wovnrb.get_settings)
      assert_equal('no', h.path_lang)
    end

    def test_path_lang_path_no_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/NO'), Wovnrb.get_settings)
      assert_equal('no', h.path_lang)
    end

    def test_path_lang_path_pl
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/pl'), Wovnrb.get_settings)
      assert_equal('pl', h.path_lang)
    end

    def test_path_lang_path_pl_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/PL'), Wovnrb.get_settings)
      assert_equal('pl', h.path_lang)
    end

    def test_path_lang_path_pt
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/pt'), Wovnrb.get_settings)
      assert_equal('pt', h.path_lang)
    end

    def test_path_lang_path_pt_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/PT'), Wovnrb.get_settings)
      assert_equal('pt', h.path_lang)
    end

    def test_path_lang_path_ru
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/ru'), Wovnrb.get_settings)
      assert_equal('ru', h.path_lang)
    end

    def test_path_lang_path_ru_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/RU'), Wovnrb.get_settings)
      assert_equal('ru', h.path_lang)
    end

    def test_path_lang_path_es
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/es'), Wovnrb.get_settings)
      assert_equal('es', h.path_lang)
    end

    def test_path_lang_path_es_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/ES'), Wovnrb.get_settings)
      assert_equal('es', h.path_lang)
    end

    def test_path_lang_path_sv
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/sv'), Wovnrb.get_settings)
      assert_equal('sv', h.path_lang)
    end

    def test_path_lang_path_sv_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/SV'), Wovnrb.get_settings)
      assert_equal('sv', h.path_lang)
    end

    def test_path_lang_path_th
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/th'), Wovnrb.get_settings)
      assert_equal('th', h.path_lang)
    end

    def test_path_lang_path_th_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/TH'), Wovnrb.get_settings)
      assert_equal('th', h.path_lang)
    end

    def test_path_lang_path_hi
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/hi'), Wovnrb.get_settings)
      assert_equal('hi', h.path_lang)
    end

    def test_path_lang_path_hi_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/HI'), Wovnrb.get_settings)
      assert_equal('hi', h.path_lang)
    end

    def test_path_lang_path_tr
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/tr'), Wovnrb.get_settings)
      assert_equal('tr', h.path_lang)
    end

    def test_path_lang_path_tr_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/TR'), Wovnrb.get_settings)
      assert_equal('tr', h.path_lang)
    end

    def test_path_lang_path_uk
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/uk'), Wovnrb.get_settings)
      assert_equal('uk', h.path_lang)
    end

    def test_path_lang_path_uk_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/UK'), Wovnrb.get_settings)
      assert_equal('uk', h.path_lang)
    end

    def test_path_lang_path_vi
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/vi'), Wovnrb.get_settings)
      assert_equal('vi', h.path_lang)
    end

    def test_path_lang_path_vi_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/VI'), Wovnrb.get_settings)
      assert_equal('vi', h.path_lang)
    end

    def test_path_lang_path_zh_CHS
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/zh-CHS'), Wovnrb.get_settings)
      assert_equal('zh-CHS', h.path_lang)
    end

    def test_path_lang_path_zh_CHS_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/ZH-CHS'), Wovnrb.get_settings)
      assert_equal('zh-CHS', h.path_lang)
    end

    def test_path_lang_path_zh_CHS_lowercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/zh-chs'), Wovnrb.get_settings)
      assert_equal('zh-CHS', h.path_lang)
    end

    def test_path_lang_path_zh_CHT
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/zh-CHT'), Wovnrb.get_settings)
      assert_equal('zh-CHT', h.path_lang)
    end

    def test_path_lang_path_zh_CHT_uppercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/ZH-CHT'), Wovnrb.get_settings)
      assert_equal('zh-CHT', h.path_lang)
    end

    def test_path_lang_path_zh_CHT_lowercase
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io/zh-cht'), Wovnrb.get_settings)
      assert_equal('zh-CHT', h.path_lang)
    end

    def test_path_lang_path_empty_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234'), Wovnrb.get_settings)
      assert_equal('', h.path_lang)
    end

    def test_path_lang_path_empty_with_slash_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/'), Wovnrb.get_settings)
      assert_equal('', h.path_lang)
    end

    def test_path_lang_path_ar_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/ar'), Wovnrb.get_settings)
      assert_equal('ar', h.path_lang)
    end

    def test_path_lang_path_ar_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/AR'), Wovnrb.get_settings)
      assert_equal('ar', h.path_lang)
    end

    def test_path_lang_path_da_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/da'), Wovnrb.get_settings)
      assert_equal('da', h.path_lang)
    end

    def test_path_lang_path_da_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/DA'), Wovnrb.get_settings)
      assert_equal('da', h.path_lang)
    end

    def test_path_lang_path_nl_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/nl'), Wovnrb.get_settings)
      assert_equal('nl', h.path_lang)
    end

    def test_path_lang_path_nl_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/NL'), Wovnrb.get_settings)
      assert_equal('nl', h.path_lang)
    end

    def test_path_lang_path_en_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/en'), Wovnrb.get_settings)
      assert_equal('en', h.path_lang)
    end

    def test_path_lang_path_en_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/EN'), Wovnrb.get_settings)
      assert_equal('en', h.path_lang)
    end

    def test_path_lang_path_fi_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/fi'), Wovnrb.get_settings)
      assert_equal('fi', h.path_lang)
    end

    def test_path_lang_path_fi_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/FI'), Wovnrb.get_settings)
      assert_equal('fi', h.path_lang)
    end

    def test_path_lang_path_fr_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/fr'), Wovnrb.get_settings)
      assert_equal('fr', h.path_lang)
    end

    def test_path_lang_path_fr_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/FR'), Wovnrb.get_settings)
      assert_equal('fr', h.path_lang)
    end

    def test_path_lang_path_de_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/de'), Wovnrb.get_settings)
      assert_equal('de', h.path_lang)
    end

    def test_path_lang_path_de_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/DE'), Wovnrb.get_settings)
      assert_equal('de', h.path_lang)
    end

    def test_path_lang_path_el_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/el'), Wovnrb.get_settings)
      assert_equal('el', h.path_lang)
    end

    def test_path_lang_path_el_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/EL'), Wovnrb.get_settings)
      assert_equal('el', h.path_lang)
    end

    def test_path_lang_path_he_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/he'), Wovnrb.get_settings)
      assert_equal('he', h.path_lang)
    end

    def test_path_lang_path_he_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/HE'), Wovnrb.get_settings)
      assert_equal('he', h.path_lang)
    end

    def test_path_lang_path_id_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/id'), Wovnrb.get_settings)
      assert_equal('id', h.path_lang)
    end

    def test_path_lang_path_id_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/ID'), Wovnrb.get_settings)
      assert_equal('id', h.path_lang)
    end

    def test_path_lang_path_it_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/it'), Wovnrb.get_settings)
      assert_equal('it', h.path_lang)
    end

    def test_path_lang_path_it_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/IT'), Wovnrb.get_settings)
      assert_equal('it', h.path_lang)
    end

    def test_path_lang_path_ja_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/ja'), Wovnrb.get_settings)
      assert_equal('ja', h.path_lang)
    end

    def test_path_lang_path_ja_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/JA'), Wovnrb.get_settings)
      assert_equal('ja', h.path_lang)
    end

    def test_path_lang_path_ko_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/ko'), Wovnrb.get_settings)
      assert_equal('ko', h.path_lang)
    end

    def test_path_lang_path_ko_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/KO'), Wovnrb.get_settings)
      assert_equal('ko', h.path_lang)
    end

    def test_path_lang_path_ms_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/ms'), Wovnrb.get_settings)
      assert_equal('ms', h.path_lang)
    end

    def test_path_lang_path_ms_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/MS'), Wovnrb.get_settings)
      assert_equal('ms', h.path_lang)
    end

    def test_path_lang_path_no_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/no'), Wovnrb.get_settings)
      assert_equal('no', h.path_lang)
    end

    def test_path_lang_path_no_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/NO'), Wovnrb.get_settings)
      assert_equal('no', h.path_lang)
    end

    def test_path_lang_path_pl_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/pl'), Wovnrb.get_settings)
      assert_equal('pl', h.path_lang)
    end

    def test_path_lang_path_pl_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/PL'), Wovnrb.get_settings)
      assert_equal('pl', h.path_lang)
    end

    def test_path_lang_path_pt_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/pt'), Wovnrb.get_settings)
      assert_equal('pt', h.path_lang)
    end

    def test_path_lang_path_pt_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/PT'), Wovnrb.get_settings)
      assert_equal('pt', h.path_lang)
    end

    def test_path_lang_path_ru_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/ru'), Wovnrb.get_settings)
      assert_equal('ru', h.path_lang)
    end

    def test_path_lang_path_ru_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/RU'), Wovnrb.get_settings)
      assert_equal('ru', h.path_lang)
    end

    def test_path_lang_path_es_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/es'), Wovnrb.get_settings)
      assert_equal('es', h.path_lang)
    end

    def test_path_lang_path_es_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/ES'), Wovnrb.get_settings)
      assert_equal('es', h.path_lang)
    end

    def test_path_lang_path_sv_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/sv'), Wovnrb.get_settings)
      assert_equal('sv', h.path_lang)
    end

    def test_path_lang_path_sv_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/SV'), Wovnrb.get_settings)
      assert_equal('sv', h.path_lang)
    end

    def test_path_lang_path_th_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/th'), Wovnrb.get_settings)
      assert_equal('th', h.path_lang)
    end

    def test_path_lang_path_th_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/TH'), Wovnrb.get_settings)
      assert_equal('th', h.path_lang)
    end

    def test_path_lang_path_hi_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/hi'), Wovnrb.get_settings)
      assert_equal('hi', h.path_lang)
    end

    def test_path_lang_path_hi_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/HI'), Wovnrb.get_settings)
      assert_equal('hi', h.path_lang)
    end

    def test_path_lang_path_tr_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/tr'), Wovnrb.get_settings)
      assert_equal('tr', h.path_lang)
    end

    def test_path_lang_path_tr_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/TR'), Wovnrb.get_settings)
      assert_equal('tr', h.path_lang)
    end

    def test_path_lang_path_uk_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/uk'), Wovnrb.get_settings)
      assert_equal('uk', h.path_lang)
    end

    def test_path_lang_path_uk_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/UK'), Wovnrb.get_settings)
      assert_equal('uk', h.path_lang)
    end

    def test_path_lang_path_vi_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/vi'), Wovnrb.get_settings)
      assert_equal('vi', h.path_lang)
    end

    def test_path_lang_path_vi_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/VI'), Wovnrb.get_settings)
      assert_equal('vi', h.path_lang)
    end

    def test_path_lang_path_zh_CHS_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/zh-CHS'), Wovnrb.get_settings)
      assert_equal('zh-CHS', h.path_lang)
    end

    def test_path_lang_path_zh_CHS_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/ZH-CHS'), Wovnrb.get_settings)
      assert_equal('zh-CHS', h.path_lang)
    end

    def test_path_lang_path_zh_CHS_lowercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/zh-chs'), Wovnrb.get_settings)
      assert_equal('zh-CHS', h.path_lang)
    end

    def test_path_lang_path_zh_CHT_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/zh-CHT'), Wovnrb.get_settings)
      assert_equal('zh-CHT', h.path_lang)
    end

    def test_path_lang_path_zh_CHT_uppercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/ZH-CHT'), Wovnrb.get_settings)
      assert_equal('zh-CHT', h.path_lang)
    end

    def test_path_lang_path_zh_CHT_lowercase_with_port
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://wovn.io:1234/zh-cht'), Wovnrb.get_settings)
      assert_equal('zh-CHT', h.path_lang)
    end

    def test_path_lang_path_empty_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io'), Wovnrb.get_settings)
      assert_equal('', h.path_lang)
    end

    def test_path_lang_path_empty_with_slash_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/'), Wovnrb.get_settings)
      assert_equal('', h.path_lang)
    end

    def test_path_lang_path_ar_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/ar'), Wovnrb.get_settings)
      assert_equal('ar', h.path_lang)
    end

    def test_path_lang_path_ar_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/AR'), Wovnrb.get_settings)
      assert_equal('ar', h.path_lang)
    end

    def test_path_lang_path_da_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/da'), Wovnrb.get_settings)
      assert_equal('da', h.path_lang)
    end

    def test_path_lang_path_da_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/DA'), Wovnrb.get_settings)
      assert_equal('da', h.path_lang)
    end

    def test_path_lang_path_nl_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/nl'), Wovnrb.get_settings)
      assert_equal('nl', h.path_lang)
    end

    def test_path_lang_path_nl_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/NL'), Wovnrb.get_settings)
      assert_equal('nl', h.path_lang)
    end

    def test_path_lang_path_en_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/en'), Wovnrb.get_settings)
      assert_equal('en', h.path_lang)
    end

    def test_path_lang_path_en_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/EN'), Wovnrb.get_settings)
      assert_equal('en', h.path_lang)
    end

    def test_path_lang_path_fi_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/fi'), Wovnrb.get_settings)
      assert_equal('fi', h.path_lang)
    end

    def test_path_lang_path_fi_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/FI'), Wovnrb.get_settings)
      assert_equal('fi', h.path_lang)
    end

    def test_path_lang_path_fr_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/fr'), Wovnrb.get_settings)
      assert_equal('fr', h.path_lang)
    end

    def test_path_lang_path_fr_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/FR'), Wovnrb.get_settings)
      assert_equal('fr', h.path_lang)
    end

    def test_path_lang_path_de_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/de'), Wovnrb.get_settings)
      assert_equal('de', h.path_lang)
    end

    def test_path_lang_path_de_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/DE'), Wovnrb.get_settings)
      assert_equal('de', h.path_lang)
    end

    def test_path_lang_path_el_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/el'), Wovnrb.get_settings)
      assert_equal('el', h.path_lang)
    end

    def test_path_lang_path_el_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/EL'), Wovnrb.get_settings)
      assert_equal('el', h.path_lang)
    end

    def test_path_lang_path_he_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/he'), Wovnrb.get_settings)
      assert_equal('he', h.path_lang)
    end

    def test_path_lang_path_he_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/HE'), Wovnrb.get_settings)
      assert_equal('he', h.path_lang)
    end

    def test_path_lang_path_id_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/id'), Wovnrb.get_settings)
      assert_equal('id', h.path_lang)
    end

    def test_path_lang_path_id_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/ID'), Wovnrb.get_settings)
      assert_equal('id', h.path_lang)
    end

    def test_path_lang_path_it_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/it'), Wovnrb.get_settings)
      assert_equal('it', h.path_lang)
    end

    def test_path_lang_path_it_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/IT'), Wovnrb.get_settings)
      assert_equal('it', h.path_lang)
    end

    def test_path_lang_path_ja_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/ja'), Wovnrb.get_settings)
      assert_equal('ja', h.path_lang)
    end

    def test_path_lang_path_ja_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/JA'), Wovnrb.get_settings)
      assert_equal('ja', h.path_lang)
    end

    def test_path_lang_path_ko_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/ko'), Wovnrb.get_settings)
      assert_equal('ko', h.path_lang)
    end

    def test_path_lang_path_ko_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/KO'), Wovnrb.get_settings)
      assert_equal('ko', h.path_lang)
    end

    def test_path_lang_path_ms_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/ms'), Wovnrb.get_settings)
      assert_equal('ms', h.path_lang)
    end

    def test_path_lang_path_ms_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/MS'), Wovnrb.get_settings)
      assert_equal('ms', h.path_lang)
    end

    def test_path_lang_path_no_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/no'), Wovnrb.get_settings)
      assert_equal('no', h.path_lang)
    end

    def test_path_lang_path_no_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/NO'), Wovnrb.get_settings)
      assert_equal('no', h.path_lang)
    end

    def test_path_lang_path_pl_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/pl'), Wovnrb.get_settings)
      assert_equal('pl', h.path_lang)
    end

    def test_path_lang_path_pl_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/PL'), Wovnrb.get_settings)
      assert_equal('pl', h.path_lang)
    end

    def test_path_lang_path_pt_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/pt'), Wovnrb.get_settings)
      assert_equal('pt', h.path_lang)
    end

    def test_path_lang_path_pt_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/PT'), Wovnrb.get_settings)
      assert_equal('pt', h.path_lang)
    end

    def test_path_lang_path_ru_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/ru'), Wovnrb.get_settings)
      assert_equal('ru', h.path_lang)
    end

    def test_path_lang_path_ru_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/RU'), Wovnrb.get_settings)
      assert_equal('ru', h.path_lang)
    end

    def test_path_lang_path_es_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/es'), Wovnrb.get_settings)
      assert_equal('es', h.path_lang)
    end

    def test_path_lang_path_es_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/ES'), Wovnrb.get_settings)
      assert_equal('es', h.path_lang)
    end

    def test_path_lang_path_sv_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/sv'), Wovnrb.get_settings)
      assert_equal('sv', h.path_lang)
    end

    def test_path_lang_path_sv_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/SV'), Wovnrb.get_settings)
      assert_equal('sv', h.path_lang)
    end

    def test_path_lang_path_th_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/th'), Wovnrb.get_settings)
      assert_equal('th', h.path_lang)
    end

    def test_path_lang_path_th_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/TH'), Wovnrb.get_settings)
      assert_equal('th', h.path_lang)
    end

    def test_path_lang_path_hi_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/hi'), Wovnrb.get_settings)
      assert_equal('hi', h.path_lang)
    end

    def test_path_lang_path_hi_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/HI'), Wovnrb.get_settings)
      assert_equal('hi', h.path_lang)
    end

    def test_path_lang_path_tr_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/tr'), Wovnrb.get_settings)
      assert_equal('tr', h.path_lang)
    end

    def test_path_lang_path_tr_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/TR'), Wovnrb.get_settings)
      assert_equal('tr', h.path_lang)
    end

    def test_path_lang_path_uk_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/uk'), Wovnrb.get_settings)
      assert_equal('uk', h.path_lang)
    end

    def test_path_lang_path_uk_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/UK'), Wovnrb.get_settings)
      assert_equal('uk', h.path_lang)
    end

    def test_path_lang_path_vi_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/vi'), Wovnrb.get_settings)
      assert_equal('vi', h.path_lang)
    end

    def test_path_lang_path_vi_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/VI'), Wovnrb.get_settings)
      assert_equal('vi', h.path_lang)
    end

    def test_path_lang_path_zh_CHS_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/zh-CHS'), Wovnrb.get_settings)
      assert_equal('zh-CHS', h.path_lang)
    end

    def test_path_lang_path_zh_CHS_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/ZH-CHS'), Wovnrb.get_settings)
      assert_equal('zh-CHS', h.path_lang)
    end

    def test_path_lang_path_zh_CHS_lowercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/zh-chs'), Wovnrb.get_settings)
      assert_equal('zh-CHS', h.path_lang)
    end

    def test_path_lang_path_zh_CHT_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/zh-CHT'), Wovnrb.get_settings)
      assert_equal('zh-CHT', h.path_lang)
    end

    def test_path_lang_path_zh_CHT_uppercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/ZH-CHT'), Wovnrb.get_settings)
      assert_equal('zh-CHT', h.path_lang)
    end

    def test_path_lang_path_zh_CHT_lowercase_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io/zh-cht'), Wovnrb.get_settings)
      assert_equal('zh-CHT', h.path_lang)
    end

    def test_path_lang_path_empty_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234'), Wovnrb.get_settings)
      assert_equal('', h.path_lang)
    end

    def test_path_lang_path_empty_with_slash_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/'), Wovnrb.get_settings)
      assert_equal('', h.path_lang)
    end

    def test_path_lang_path_ar_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/ar'), Wovnrb.get_settings)
      assert_equal('ar', h.path_lang)
    end

    def test_path_lang_path_ar_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/AR'), Wovnrb.get_settings)
      assert_equal('ar', h.path_lang)
    end

    def test_path_lang_path_da_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/da'), Wovnrb.get_settings)
      assert_equal('da', h.path_lang)
    end

    def test_path_lang_path_da_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/DA'), Wovnrb.get_settings)
      assert_equal('da', h.path_lang)
    end

    def test_path_lang_path_nl_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/nl'), Wovnrb.get_settings)
      assert_equal('nl', h.path_lang)
    end

    def test_path_lang_path_nl_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/NL'), Wovnrb.get_settings)
      assert_equal('nl', h.path_lang)
    end

    def test_path_lang_path_en_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/en'), Wovnrb.get_settings)
      assert_equal('en', h.path_lang)
    end

    def test_path_lang_path_en_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/EN'), Wovnrb.get_settings)
      assert_equal('en', h.path_lang)
    end

    def test_path_lang_path_fi_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/fi'), Wovnrb.get_settings)
      assert_equal('fi', h.path_lang)
    end

    def test_path_lang_path_fi_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/FI'), Wovnrb.get_settings)
      assert_equal('fi', h.path_lang)
    end

    def test_path_lang_path_fr_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/fr'), Wovnrb.get_settings)
      assert_equal('fr', h.path_lang)
    end

    def test_path_lang_path_fr_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/FR'), Wovnrb.get_settings)
      assert_equal('fr', h.path_lang)
    end

    def test_path_lang_path_de_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/de'), Wovnrb.get_settings)
      assert_equal('de', h.path_lang)
    end

    def test_path_lang_path_de_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/DE'), Wovnrb.get_settings)
      assert_equal('de', h.path_lang)
    end

    def test_path_lang_path_el_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/el'), Wovnrb.get_settings)
      assert_equal('el', h.path_lang)
    end

    def test_path_lang_path_el_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/EL'), Wovnrb.get_settings)
      assert_equal('el', h.path_lang)
    end

    def test_path_lang_path_he_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/he'), Wovnrb.get_settings)
      assert_equal('he', h.path_lang)
    end

    def test_path_lang_path_he_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/HE'), Wovnrb.get_settings)
      assert_equal('he', h.path_lang)
    end

    def test_path_lang_path_id_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/id'), Wovnrb.get_settings)
      assert_equal('id', h.path_lang)
    end

    def test_path_lang_path_id_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/ID'), Wovnrb.get_settings)
      assert_equal('id', h.path_lang)
    end

    def test_path_lang_path_it_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/it'), Wovnrb.get_settings)
      assert_equal('it', h.path_lang)
    end

    def test_path_lang_path_it_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/IT'), Wovnrb.get_settings)
      assert_equal('it', h.path_lang)
    end

    def test_path_lang_path_ja_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/ja'), Wovnrb.get_settings)
      assert_equal('ja', h.path_lang)
    end

    def test_path_lang_path_ja_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/JA'), Wovnrb.get_settings)
      assert_equal('ja', h.path_lang)
    end

    def test_path_lang_path_ko_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/ko'), Wovnrb.get_settings)
      assert_equal('ko', h.path_lang)
    end

    def test_path_lang_path_ko_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/KO'), Wovnrb.get_settings)
      assert_equal('ko', h.path_lang)
    end

    def test_path_lang_path_ms_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/ms'), Wovnrb.get_settings)
      assert_equal('ms', h.path_lang)
    end

    def test_path_lang_path_ms_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/MS'), Wovnrb.get_settings)
      assert_equal('ms', h.path_lang)
    end

    def test_path_lang_path_no_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/no'), Wovnrb.get_settings)
      assert_equal('no', h.path_lang)
    end

    def test_path_lang_path_no_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/NO'), Wovnrb.get_settings)
      assert_equal('no', h.path_lang)
    end

    def test_path_lang_path_pl_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/pl'), Wovnrb.get_settings)
      assert_equal('pl', h.path_lang)
    end

    def test_path_lang_path_pl_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/PL'), Wovnrb.get_settings)
      assert_equal('pl', h.path_lang)
    end

    def test_path_lang_path_pt_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/pt'), Wovnrb.get_settings)
      assert_equal('pt', h.path_lang)
    end

    def test_path_lang_path_pt_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/PT'), Wovnrb.get_settings)
      assert_equal('pt', h.path_lang)
    end

    def test_path_lang_path_ru_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/ru'), Wovnrb.get_settings)
      assert_equal('ru', h.path_lang)
    end

    def test_path_lang_path_ru_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/RU'), Wovnrb.get_settings)
      assert_equal('ru', h.path_lang)
    end

    def test_path_lang_path_es_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/es'), Wovnrb.get_settings)
      assert_equal('es', h.path_lang)
    end

    def test_path_lang_path_es_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/ES'), Wovnrb.get_settings)
      assert_equal('es', h.path_lang)
    end

    def test_path_lang_path_sv_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/sv'), Wovnrb.get_settings)
      assert_equal('sv', h.path_lang)
    end

    def test_path_lang_path_sv_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/SV'), Wovnrb.get_settings)
      assert_equal('sv', h.path_lang)
    end

    def test_path_lang_path_th_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/th'), Wovnrb.get_settings)
      assert_equal('th', h.path_lang)
    end

    def test_path_lang_path_th_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/TH'), Wovnrb.get_settings)
      assert_equal('th', h.path_lang)
    end

    def test_path_lang_path_hi_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/hi'), Wovnrb.get_settings)
      assert_equal('hi', h.path_lang)
    end

    def test_path_lang_path_hi_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/HI'), Wovnrb.get_settings)
      assert_equal('hi', h.path_lang)
    end

    def test_path_lang_path_tr_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/tr'), Wovnrb.get_settings)
      assert_equal('tr', h.path_lang)
    end

    def test_path_lang_path_tr_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/TR'), Wovnrb.get_settings)
      assert_equal('tr', h.path_lang)
    end

    def test_path_lang_path_uk_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/uk'), Wovnrb.get_settings)
      assert_equal('uk', h.path_lang)
    end

    def test_path_lang_path_uk_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/UK'), Wovnrb.get_settings)
      assert_equal('uk', h.path_lang)
    end

    def test_path_lang_path_vi_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/vi'), Wovnrb.get_settings)
      assert_equal('vi', h.path_lang)
    end

    def test_path_lang_path_vi_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/VI'), Wovnrb.get_settings)
      assert_equal('vi', h.path_lang)
    end

    def test_path_lang_path_zh_CHS_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/zh-CHS'), Wovnrb.get_settings)
      assert_equal('zh-CHS', h.path_lang)
    end

    def test_path_lang_path_zh_CHS_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/ZH-CHS'), Wovnrb.get_settings)
      assert_equal('zh-CHS', h.path_lang)
    end

    def test_path_lang_path_zh_CHS_lowercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/zh-chs'), Wovnrb.get_settings)
      assert_equal('zh-CHS', h.path_lang)
    end

    def test_path_lang_path_zh_CHT_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/zh-CHT'), Wovnrb.get_settings)
      assert_equal('zh-CHT', h.path_lang)
    end

    def test_path_lang_path_zh_CHT_uppercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/ZH-CHT'), Wovnrb.get_settings)
      assert_equal('zh-CHT', h.path_lang)
    end

    def test_path_lang_path_zh_CHT_lowercase_with_port_unsecure
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://wovn.io:1234/zh-cht'), Wovnrb.get_settings)
      assert_equal('zh-CHT', h.path_lang)
    end

    def test_remove_lang_path
      h = Wovnrb::Headers.new(Wovnrb.get_env, Wovnrb.get_settings)

      keys = Wovnrb::Lang::LANG.keys
      assert_equal(39, keys.size)

      for key in keys
        uri_without_scheme = h.remove_lang("wovn.io/#{key}", key)
        assert_equal('wovn.io/', uri_without_scheme)

        uri_with_scheme = h.remove_lang("https://wovn.io/#{key}/", key)
        assert_equal('https://wovn.io/', uri_with_scheme)
      end
    end

    def test_remove_lang_path_with_nil_lang
      h = Wovnrb::Headers.new(Wovnrb.get_env, Wovnrb.get_settings)
      keys = Wovnrb::Lang::LANG.keys
      assert_equal(39, keys.size)

      uri_without_scheme = h.remove_lang('wovn.io', nil)
      assert_equal('wovn.io', uri_without_scheme)

      uri_with_scheme = h.remove_lang('https://wovn.io/', nil)
      assert_equal('https://wovn.io/', uri_with_scheme)
    end

    def test_remove_lang_path_with_empty_lang
      h = Wovnrb::Headers.new(Wovnrb.get_env, Wovnrb.get_settings)

      uri_without_scheme = h.remove_lang('wovn.io', '')
      assert_equal('wovn.io', uri_without_scheme)

      uri_with_scheme = h.remove_lang('https://wovn.io/', '')
      assert_equal('https://wovn.io/', uri_with_scheme)
    end

    def test_remove_lang_query
      h = Wovnrb::Headers.new(Wovnrb.get_env, Wovnrb.get_settings('url_pattern' => 'query'))

      keys = Wovnrb::Lang::LANG.keys
      assert_equal(39, keys.size)

      for key in keys
        uri_without_scheme = h.remove_lang("wovn.io/?wovn=#{key}", key)
        assert_equal('wovn.io/', uri_without_scheme)

        uri_with_scheme = h.remove_lang("https://wovn.io?wovn=#{key}", key)
        assert_equal('https://wovn.io', uri_with_scheme)
      end
    end

    def test_remove_lang_query_with_nil_lang
      h = Wovnrb::Headers.new(Wovnrb.get_env, Wovnrb.get_settings('url_pattern' => 'query'))
      keys = Wovnrb::Lang::LANG.keys
      assert_equal(39, keys.size)

      uri_without_scheme = h.remove_lang('wovn.io', nil)
      assert_equal('wovn.io', uri_without_scheme)

      uri_with_scheme = h.remove_lang('https://wovn.io/', nil)
      assert_equal('https://wovn.io/', uri_with_scheme)
    end

    def test_remove_lang_query_with_empty_lang
      h = Wovnrb::Headers.new(Wovnrb.get_env, Wovnrb.get_settings('url_pattern' => 'query'))

      uri_without_scheme = h.remove_lang('wovn.io', '')
      assert_equal('wovn.io', uri_without_scheme)

      uri_with_scheme = h.remove_lang('https://wovn.io/', '')
      assert_equal('https://wovn.io/', uri_with_scheme)
    end

    def test_remove_lang_subdomain
      h = Wovnrb::Headers.new(Wovnrb.get_env, Wovnrb.get_settings('url_pattern' => 'subdomain'))

      keys = Wovnrb::Lang::LANG.keys
      assert_equal(39, keys.size)

      for key in keys
        uri_without_scheme = h.remove_lang("#{key.downcase}.wovn.io/", key)
        assert_equal('wovn.io/', uri_without_scheme)

        uri_with_scheme = h.remove_lang("https://#{key.downcase}.wovn.io", key)
        assert_equal('https://wovn.io', uri_with_scheme)
      end
    end

    def test_remove_lang_subdomain_with_nil_lang
      h = Wovnrb::Headers.new(Wovnrb.get_env, Wovnrb.get_settings('url_pattern' => 'subdomain'))
      keys = Wovnrb::Lang::LANG.keys
      assert_equal(39, keys.size)

      uri_without_scheme = h.remove_lang('wovn.io', nil)
      assert_equal('wovn.io', uri_without_scheme)

      uri_with_scheme = h.remove_lang('https://wovn.io/', nil)
      assert_equal('https://wovn.io/', uri_with_scheme)
    end

    def test_remove_lang_subdomain_with_empty_lang
      h = Wovnrb::Headers.new(Wovnrb.get_env, Wovnrb.get_settings('url_pattern' => 'subdomain'))

      uri_without_scheme = h.remove_lang('wovn.io', '')
      assert_equal('wovn.io', uri_without_scheme)

      uri_with_scheme = h.remove_lang('https://wovn.io/', '')
      assert_equal('https://wovn.io/', uri_with_scheme)
    end

    def test_remove_lang_subdomain_with_custom_lang_alias
      Store.instance.update_settings({'custom_lang_aliases' => {'fr' => 'staging-fr'}})
      h = Wovnrb::Headers.new(Wovnrb.get_env, Wovnrb.get_settings('url_pattern' => 'subdomain'))

      uri_without_scheme = h.remove_lang("staging-fr.wovn.io/", 'fr')
      assert_equal('wovn.io/', uri_without_scheme)

      uri_with_scheme = h.remove_lang("https://staging-fr.wovn.io", 'fr')
      assert_equal('https://wovn.io', uri_with_scheme)
    end
  end
end
