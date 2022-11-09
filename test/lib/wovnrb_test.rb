require 'test_helper'
require 'wovnrb'

class WovnrbTest < Minitest::Test
  def setup
    Wovnrb::Store.instance.reset
  end

  def test_initialize
    i = Wovnrb::Interceptor.new(get_app)
    refute_nil(i)
  end

  def test_switch_lang
    body = '<html lang="ja"><body><h1>Mr. Belvedere Fan Club</h1><div><p>Hello</p></div></body></html>'

    expected_body = [
      '<html lang="ja"><head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8">',
      "<script src=\"https://j.wovn.io/1\" async=\"true\" data-wovnio=\"key=&amp;backend=true&amp;currentLang=ja&amp;defaultLang=en&amp;urlPattern=path&amp;langCodeAliases={}&amp;version=#{Wovnrb::VERSION}\"> </script>",
      '<link rel="alternate" hreflang="ja" href="http://ja.page.com/">',
      '<link rel="alternate" hreflang="en" href="http://page.com/"></head>',
      '<body><h1><!--wovn-src:Mr. Belvedere Fan Club-->ベルベデアさんファンクラブ</h1>',
      '<div><p><!--wovn-src:Hello-->こんにちは</p></div>',
      '</body></html>'
    ].join

    assert_switch_lang('en', 'ja', body, expected_body, api_expected: true)
  end

  def test_switch_lang_with_input_tags
    body = [
      '<html lang="ja">',
      '<body>',
      '<input type="hidden" value="test1">',
      '<input type="hidden" value="test2">',
      '<input type="hidden" value="">',
      '<input value="test3">',
      '</body></html>'
    ].join

    expected_body = [
      '<html lang="ja"><head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8">',
      "<script src=\"https://j.wovn.io/1\" async=\"true\" data-wovnio=\"key=&backend=true&currentLang=ja&defaultLang=en&urlPattern=path&langCodeAliases={}&version=#{Wovnrb::VERSION}\"> </script>",
      '<link rel="alternate" hreflang="ja" href="http://ja.page.com/">',
      '<link rel="alternate" hreflang="en" href="http://page.com/"></head>',
      '<body>',
      '<input type="hidden" value="test1">',
      '<input type="hidden" value="test2">',
      '<input type="hidden" value="">',
      '<input value="test3">',
      '<p><!--wovn-src:Hello-->こんにちは</p>',
      '</body></html>'
    ].join

    assert_switch_lang('en', 'ja', body, expected_body, api_expected: true)
  end

  def test_switch_lang_of_html_fragment_with_japanese_translations
    bodies = ['<span>Hello</span>'].join
    expected_bodies = ['<span><!--wovn-src:Hello-->こんにちは</span>'].join

    assert_switch_lang('en', 'ja', bodies, expected_bodies, api_expected: true)
  end

  def test_switch_lang_splitted_body
    bodies = ['<html><body><h1>Mr. Belvedere Fan Club</h1>',
              '<div><p>Hello</p></div>',
              '</body></html>'].join
    expected_bodies = ["<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\"><script src=\"https://j.wovn.io/1\" async=\"true\" data-wovnio=\"key=123456&amp;backend=true&amp;currentLang=ja&amp;defaultLang=en&amp;urlPattern=subdomain&amp;langCodeAliases={}&amp;version=WOVN.rb_#{Wovnrb::VERSION}\" data-wovnio-type=\"fallback_snippet\"></script><link rel=\"alternate\" hreflang=\"en\" href=\"http://page.com/\"></head><body><h1>Mr. Belvedere Fan Club</h1><div><p>Hello</p></div></body></html>"].join

    assert_switch_lang('en', 'ja', bodies, expected_bodies, api_expected: true)
  end

  def test_switch_lang_of_html_fragment_in_splitted_body
    body = ['<select name="test"><option value="1">1</option>',
            '<option value="2">2</option></select>'].join
    expected_body = ['<select name="test"><option value="1">1</option><option value="2">2</option></select>'].join

    assert_switch_lang('en', 'ja', body, expected_body, api_expected: true)
  end

  def test_switch_lang_missing_values
    body = "<html><body><h1>Mr. Belvedere Fan Club</h1>
                <div><p>Hello</p></div>
              </body></html>"
    expected_body = "<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\"><script src=\"https://j.wovn.io/1\" async=\"true\" data-wovnio=\"key=&amp;backend=true&amp;currentLang=ja&amp;defaultLang=en&amp;urlPattern=path&amp;langCodeAliases={}&amp;version=#{Wovnrb::VERSION}\"> </script></head><body><h1>Mr. Belvedere Fan Club</h1>
                <div><p>Hello</p></div>
              </body></html>
"

    assert_switch_lang('en', 'ja', body, expected_body, api_expected: true)
  end

  def test_switch_lang_on_fragment_with_translate_fragment_false
    body = "<h1>Mr. Belvedere Fan Club</h1>
                <div><p>Hello</p></div>"

    Wovnrb::Store.instance.settings['translate_fragment'] = false
    assert_switch_lang('en', 'ja', body, body, api_expected: false)
  end

  def test_switch_lang_on_fragment_with_translate_fragment_true
    body = "<h1>Mr. Belvedere Fan Club</h1>
                <div><p>Hello</p></div>"
    expected_body = "<h1><!--wovn-src:Mr. Belvedere Fan Club-->ベルベデアさんファンクラブ</h1>
                <div><p><!--wovn-src:Hello-->こんにちは</p></div>"

    Wovnrb::Store.instance.settings['translate_fragment'] = true
    assert_switch_lang('en', 'ja', body, expected_body, api_expected: true)
  end

  def test_switch_lang_ignores_amp
    body = <<HTML
<html amp>
<head><noscript><style amp-boilerplate>body{-webkit-animation:none;-moz-animation:none;-ms-animation:none;animation:none}</style></noscript></head>
<body>
  <h1>Mr. Belvedere Fan Club</h1>
  <div><p>Hello</p></div>
</body>
</html>
HTML

    assert_switch_lang('en', 'ja', body, body, api_expected: false)
  end

  def test_switch_lang_ignores_amp_defined_with_symbol_attribute
    body = <<HTML
<html ⚡>
<body>
  <h1>Mr. Belvedere Fan Club</h1>
  <div><p>Hello</p></div>
</body>
</html>
HTML

    assert_switch_lang('en', 'ja', body, body, api_expected: false)
  end

  def test_call_without_path_ignored_should_change_environment
    settings = {
      'project_token' => '123456',
      'url_pattern' => 'path',
      'default_lang' => 'ja',
      'supported_langs' => %w[ja en],
      'ignore_paths' => ['/en/ignored']
    }
    env = {
      'rack.input' => '',
      'rack.request.query_string' => '',
      'rack.request.query_hash' => {},
      'rack.request.form_input' => '',
      'rack.request.form_hash' => {},
      'HTTP_HOST' => 'test.com',
      'REQUEST_URI' => '/en/not_ignored',
      'PATH_INFO' => '/en/not_ignored'
    }

    assert_call_affects_env(settings, env, mock_api: true, affected: true)
  end

  def test_call_with_path_ignored_with_language_code_should_change_environment
    settings = {
      'project_token' => '123456',
      'url_pattern' => 'path',
      'default_lang' => 'ja',
      'supported_langs' => %w[ja en],
      'ignore_paths' => ['/en/ignored']
    }
    env = {
      'rack.input' => '',
      'rack.request.query_string' => '',
      'rack.request.query_hash' => {},
      'rack.request.form_input' => '',
      'rack.request.form_hash' => {},
      'HTTP_HOST' => 'test.com',
      'REQUEST_URI' => '/ignored',
      'PATH_INFO' => '/ignored'
    }

    assert_call_affects_env(settings, env, mock_api: false, affected: true)
  end

  def test_call_with_path_ignored_without_language_code_should_change_environment
    settings = {
      'project_token' => '123456',
      'url_pattern' => 'path',
      'default_lang' => 'ja',
      'supported_langs' => %w[ja en],
      'ignore_paths' => ['/ignored']
    }
    env = {
      'rack.input' => '',
      'rack.request.query_string' => '',
      'rack.request.query_hash' => {},
      'rack.request.form_input' => '',
      'rack.request.form_hash' => {},
      'HTTP_HOST' => 'test.com',
      'REQUEST_URI' => '/en/ignored',
      'PATH_INFO' => '/en/ignored'
    }

    assert_call_affects_env(settings, env, mock_api: false, affected: true)
  end

  def test_call_with_path_ignored_without_language_code_in_original_language_should_change_environment
    settings = {
      'project_token' => '123456',
      'url_pattern' => 'path',
      'default_lang' => 'ja',
      'supported_langs' => %w[ja en],
      'ignore_paths' => ['/ignored']
    }
    env = {
      'rack.input' => '',
      'rack.request.query_string' => '',
      'rack.request.query_hash' => {},
      'rack.request.form_input' => '',
      'rack.request.form_hash' => {},
      'HTTP_HOST' => 'test.com',
      'REQUEST_URI' => '/ignored',
      'PATH_INFO' => '/ignored'
    }

    assert_call_affects_env(settings, env, mock_api: false, affected: true)
  end

  def test_call_with_path_ignored_should_not_change_environment
    settings = {
      'project_token' => '123456',
      'url_pattern' => 'path',
      'default_lang' => 'ja',
      'supported_langs' => %w[ja en],
      'ignore_paths' => ['/en/ignored']
    }
    env = {
      'rack.input' => '',
      'rack.request.query_string' => '',
      'rack.request.query_hash' => {},
      'rack.request.form_input' => '',
      'rack.request.form_hash' => {},
      'HTTP_HOST' => 'test.com',
      'REQUEST_URI' => '/en/ignored',
      'PATH_INFO' => '/en/ignored'
    }

    assert_call_affects_env(settings, env, mock_api: false, affected: false)
  end

  private

  def assert_call_affects_env(settings, env, mock_api:, affected:)
    app_mock = get_app
    sut = Wovnrb::Interceptor.new(app_mock, settings)
    unaffected_env = env

    mock_translation_api_response('', '') if mock_api
    sut.call(env.clone)

    assert_equal(unaffected_env != app_mock.env, affected)
  end

  def assert_switch_lang(original_lang, target_lang, body, expected_body, api_expected: true)
    subdomain = target_lang == original_lang ? '' : "#{target_lang}."
    interceptor = Wovnrb::Interceptor.new(get_app)

    store, headers = store_headers_factory(subdomain, original_lang)
    if api_expected
      dom = Wovnrb::Helpers::NokogumboHelper.parse_html(body)
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)
      converter = Wovnrb::HtmlConverter.new(dom, store, headers, url_lang_switcher)
      apified_body, = converter.build_api_compatible_html
      mock_translation_api_response(apified_body, expected_body)
    end

    actual_bodies = interceptor.switch_lang(headers, [body])

    assert_same_elements([expected_body], actual_bodies)
  end

  def store_headers_factory(subdomain, original_lang)
    settings = {
      'project_token' => '123456',
      'custom_lang_aliases' => {},
      'default_lang' => original_lang,
      'url_pattern' => 'subdomain',
      'url_pattern_reg' => '^(?<lang>[^.]+)\.'
    }

    store = Wovnrb::Store.instance
    store.update_settings(settings)

    headers = Wovnrb::Headers.new(
      Wovnrb.get_env('url' => "http://#{subdomain}page.com"),
      Wovnrb.get_settings(settings),
      Wovnrb::UrlLanguageSwitcher.new(store)
    )

    [store, headers]
  end

  def mock_translation_api_response(body, expected_body)
    Wovnrb::ApiTranslator.any_instance
                         .expects(:translate)
                         .once
                         .with(body)
                         .returns(expected_body)
  end

  def get_app(opts = {})
    RackMock.new(opts)
  end

  class RackMock
    attr_accessor :params, :env

    def initialize(opts = {})
      @params = {}
      if opts.key?(:params) && opts[:params].instance_of?(Hash)
        opts[:params].each do |key, val|
          @params[key] = val
        end
      end
      @request_headers = {}
    end

    def call(env)
      @env = env
      unless @params.empty?
        req = Rack::Request.new(@env)
        @params.each do |key, val|
          req.update_param(key, val)
        end
      end
      [200, { 'Content-Type' => 'text/html' }, ['']]
    end

    def [](key)
      @env[key]
    end
  end
end
