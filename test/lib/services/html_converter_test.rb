require 'test_helper'

module Wovnrb
  class HtmlConverterTest < WovnMiniTest
    def test_api_build_compatible_html
      converter = prepare_html_converter('<html><body><a>hello</a></body></html>', 'supported_langs': ['en', 'vi'])
      converted_html, _ = converter.build_api_compatible_html

      expected_html = "<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\"><script src=\"//j.dev-wovn.io:3000/1\" async=\"true\" data-wovnio=\"key=123456&amp;amp;backend=true&amp;amp;currentLang=en&amp;amp;defaultLang=en&amp;amp;urlPattern=query&amp;amp;langCodeAliases={}&amp;amp;version=WOVN.rb_#{VERSION}\" data-wovnio-type=\"fallback_snippet\"></script><link rel=\"alternate\" hreflang=\"en\" href=\"http://my-site.com/\"><link rel=\"alternate\" hreflang=\"vi\" href=\"http://my-site.com/?wovn=vi\"></head><body><a>hello</a></body></html>"
      assert_equal(expected_html, converted_html)
    end

    def test_api_build_compatible_html_not_fail_for_big_content
      long_string = 'a' * 60000
      converter = prepare_html_converter('<html><body><p>' + long_string + '</p></body></html>', 'supported_langs': ['en', 'vi'])
      converted_html, _ = converter.build_api_compatible_html

      expected_html = "<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\"><script src=\"//j.dev-wovn.io:3000/1\" async=\"true\" data-wovnio=\"key=123456&amp;amp;backend=true&amp;amp;currentLang=en&amp;amp;defaultLang=en&amp;amp;urlPattern=query&amp;amp;langCodeAliases={}&amp;amp;version=WOVN.rb_#{VERSION}\" data-wovnio-type=\"fallback_snippet\"></script><link rel=\"alternate\" hreflang=\"en\" href=\"http://my-site.com/\"><link rel=\"alternate\" hreflang=\"vi\" href=\"http://my-site.com/?wovn=vi\"></head><body><p>" + long_string + '</p></body></html>'
      assert_equal(expected_html, converted_html)
    end

    def test_transform_html
      converter = prepare_html_converter('<html><body><a>hello</a></body></html>', supported_langs: %w(en vi))
      translated_html = converter.build

      expected_html = "<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\"><script src=\"//j.dev-wovn.io:3000/1\" async=\"true\" data-wovnio=\"key=123456&amp;amp;backend=true&amp;amp;currentLang=en&amp;amp;defaultLang=en&amp;amp;urlPattern=query&amp;amp;langCodeAliases={}&amp;amp;version=WOVN.rb_#{VERSION}\" data-wovnio-type=\"fallback_snippet\"></script><link rel=\"alternate\" hreflang=\"en\" href=\"http://my-site.com/\"><link rel=\"alternate\" hreflang=\"vi\" href=\"http://my-site.com/?wovn=vi\"></head><body><a>hello</a></body></html>"
      assert_equal(expected_html, translated_html)
    end

    def test_transform_html_with_empty_supported_langs
      converter = prepare_html_converter('<html><body><a>hello</a></body></html>', 'supported_langs': [])
      translated_html = converter.build

      expected_html = "<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\"><script src=\"//j.dev-wovn.io:3000/1\" async=\"true\" data-wovnio=\"key=123456&amp;amp;backend=true&amp;amp;currentLang=en&amp;amp;defaultLang=en&amp;amp;urlPattern=query&amp;amp;langCodeAliases={}&amp;amp;version=WOVN.rb_#{VERSION}\" data-wovnio-type=\"fallback_snippet\"></script></head><body><a>hello</a></body></html>"
      assert_equal(expected_html, translated_html)
    end

    def test_transform_html_with_head_tag
      converter = prepare_html_converter('<html><head><title>TITLE</title></head><body><a>hello</a></body></html>', 'supported_langs': ['en', 'vi'])
      translated_html = converter.build

      expected_html = "<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\"><script src=\"//j.dev-wovn.io:3000/1\" async=\"true\" data-wovnio=\"key=123456&amp;amp;backend=true&amp;amp;currentLang=en&amp;amp;defaultLang=en&amp;amp;urlPattern=query&amp;amp;langCodeAliases={}&amp;amp;version=WOVN.rb_#{VERSION}\" data-wovnio-type=\"fallback_snippet\"></script><title>TITLE</title><link rel=\"alternate\" hreflang=\"en\" href=\"http://my-site.com/\"><link rel=\"alternate\" hreflang=\"vi\" href=\"http://my-site.com/?wovn=vi\"></head><body><a>hello</a></body></html>"
      assert_equal(expected_html, translated_html)
    end

    def test_transform_html_without_body
      converter = prepare_html_converter('<html>hello<a>world</a></html>', 'supported_langs': [])
      translated_html = converter.build

      expected_html = "<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\"><script src=\"//j.dev-wovn.io:3000/1\" async=\"true\" data-wovnio=\"key=123456&amp;amp;backend=true&amp;amp;currentLang=en&amp;amp;defaultLang=en&amp;amp;urlPattern=query&amp;amp;langCodeAliases={}&amp;amp;version=WOVN.rb_#{VERSION}\" data-wovnio-type=\"fallback_snippet\"></script></head><body>hello<a>world</a></body></html>"
      assert_equal(expected_html, translated_html)
    end

    def test_transform_html_on_default_lang_with_query_pattern_and_supported_lang
      dom = get_dom('<html>hello<a>world</a></html>')
      settings = {
        'default_lang' => 'en',
        'supported_langs' => %w(en ja vi),
        'url_pattern' => 'query'
      }
      store, headers = store_headers_factory(settings)
      converter = HtmlConverter.new(dom, store, headers)
      translated_html = converter.build

      expected_html = "<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\"><script src=\"//j.dev-wovn.io:3000/1\" async=\"true\" data-wovnio=\"key=123456&amp;amp;backend=true&amp;amp;currentLang=en&amp;amp;defaultLang=en&amp;amp;urlPattern=query&amp;amp;langCodeAliases={}&amp;amp;version=WOVN.rb_#{VERSION}\" data-wovnio-type=\"fallback_snippet\"></script><link rel=\"alternate\" hreflang=\"en\" href=\"http://my-site.com/\"><link rel=\"alternate\" hreflang=\"ja\" href=\"http://my-site.com/?wovn=ja\"><link rel=\"alternate\" hreflang=\"vi\" href=\"http://my-site.com/?wovn=vi\"></head><body>hello<a>world</a></body></html>"
      assert_equal(expected_html, translated_html)
    end

    def test_transform_html_on_default_lang_with_path_pattern_and_supported_lang
      dom = get_dom('<html>hello<a>world</a></html>')
      settings = {
        'default_lang' => 'en',
        'supported_langs' => %w(en ja vi),
        'url_pattern' => 'path'
      }
      store, headers = store_headers_factory(settings)
      converter = HtmlConverter.new(dom, store, headers)
      translated_html = converter.build

      expected_html = "<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\"><script src=\"//j.dev-wovn.io:3000/1\" async=\"true\" data-wovnio=\"key=123456&amp;amp;backend=true&amp;amp;currentLang=en&amp;amp;defaultLang=en&amp;amp;urlPattern=path&amp;amp;langCodeAliases={}&amp;amp;version=WOVN.rb_#{VERSION}\" data-wovnio-type=\"fallback_snippet\"></script><link rel=\"alternate\" hreflang=\"en\" href=\"http://my-site.com/\"><link rel=\"alternate\" hreflang=\"ja\" href=\"http://my-site.com/ja/\"><link rel=\"alternate\" hreflang=\"vi\" href=\"http://my-site.com/vi/\"></head><body>hello<a>world</a></body></html>"
      assert_equal(expected_html, translated_html)
    end

    def test_replace_snippet
      converter = prepare_html_converter('<html><head><script src="/a"></script><script src="//j.wovn.io/1" async="true"</head></html>')
      converter.send(:replace_snippet)

      expected_html = "<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\"><script src=\"//j.dev-wovn.io:3000/1\" async=\"true\" data-wovnio=\"key=123456&amp;amp;backend=true&amp;amp;currentLang=en&amp;amp;defaultLang=en&amp;amp;urlPattern=query&amp;amp;langCodeAliases={}&amp;amp;version=WOVN.rb_1.2.0-beta\" data-wovnio-type=\"fallback_snippet\"></script><script src=\"/a\"></script></head><body></body></html>"
      assert_equal(expected_html, converter.html)
    end

    def test_replace_hreflangs
      converter = prepare_html_converter('<html><head><link rel="alternate" hreflang="en" href="https://wovn.io/en/"></head></html>')
      converter.send(:replace_hreflangs)

      expected_html = "<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\"><link rel=\"alternate\" hreflang=\"en\" href=\"http://my-site.com/\"><link rel=\"alternate\" hreflang=\"fr\" href=\"http://my-site.com/?wovn=fr\"><link rel=\"alternate\" hreflang=\"ja\" href=\"http://my-site.com/?wovn=ja\"><link rel=\"alternate\" hreflang=\"vi\" href=\"http://my-site.com/?wovn=vi\"></head><body></body></html>"
      assert_equal(expected_html, converter.html)
    end

    def test_inject_lang_html_tag
      settings = {
        'project_token' => '123456',
        'custom_lang_aliases' => {},
        'default_lang' => 'en',
        'url_pattern' => 'query',
        'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)',
        'supported_langs' => ['en', 'fr', 'ja', 'vi']
      }

      store = Wovnrb::Store.instance
      store.update_settings(settings)

      headers = Wovnrb::Headers.new(
        Wovnrb.get_env('url' => "http://my-site.com/?wovn=ja"),
        Wovnrb.get_settings(settings)
      )
      converter = HtmlConverter.new(get_dom('<html><body>hello</body></html>'), store, headers)
      converter.send(:inject_lang_html_tag)
      expected_html = "<html lang=\"ja\"><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\"></head><body>hello</body></html>"
      assert_equal(expected_html, converter.html)
    end

    private

    def prepare_html_converter(input_html, store_options = {})
      store, headers = store_headers_factory(store_options)
      HtmlConverter.new(get_dom(input_html), store, headers)
    end

    def html
      [
        '<html><head><meta charset="utf-8">',
        '<script src="//j.wovn.io/1" data-wovnio="key=4tok3n" async></script>',
        '<link rel="alternate" href="/" hreflang="en">',
        '<link rel="alternate" href="/ja" hreflang="ja">',
        '</head>',
        '<body>',
        '<div>Simple content</div>',
        '<div wovn-ignore>This content should be ignored</div>',
        '</body>',
        '</html>'
      ].join()
    end

    def store_headers_factory(setting_opts = {})
      setting_opts = {
        'project_token' => '123456',
        'custom_lang_aliases' => {},
        'default_lang' => 'en',
        'url_pattern' => 'query',
        'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)',
        'supported_langs' => ['en', 'fr', 'ja', 'vi']
      }.merge(setting_opts)

      store = Wovnrb::Store.instance
      store.update_settings(setting_opts)

      headers = Wovnrb::Headers.new(
        Wovnrb.get_env('url' => "http://my-site.com"),
        Wovnrb.get_settings(setting_opts)
      )

      [store, headers]
    end

    def get_dom(html)
      Helpers::NokogumboHelper::parse_html(html)
    end
  end
end
