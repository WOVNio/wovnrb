# -*- coding: utf-8 -*-
require 'wovnrb'
require 'wovnrb/headers'
require 'minitest/autorun'
require 'webmock/minitest'
require 'rack'
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

    i = Wovnrb::Interceptor.new(get_app, settings)

    i.call(Wovnrb.get_env)
    i.call(Wovnrb.get_env)
    assert_requested(stub, :times => 1)
  end

  def test_request_wovn_token
    settings = Wovnrb.get_settings
    default_token = 'token0'
    request_token = 'token1'
    settings['project_token'] = default_token
    url = 'wovn.io/dashboard'
    stub = stub_request(:get, "#{settings['api_url']}?token=#{request_token}&url=#{url}").
      to_return(:body => '{"test_body": "a"}')

    app = get_app(:params => {'wovn_token' => request_token})
    i = Wovnrb::Interceptor.new(app, settings)

    env = Wovnrb.get_env
    i.call(env)
    assert_requested(stub, :times => 1)

    # check use default a token after use dynamic token
    stub_default = stub_request(:get, "#{settings['api_url']}?token=#{default_token}&url=#{url}").
      to_return(:body => '{"test_body": "a"}')
    app.params.clear
    env['rack.request.query_hash'] = {}
    i.call(env)
    assert_requested(stub_default, :times => 1)
  end

  def test_request_invalid_wovn_token
    settings = Wovnrb.get_settings
    settings['project_token'] = 'token0'
    request_token = 'invalidtoken1'
    url = 'wovn.io/dashboard'
    stub = stub_request(:get, "#{settings['api_url']}?token=#{settings['project_token']}&url=#{url}").
      to_return(:body => '{"test_body": "a"}')

    i = Wovnrb::Interceptor.new(get_app(:params => {'wovn_token' => settings['project_token']}), settings)

    env = Wovnrb.get_env
    i.call(env)
    assert_requested(stub, :times => 1)
  end

  def test_request_wovn_ignore_paths
    settings = Wovnrb.get_settings
    url = 'wovn.io/dashboard'
    stub = stub_request(:get, "#{settings['api_url']}?token=#{settings['project_token']}&url=#{url}").
      to_return(:body => '{"test_body": "a"}')

    app = get_app(:params => {'wovn_ignore_paths' => ['/dashboard']})
    i = Wovnrb::Interceptor.new(app, settings)

    env = Wovnrb.get_env
    i.call(env)
    assert_requested(stub, :times => 0)
  end

  def test_request_wovn_disable
    settings = Wovnrb.get_settings
    token = settings['project_token']
    url = 'wovn.io/dashboard'
    stub = stub_request(:get, "#{settings['api_url']}?token=#{token}&url=#{url}").
      to_return(:body => '{"test_body": "a"}')

    i = Wovnrb::Interceptor.new(get_app(:params => {'wovn_disable' => true}), settings)

    env = Wovnrb.get_env
    i.call(env)
    assert_requested(stub, :times => 0)
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
<link rel=\"alternate\" hreflang=\"en\" href=\"http://page.com/\">
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

  def test_switch_lang_ignores_amp
    interceptor = Wovnrb::Interceptor.new(get_app)
    headers = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://page.com'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    body = <<HTML
<html amp>
<head><noscript><style amp-boilerplate>body{-webkit-animation:none;-moz-animation:none;-ms-animation:none;animation:none}</style></noscript></head>
<body>
  <h1>Mr. Belvedere Fan Club</h1>
  <div><p>Hello</p></div>
</body>
</html>
HTML
    expected_body = <<HTML
<html amp="">
<head>
<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">
<noscript><style amp-boilerplate>body{-webkit-animation:none;-moz-animation:none;-ms-animation:none;animation:none}</style></noscript>
</head>
<body>
  <h1>Mr. Belvedere Fan Club</h1>
  <div><p>Hello</p></div>


</body>
</html>
HTML
    values = generate_values
    url = headers.url
    swapped_bodies = interceptor.switch_lang([body], values, url, 'ja', headers)

    assert_equal([expected_body], swapped_bodies)
  end

  def test_switch_lang_ignores_amp_defined_with_symbol_attribute
    interceptor = Wovnrb::Interceptor.new(get_app)
    headers = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://page.com'), Wovnrb.get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    body = <<HTML
<html ⚡>
<body>
  <h1>Mr. Belvedere Fan Club</h1>
  <div><p>Hello</p></div>
</body>
</html>
HTML
    expected_body = <<HTML
<html ⚡="">
<head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\"></head>
<body>
  <h1>Mr. Belvedere Fan Club</h1>
  <div><p>Hello</p></div>


</body>
</html>
HTML
    values = generate_values
    url = headers.url
    swapped_bodies = interceptor.switch_lang([body], values, url, 'ja', headers)

    assert_equal([expected_body], swapped_bodies)
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
<link rel=\"alternate\" hreflang=\"en\" href=\"http://page.com/\">
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
<link rel=\"alternate\" hreflang=\"en\" href=\"http://page.com/\">
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
<link rel=\"alternate\" hreflang=\"en\" href=\"http://page.com/\">
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
<link rel=\"alternate\" hreflang=\"en\" href=\"http://page.com/\">
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
<link rel=\"alternate\" hreflang=\"en\" href=\"http://page.com/\">
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

  def get_app(opts={})
    RackMock.new(opts)
  end

  def generate_values
    values = {}
    values['text_vals'] = {'Hello' => {'ja' => [{'data' => 'こんにちは'}]},
      'Mr. Belvedere Fan Club' => {'ja' => [{'data' => 'ベルベデアさんファンクラブ'}]}}
    return values
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
