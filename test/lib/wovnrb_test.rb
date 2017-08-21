# -*- coding: utf-8 -*-
require 'wovnrb'
require 'wovnrb/headers'
require 'minitest/autorun'
require 'webmock/minitest'
require 'pry'

class WovnrbTest < Minitest::Test
  def setup
    Wovnrb::Store.instance.reset
  end

  def test_initialize
    i = Wovnrb::Interceptor.new(get_app)
    refute_nil(i)
  end


  # def test_call(env)
  # end


  # def test_switch_lang(body, values, url, lang=STORE.settings['default_lang'], headers)
  # end

  def test_api_call
    settings = Wovnrb.get_settings
    token = settings['project_token']
    url = 'wovn.io/dashboard'
    stub = stub_request(:get, "#{settings['api_url']}?token=#{token}&url=#{url}").
      to_return(:body => '{"test_body": "a"}')

    i = Wovnrb::Interceptor.new(get_app, settings)

    i.call(Wovnrb.get_env)
    assert_requested(stub, :times => 1)
  end

  def test_api_call_with_cache
    settings = Wovnrb.get_settings
    token = settings['project_token']
    url = 'wovn.io/dashboard'
    stub = stub_request(:get, "#{settings['api_url']}?token=#{token}&url=#{url}").
      to_return(:body => '{"test_body": "a"}')

    i = Wovnrb::Interceptor.new(RackMock.new, settings)

    i.call(Wovnrb.get_env)
    i.call(Wovnrb.get_env)
    assert_requested(stub, :times => 1)
  end

  def test_api_call_with_language
    settings = Wovnrb.get_settings
    token = settings['project_token']
    url = 'wovn.io/dashboard'
    stub = stub_request(:get, "#{settings['api_url']}?token=#{token}&url=#{url}").
      to_return(:body => '{"test_body": "a", "language": "ja"}')

    i = Wovnrb::Interceptor.new(get_app, settings)

    _status, _header, html = i.call(Wovnrb.get_env)
    assert_match(/backend=true&amp;currentLang=en&amp;defaultLang=ja/, html.to_s)
  end

  def test_switch_lang
    i = Wovnrb::Interceptor.new(get_app)
    h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://page.com'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    body =  "<html><body><h1>Mr. Belvedere Fan Club</h1>
                <div><p>Hello</p></div>
              </body></html>"
    values = generate_values
    url = h.url
    swapped_body = i.switch_lang([body], values, url, 'ja', h)

    expected_body = "<html lang=\"ja\">
<head>
<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">
<script src=\"//j.wovn.io/1\" async=\"true\" data-wovnio=\"key=&amp;backend=true&amp;currentLang=ja&amp;defaultLang=en&amp;urlPattern=path&amp;langCodeAliases={}&amp;version=#{Wovnrb::VERSION}\"> </script><link rel=\"alternate\" hreflang=\"ja\" href=\"http://ja.page.com/\">
</head>
<body>
<h1>
<!--wovn-src:Mr. Belvedere Fan Club-->ベルベデアさんファンクラブ</h1>
                <div><p><!--wovn-src:Hello-->こんにちは</p></div>
              </body>
</html>
"
    assert_equal([expected_body], swapped_body)
  end

  def test_switch_lang_with_noscript_in_head
    i = Wovnrb::Interceptor.new(get_app)
    h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://page.com'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    body =  "<html><head><noscript><div>test</div></noscript></head><body><h1>Mr. Belvedere Fan Club</h1>
                <div><p>Hello</p></div>
              </body></html>"
    values = generate_values
    url = h.url
    swapped_body = i.switch_lang([body], values, url, 'ja', h)

    expected_body = "<html lang=\"ja\">
<head>
<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">
<script src=\"//j.wovn.io/1\" async=\"true\" data-wovnio=\"key=&amp;backend=true&amp;currentLang=ja&amp;defaultLang=en&amp;urlPattern=path&amp;langCodeAliases={}&amp;version=#{Wovnrb::VERSION}\"> </script><noscript><div>test</div></noscript>
<link rel=\"alternate\" hreflang=\"ja\" href=\"http://ja.page.com/\">
</head>
<body>
<h1>
<!--wovn-src:Mr. Belvedere Fan Club-->ベルベデアさんファンクラブ</h1>
                <div><p><!--wovn-src:Hello-->こんにちは</p></div>
              </body>
</html>
"
    assert_equal([expected_body], swapped_body)
  end

  def test_switch_lang_with_multiline_noscript_in_head
    i = Wovnrb::Interceptor.new(get_app)
    h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://page.com'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    body =  "<html><head><noscript>
                <div>test</div>
                </noscript></head><body><h1>Mr. Belvedere Fan Club</h1>
                <div><p>Hello</p></div>
              </body></html>"
    values = generate_values
    url = h.url
    swapped_body = i.switch_lang([body], values, url, 'ja', h)

    expected_body = "<html lang=\"ja\">
<head>
<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">
<script src=\"//j.wovn.io/1\" async=\"true\" data-wovnio=\"key=&amp;backend=true&amp;currentLang=ja&amp;defaultLang=en&amp;urlPattern=path&amp;langCodeAliases={}&amp;version=#{Wovnrb::VERSION}\"> </script><noscript>
                <div>test</div>
                </noscript>
<link rel=\"alternate\" hreflang=\"ja\" href=\"http://ja.page.com/\">
</head>
<body>
<h1>
<!--wovn-src:Mr. Belvedere Fan Club-->ベルベデアさんファンクラブ</h1>
                <div><p><!--wovn-src:Hello-->こんにちは</p></div>
              </body>
</html>
"
    assert_equal([expected_body], swapped_body)
  end

  def test_switch_lang_with_multiple_noscript_in_head
    i = Wovnrb::Interceptor.new(get_app)
    h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://page.com'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    body =  "<html><head><noscript><div>test</div></noscript><title>plop</title><noscript><div>test2</div></noscript></head><body><h1>Mr. Belvedere Fan Club</h1>
                <div><p>Hello</p></div>
              </body></html>"
    values = generate_values
    url = h.url
    swapped_body = i.switch_lang([body], values, url, 'ja', h)

    expected_body = "<html lang=\"ja\">
<head>
<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">
<script src=\"//j.wovn.io/1\" async=\"true\" data-wovnio=\"key=&amp;backend=true&amp;currentLang=ja&amp;defaultLang=en&amp;urlPattern=path&amp;langCodeAliases={}&amp;version=#{Wovnrb::VERSION}\"> </script><noscript><div>test</div></noscript>
<title>plop</title>
<noscript><div>test2</div></noscript>
<link rel=\"alternate\" hreflang=\"ja\" href=\"http://ja.page.com/\">
</head>
<body>
<h1>
<!--wovn-src:Mr. Belvedere Fan Club-->ベルベデアさんファンクラブ</h1>
                <div><p><!--wovn-src:Hello-->こんにちは</p></div>
              </body>
</html>
"
    assert_equal([expected_body], swapped_body)
  end

  def test_switch_lang_with_noscript_in_head_and_comment_inside
    i = Wovnrb::Interceptor.new(get_app)
    h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://page.com'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    body =  "<html><head><noscript><!-- --><div>test</div></noscript></head><body><h1>Mr. Belvedere Fan Club</h1>
                <div><p>Hello</p></div>
              </body></html>"
    values = generate_values
    url = h.url
    swapped_body = i.switch_lang([body], values, url, 'ja', h)

    expected_body = "<html lang=\"ja\">
<head>
<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">
<script src=\"//j.wovn.io/1\" async=\"true\" data-wovnio=\"key=&amp;backend=true&amp;currentLang=ja&amp;defaultLang=en&amp;urlPattern=path&amp;langCodeAliases={}&amp;version=#{Wovnrb::VERSION}\"> </script><noscript><!-- --><div>test</div></noscript>
<link rel=\"alternate\" hreflang=\"ja\" href=\"http://ja.page.com/\">
</head>
<body>
<h1>
<!--wovn-src:Mr. Belvedere Fan Club-->ベルベデアさんファンクラブ</h1>
                <div><p><!--wovn-src:Hello-->こんにちは</p></div>
              </body>
</html>
"
    assert_equal([expected_body], swapped_body)
  end

  def test_switch_lang_with_commented_noscript_in_head
    i = Wovnrb::Interceptor.new(get_app)
    h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://page.com'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    body =  "<html><head><!--<noscript><div>test</div></noscript>--></head><body><h1>Mr. Belvedere Fan Club</h1>
                <div><p>Hello</p></div>
              </body></html>"
    values = generate_values
    url = h.url
    swapped_body = i.switch_lang([body], values, url, 'ja', h)

    expected_body = "<html lang=\"ja\">
<head>
<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">
<script src=\"//j.wovn.io/1\" async=\"true\" data-wovnio=\"key=&amp;backend=true&amp;currentLang=ja&amp;defaultLang=en&amp;urlPattern=path&amp;langCodeAliases={}&amp;version=#{Wovnrb::VERSION}\"> </script><!--<noscript><div>test</div></noscript>--><link rel=\"alternate\" hreflang=\"ja\" href=\"http://ja.page.com/\">
</head>
<body>
<h1>
<!--wovn-src:Mr. Belvedere Fan Club-->ベルベデアさんファンクラブ</h1>
                <div><p><!--wovn-src:Hello-->こんにちは</p></div>
              </body>
</html>
"
    assert_equal([expected_body], swapped_body)
  end

  def get_app
    RackMock.new
  end

  def generate_values
    values = {}
    values['text_vals'] = {'Hello' => {'ja' => [{'data' => 'こんにちは'}]},
      'Mr. Belvedere Fan Club' => {'ja' => [{'data' => 'ベルベデアさんファンクラブ'}]}}
    return values
  end

  class RackMock
    def call(env)
      [200, {'Content-Type' => 'text/html'}, ['']]
    end
  end
end
