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
    body =  "<html lang=\"ja\"><body><h1>Mr. Belvedere Fan Club</h1><div><p>Hello</p></div></body></html>"

    expected_body = [
        "<html lang=\"ja\"><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">",
        "<script src=\"//j.wovn.io/1\" async=\"true\" data-wovnio=\"key=&amp;backend=true&amp;currentLang=ja&amp;defaultLang=en&amp;urlPattern=path&amp;langCodeAliases={}&amp;version=#{Wovnrb::VERSION}\"> </script>",
        "<link rel=\"alternate\" hreflang=\"ja\" href=\"http://ja.page.com/\">",
        "<link rel=\"alternate\" hreflang=\"en\" href=\"http://page.com/\"></head>",
        "<body><h1><!--wovn-src:Mr. Belvedere Fan Club-->ベルベデアさんファンクラブ</h1>",
        "<div><p><!--wovn-src:Hello-->こんにちは</p></div>",
        "</body></html>"
    ].join

    assert_switch_lang('en', 'ja', body, expected_body, true)
  end

  def test_switch_lang_of_html_fragment_with_japanese_translations
    bodies = ['<span>Hello</span>'].join
    expected_bodies = ['<span><!--wovn-src:Hello-->こんにちは</span>'].join

    assert_switch_lang('en', 'ja', bodies, expected_bodies, true)
  end

  def test_switch_lang_splitted_body
    bodies =  ["<html><body><h1>Mr. Belvedere Fan Club</h1>",
               "<div><p>Hello</p></div>",
               "</body></html>"].join
    expected_bodies = ["<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\"><script src=\"//j.dev-wovn.io:3000/1\" async=\"true\" data-wovnio=\"key=123456&amp;amp;backend=true&amp;amp;currentLang=ja&amp;amp;defaultLang=en&amp;amp;urlPattern=subdomain&amp;amp;langCodeAliases={}&amp;amp;version=WOVN.rb_#{Wovnrb::VERSION}\" data-wovnio-type=\"fallback_snippet\"></script><link rel=\"alternate\" hreflang=\"en\" href=\"http://page.com/\"></head><body><h1>Mr. Belvedere Fan Club</h1><div><p>Hello</p></div></body></html>"].join

    assert_switch_lang('en', 'ja', bodies, expected_bodies, true)
  end

  def test_switch_lang_of_html_fragment_in_splitted_body
    body =  ['<select name="test"><option value="1">1</option>',
             '<option value="2">2</option></select>'].join
    expected_body = ['<select name="test"><option value="1">1</option><option value="2">2</option></select>'].join

    assert_switch_lang('en', 'ja', body, expected_body, true)
  end

  def test_switch_lang_missing_values
    body =  "<html><body><h1>Mr. Belvedere Fan Club</h1>
                <div><p>Hello</p></div>
              </body></html>"
    expected_body = "<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\"><script src=\"//j.wovn.io/1\" async=\"true\" data-wovnio=\"key=&amp;backend=true&amp;currentLang=ja&amp;defaultLang=en&amp;urlPattern=path&amp;langCodeAliases={}&amp;version=#{Wovnrb::VERSION}\"> </script></head><body><h1>Mr. Belvedere Fan Club</h1>
                <div><p>Hello</p></div>
              </body></html>
"

    assert_switch_lang('en', 'ja', body, expected_body, true)
  end

  def test_switch_lang_on_fragment_with_translate_fragment_false
    body =  "<h1>Mr. Belvedere Fan Club</h1>
                <div><p>Hello</p></div>"

    Wovnrb::Store.instance.settings['translate_fragment'] = false
    assert_switch_lang('en', 'ja', body, body, false)
  end

  def test_switch_lang_on_fragment_with_translate_fragment_true
    body =  "<h1>Mr. Belvedere Fan Club</h1>
                <div><p>Hello</p></div>"
    expected_body = "<h1><!--wovn-src:Mr. Belvedere Fan Club-->ベルベデアさんファンクラブ</h1>
                <div><p><!--wovn-src:Hello-->こんにちは</p></div>"

    Wovnrb::Store.instance.settings['translate_fragment'] = true
    assert_switch_lang('en', 'ja', body, expected_body, true)
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

    assert_switch_lang('en', 'ja', body, body, false)
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

    assert_switch_lang('en', 'ja', body, body, false)
  end

  private

  def assert_switch_lang(original_lang, target_lang, body, expected_body, api_expected = true)
    subdomain = target_lang == original_lang ? '' : "#{target_lang}."
    interceptor = Wovnrb::Interceptor.new(get_app)

    store, headers = store_headers_factory(subdomain, original_lang)
    if api_expected
      dom = Wovnrb::Helpers::NokogumboHelper::parse_html(body)
      converter = Wovnrb::HtmlConverter.new(dom, store, headers)
      apified_body, _ = converter.build_api_compatible_html
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
        'url_pattern_reg' => '^(?<lang>[^.]+).'
    }

    store = Wovnrb::Store.instance
    store.update_settings(settings)

    headers = Wovnrb::Headers.new(
        Wovnrb.get_env('url' => "http://#{subdomain}page.com"),
        Wovnrb.get_settings(settings)
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

  def get_app(opts={})
    RackMock.new(opts)
  end

  class RackMock
    attr_accessor :params

    def initialize(opts={})
      @params = {}
      if opts.has_key?(:params) && opts[:params].class == Hash
        opts[:params].each do |key, val|
          @params[key] = val
        end
      end
      @request_headers = {}
    end

    def call(env)
      @env = env
      if @params.length > 0
        req = Rack::Request.new(@env)
        @params.each do |key, val|
          req.update_param(key, val)
        end
      end
      [200, {'Content-Type' => 'text/html'}, ['']]
    end

    def [](key)
      @env[key]
    end
  end
end
