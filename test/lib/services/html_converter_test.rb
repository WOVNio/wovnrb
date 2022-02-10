require 'test_helper'

module Wovnrb
  class HtmlConverterTest < WovnMiniTest
    def test_build_api_compatible_html
      converter = prepare_html_converter('<html><body><a class="test">hello</a></body></html>', supported_langs: %w[en vi])
      converted_html, = converter.build_api_compatible_html

      expected_html = "<html lang=\"en\"><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\"><script src=\"https://j.wovn.io/1\" async=\"true\" data-wovnio=\"key=123456&amp;backend=true&amp;currentLang=en&amp;defaultLang=en&amp;urlPattern=query&amp;langCodeAliases={}&amp;langParamName=wovn&amp;version=WOVN.rb_#{VERSION}\" data-wovnio-type=\"fallback_snippet\"></script><link rel=\"alternate\" hreflang=\"en\" href=\"http://my-site.com/\"><link rel=\"alternate\" hreflang=\"vi\" href=\"http://my-site.com/?wovn=vi\"></head><body><a class=\"test\">hello</a></body></html>"
      assert_equal(expected_html, converted_html)
    end

    def test_build_api_compatible_html_with_custom_lang_param_name
      settings = {
        supported_langs: %w[en vi],
        url_lang_pattern: 'query',
        lang_param_name: 'lang'
      }
      converter = prepare_html_converter('<html><body><a class="test">hello</a></body></html>', settings)
      converted_html, = converter.build_api_compatible_html

      expected_html = "<html lang=\"en\"><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\"><script src=\"https://j.wovn.io/1\" async=\"true\" data-wovnio=\"key=123456&amp;backend=true&amp;currentLang=en&amp;defaultLang=en&amp;urlPattern=query&amp;langCodeAliases={}&amp;langParamName=lang&amp;version=WOVN.rb_#{VERSION}\" data-wovnio-type=\"fallback_snippet\"></script><link rel=\"alternate\" hreflang=\"en\" href=\"http://my-site.com/\"><link rel=\"alternate\" hreflang=\"vi\" href=\"http://my-site.com/?lang=vi\"></head><body><a class=\"test\">hello</a></body></html>"
      assert_equal(expected_html, converted_html)
    end

    def test_build_api_compatible_html_not_fail_for_big_content
      long_string = 'a' * 60_000
      converter = prepare_html_converter("<html><body><p>#{long_string}</p></body></html>", supported_langs: %w[en vi])
      converted_html, = converter.build_api_compatible_html

      expected_html = "<html lang=\"en\"><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\"><script src=\"https://j.wovn.io/1\" async=\"true\" data-wovnio=\"key=123456&amp;backend=true&amp;currentLang=en&amp;defaultLang=en&amp;urlPattern=query&amp;langCodeAliases={}&amp;langParamName=wovn&amp;version=WOVN.rb_#{VERSION}\" data-wovnio-type=\"fallback_snippet\"></script><link rel=\"alternate\" hreflang=\"en\" href=\"http://my-site.com/\"><link rel=\"alternate\" hreflang=\"vi\" href=\"http://my-site.com/?wovn=vi\"></head><body><p>#{long_string}</p></body></html>"
      assert_equal(expected_html, converted_html)
    end

    def test_build_api_compatible_html_ignored_content_should_not_be_sent
      html = [
        '<html><body>',
        '<p>Hello <span wovn-ignore>WOVN</span><p>',
        '<p>Hello <span data-wovn-ignore>WOVN</span><p>',
        '<div><span class="ignore-me">should be ignored</span></div>',
        '<span>Have a nice day!</span>',
        '</body></html>'
      ].join

      converter = prepare_html_converter(html, ignore_class: ['ignore-me'])
      converted_html, = converter.build_api_compatible_html

      expected_convert_html = "<html lang=\"en\"><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\"><script src=\"https://j.wovn.io/1\" async=\"true\" data-wovnio=\"key=123456&amp;backend=true&amp;currentLang=en&amp;defaultLang=en&amp;urlPattern=query&amp;langCodeAliases={}&amp;langParamName=wovn&amp;version=WOVN.rb_#{VERSION}\" data-wovnio-type=\"fallback_snippet\"></script><link rel=\"alternate\" hreflang=\"en\" href=\"http://my-site.com/\"><link rel=\"alternate\" hreflang=\"fr\" href=\"http://my-site.com/?wovn=fr\"><link rel=\"alternate\" hreflang=\"ja\" href=\"http://my-site.com/?wovn=ja\"><link rel=\"alternate\" hreflang=\"vi\" href=\"http://my-site.com/?wovn=vi\"></head><body><p>Hello <span wovn-ignore=\"\"><!-- __wovn-backend-ignored-key-0 --></span></p><p></p><p>Hello <span data-wovn-ignore=\"\"><!-- __wovn-backend-ignored-key-1 --></span></p><p></p><div><span class=\"ignore-me\"><!-- __wovn-backend-ignored-key-2 --></span></div><span>Have a nice day!</span></body></html>"
      assert_equal(expected_convert_html, converted_html)
    end

    def test_build_api_compatible_html_form_should_not_be_sent
      html = [
        '<html><body>',
        '<form action="/test" method="POST">',
        '<input id="name" type="text">',
        '<button type="submit">Submit</button>',
        '</form>',
        '</body></html>'
      ].join

      converter = prepare_html_converter(html, ignore_class: [])
      converted_html, = converter.build_api_compatible_html

      expected_convert_html = "<html lang=\"en\"><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\"><script src=\"https://j.wovn.io/1\" async=\"true\" data-wovnio=\"key=123456&amp;backend=true&amp;currentLang=en&amp;defaultLang=en&amp;urlPattern=query&amp;langCodeAliases={}&amp;langParamName=wovn&amp;version=WOVN.rb_#{VERSION}\" data-wovnio-type=\"fallback_snippet\"></script><link rel=\"alternate\" hreflang=\"en\" href=\"http://my-site.com/\"><link rel=\"alternate\" hreflang=\"fr\" href=\"http://my-site.com/?wovn=fr\"><link rel=\"alternate\" hreflang=\"ja\" href=\"http://my-site.com/?wovn=ja\"><link rel=\"alternate\" hreflang=\"vi\" href=\"http://my-site.com/?wovn=vi\"></head><body><form action=\"/test\" method=\"POST\"><!-- __wovn-backend-ignored-key-0 --></form></body></html>"
      assert_equal(expected_convert_html, converted_html)
    end

    def test_build_api_compatible_html_hidden_input_should_not_be_sent
      html = [
        '<html><body>',
        '<input id="user-id" type="hidden" value="secret-id">',
        '<input id="password" type="hidden" value="secret-password">',
        '<input id="something" type="hidden" value="">',
        '<input id="name" type="text" value="wovn.io">',
        '</body></html>'
      ].join

      converter = prepare_html_converter(html, ignore_class: [])
      converted_html, = converter.build_api_compatible_html

      expected_convert_html = [
        '<html lang="en"><head>',
        "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\"><script src=\"https://j.wovn.io/1\" async=\"true\" data-wovnio=\"key=123456&amp;backend=true&amp;currentLang=en&amp;defaultLang=en&amp;urlPattern=query&amp;langCodeAliases={}&amp;langParamName=wovn&amp;version=WOVN.rb_#{VERSION}\" data-wovnio-type=\"fallback_snippet\"></script><link rel=\"alternate\" hreflang=\"en\" href=\"http://my-site.com/\"><link rel=\"alternate\" hreflang=\"fr\" href=\"http://my-site.com/?wovn=fr\"><link rel=\"alternate\" hreflang=\"ja\" href=\"http://my-site.com/?wovn=ja\"><link rel=\"alternate\" hreflang=\"vi\" href=\"http://my-site.com/?wovn=vi\"></head><body>",
        '<input id="user-id" type="hidden" value="__wovn-backend-ignored-key-0">',
        '<input id="password" type="hidden" value="__wovn-backend-ignored-key-1">',
        '<input id="something" type="hidden" value="__wovn-backend-ignored-key-2">',
        '<input id="name" type="text" value="wovn.io">',
        '</body></html>'
      ].join
      assert_equal(expected_convert_html, converted_html)
    end

    def test_transform_html
      converter = prepare_html_converter('<html><body><a>hello</a></body></html>', supported_langs: %w[en vi])
      translated_html = converter.build

      expected_html = "<html lang=\"en\"><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\"><script src=\"https://j.wovn.io/1\" async=\"true\" data-wovnio=\"key=123456&amp;backend=true&amp;currentLang=en&amp;defaultLang=en&amp;urlPattern=query&amp;langCodeAliases={}&amp;langParamName=wovn&amp;version=WOVN.rb_#{VERSION}\" data-wovnio-type=\"fallback_snippet\"></script><link rel=\"alternate\" hreflang=\"en\" href=\"http://my-site.com/\"><link rel=\"alternate\" hreflang=\"vi\" href=\"http://my-site.com/?wovn=vi\"></head><body><a>hello</a></body></html>"
      assert_equal(expected_html, translated_html)
    end

    def test_transform_html_with_empty_supported_langs
      converter = prepare_html_converter('<html><body><a>hello</a></body></html>', supported_langs: [])
      translated_html = converter.build

      expected_html = "<html lang=\"en\"><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\"><script src=\"https://j.wovn.io/1\" async=\"true\" data-wovnio=\"key=123456&amp;backend=true&amp;currentLang=en&amp;defaultLang=en&amp;urlPattern=query&amp;langCodeAliases={}&amp;langParamName=wovn&amp;version=WOVN.rb_#{VERSION}\" data-wovnio-type=\"fallback_snippet\"></script></head><body><a>hello</a></body></html>"
      assert_equal(expected_html, translated_html)
    end

    def test_transform_html_with_head_tag
      converter = prepare_html_converter('<html><head><title>TITLE</title></head><body><a>hello</a></body></html>', supported_langs: %w[en vi])
      translated_html = converter.build

      expected_html = "<html lang=\"en\"><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\"><script src=\"https://j.wovn.io/1\" async=\"true\" data-wovnio=\"key=123456&amp;backend=true&amp;currentLang=en&amp;defaultLang=en&amp;urlPattern=query&amp;langCodeAliases={}&amp;langParamName=wovn&amp;version=WOVN.rb_#{VERSION}\" data-wovnio-type=\"fallback_snippet\"></script><title>TITLE</title><link rel=\"alternate\" hreflang=\"en\" href=\"http://my-site.com/\"><link rel=\"alternate\" hreflang=\"vi\" href=\"http://my-site.com/?wovn=vi\"></head><body><a>hello</a></body></html>"
      assert_equal(expected_html, translated_html)
    end

    def test_transform_html_without_body
      converter = prepare_html_converter('<html>hello<a>world</a></html>', supported_langs: [])
      translated_html = converter.build

      expected_html = "<html lang=\"en\"><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\"><script src=\"https://j.wovn.io/1\" async=\"true\" data-wovnio=\"key=123456&amp;backend=true&amp;currentLang=en&amp;defaultLang=en&amp;urlPattern=query&amp;langCodeAliases={}&amp;langParamName=wovn&amp;version=WOVN.rb_#{VERSION}\" data-wovnio-type=\"fallback_snippet\"></script></head><body>hello<a>world</a></body></html>"
      assert_equal(expected_html, translated_html)
    end

    def test_transform_html_on_default_lang_with_query_pattern_and_supported_lang
      dom = get_dom('<html>hello<a>world</a></html>')
      settings = {
        'default_lang' => 'en',
        'supported_langs' => %w[en ja vi],
        'url_pattern' => 'query'
      }
      store, headers = store_headers_factory(settings)
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)
      converter = HtmlConverter.new(dom, store, headers, url_lang_switcher)
      translated_html = converter.build

      expected_html = "<html lang=\"en\"><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\"><script src=\"https://j.wovn.io/1\" async=\"true\" data-wovnio=\"key=123456&amp;backend=true&amp;currentLang=en&amp;defaultLang=en&amp;urlPattern=query&amp;langCodeAliases={}&amp;langParamName=wovn&amp;version=WOVN.rb_#{VERSION}\" data-wovnio-type=\"fallback_snippet\"></script><link rel=\"alternate\" hreflang=\"en\" href=\"http://my-site.com/\"><link rel=\"alternate\" hreflang=\"ja\" href=\"http://my-site.com/?wovn=ja\"><link rel=\"alternate\" hreflang=\"vi\" href=\"http://my-site.com/?wovn=vi\"></head><body>hello<a>world</a></body></html>"
      assert_equal(expected_html, translated_html)
    end

    def test_transform_html_on_target_lang_translate_canonical_tag
      dom = get_dom('<html><head><link rel="canonical" href="http://my-site.com/" /></head><body></body></html>')
      settings = {
        'default_lang' => 'en',
        'supported_langs' => %w[en ja vi],
        'url_pattern' => 'path',
        'translate_canonical_tag' => true
      }
      store, headers = store_headers_factory(settings, 'http://my-site.com/vi/')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)
      converter = HtmlConverter.new(dom, store, headers, url_lang_switcher)
      translated_html = converter.build

      expected_html = "<html lang=\"en\"><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\"><script src=\"https://j.wovn.io/1\" async=\"true\" data-wovnio=\"key=123456&amp;backend=true&amp;currentLang=vi&amp;defaultLang=en&amp;urlPattern=path&amp;langCodeAliases={}&amp;langParamName=wovn&amp;version=WOVN.rb_#{VERSION}\" data-wovnio-type=\"fallback_snippet\"></script><link rel=\"canonical\" href=\"http://my-site.com/vi/\"><link rel=\"alternate\" hreflang=\"en\" href=\"http://my-site.com/\"><link rel=\"alternate\" hreflang=\"ja\" href=\"http://my-site.com/ja/\"><link rel=\"alternate\" hreflang=\"vi\" href=\"http://my-site.com/vi/\"></head><body></body></html>"
      assert_equal(expected_html, translated_html)
    end

    def test_transform_html_on_default_lang_do_not_change_canonical_tag_path_pattern
      dom = get_dom('<html><head><link rel="canonical" href="http://my-site.com/" /></head><body></body></html>')
      settings = {
        'default_lang' => 'en',
        'supported_langs' => %w[en ja vi],
        'url_pattern' => 'path',
        'translate_canonical_tag' => true
      }
      store, headers = store_headers_factory(settings, 'http://my-site.com/')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)
      converter = HtmlConverter.new(dom, store, headers, url_lang_switcher)
      translated_html = converter.build

      expected_html = "<html lang=\"en\"><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\"><script src=\"https://j.wovn.io/1\" async=\"true\" data-wovnio=\"key=123456&amp;backend=true&amp;currentLang=en&amp;defaultLang=en&amp;urlPattern=path&amp;langCodeAliases={}&amp;langParamName=wovn&amp;version=WOVN.rb_#{VERSION}\" data-wovnio-type=\"fallback_snippet\"></script><link rel=\"canonical\" href=\"http://my-site.com/\"><link rel=\"alternate\" hreflang=\"en\" href=\"http://my-site.com/\"><link rel=\"alternate\" hreflang=\"ja\" href=\"http://my-site.com/ja/\"><link rel=\"alternate\" hreflang=\"vi\" href=\"http://my-site.com/vi/\"></head><body></body></html>"
      assert_equal(expected_html, translated_html)
    end

    def test_transform_html_on_default_lang_do_not_change_canonical_tag_query_pattern
      dom = get_dom('<html><head><link rel="canonical" href="http://my-site.com/" /></head><body></body></html>')
      settings = {
        'default_lang' => 'en',
        'supported_langs' => %w[en ja vi],
        'url_pattern' => 'query',
        'translate_canonical_tag' => true
      }
      store, headers = store_headers_factory(settings, 'http://my-site.com/')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)
      converter = HtmlConverter.new(dom, store, headers, url_lang_switcher)
      translated_html = converter.build

      expected_html = "<html lang=\"en\"><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\"><script src=\"https://j.wovn.io/1\" async=\"true\" data-wovnio=\"key=123456&amp;backend=true&amp;currentLang=en&amp;defaultLang=en&amp;urlPattern=query&amp;langCodeAliases={}&amp;langParamName=wovn&amp;version=WOVN.rb_#{VERSION}\" data-wovnio-type=\"fallback_snippet\"></script><link rel=\"canonical\" href=\"http://my-site.com/\"><link rel=\"alternate\" hreflang=\"en\" href=\"http://my-site.com/\"><link rel=\"alternate\" hreflang=\"ja\" href=\"http://my-site.com/?wovn=ja\"><link rel=\"alternate\" hreflang=\"vi\" href=\"http://my-site.com/?wovn=vi\"></head><body></body></html>"
      assert_equal(expected_html, translated_html)
    end

    def test_transform_html_on_default_lang_with_default_lang_alias
      dom = get_dom('<html><head><link rel="canonical" href="http://my-site.com/" /></head><body></body></html>')
      settings = {
        'default_lang' => 'en',
        'supported_langs' => %w[en ja vi],
        'url_pattern' => 'query',
        'translate_canonical_tag' => true,
        'custom_lang_aliases' => { 'en' => 'english' }
      }
      store, headers = store_headers_factory(settings, 'http://my-site.com/')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)
      converter = HtmlConverter.new(dom, store, headers, url_lang_switcher)
      translated_html = converter.build

      expected_html = '<html lang="en"><head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8"><script src="https://j.wovn.io/1" async="true" data-wovnio="key=123456&amp;backend=true&amp;currentLang=en&amp;defaultLang=en&amp;urlPattern=query&amp;langCodeAliases={&quot;en&quot;:&quot;english&quot;}&amp;langParamName=wovn&amp;version=WOVN.rb_3.5.0" data-wovnio-type="fallback_snippet"></script><link rel="canonical" href="http://my-site.com/?wovn=english"><link rel="alternate" hreflang="en" href="http://my-site.com/"><link rel="alternate" hreflang="ja" href="http://my-site.com/?wovn=ja"><link rel="alternate" hreflang="vi" href="http://my-site.com/?wovn=vi"></head><body></body></html>'
      assert_equal(expected_html, translated_html)
    end

    def test_transform_html_on_target_lang_do_not_translate_canonical_tag
      dom = get_dom('<html><head><link rel="canonical" href="http://my-site.com/" /></head><body></body></html>')
      settings = {
        'default_lang' => 'en',
        'supported_langs' => %w[en ja vi],
        'url_pattern' => 'path',
        'translate_canonical_tag' => false
      }
      store, headers = store_headers_factory(settings, 'http://my-site.com/vi/')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)
      converter = HtmlConverter.new(dom, store, headers, url_lang_switcher)
      translated_html = converter.build

      expected_html = "<html lang=\"en\"><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\"><script src=\"https://j.wovn.io/1\" async=\"true\" data-wovnio=\"key=123456&amp;backend=true&amp;currentLang=vi&amp;defaultLang=en&amp;urlPattern=path&amp;langCodeAliases={}&amp;langParamName=wovn&amp;version=WOVN.rb_#{VERSION}\" data-wovnio-type=\"fallback_snippet\"></script><link rel=\"canonical\" href=\"http://my-site.com/\"><link rel=\"alternate\" hreflang=\"en\" href=\"http://my-site.com/\"><link rel=\"alternate\" hreflang=\"ja\" href=\"http://my-site.com/ja/\"><link rel=\"alternate\" hreflang=\"vi\" href=\"http://my-site.com/vi/\"></head><body></body></html>"
      assert_equal(expected_html, translated_html)
    end

    def test_transform_html_on_default_lang_with_path_pattern_and_supported_lang
      dom = get_dom('<html>hello<a>world</a></html>')
      settings = {
        'default_lang' => 'en',
        'supported_langs' => %w[en ja vi],
        'url_pattern' => 'path'
      }
      store, headers = store_headers_factory(settings)
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)
      converter = HtmlConverter.new(dom, store, headers, url_lang_switcher)
      translated_html = converter.build

      expected_html = "<html lang=\"en\"><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\"><script src=\"https://j.wovn.io/1\" async=\"true\" data-wovnio=\"key=123456&amp;backend=true&amp;currentLang=en&amp;defaultLang=en&amp;urlPattern=path&amp;langCodeAliases={}&amp;langParamName=wovn&amp;version=WOVN.rb_#{VERSION}\" data-wovnio-type=\"fallback_snippet\"></script><link rel=\"alternate\" hreflang=\"en\" href=\"http://my-site.com/\"><link rel=\"alternate\" hreflang=\"ja\" href=\"http://my-site.com/ja/\"><link rel=\"alternate\" hreflang=\"vi\" href=\"http://my-site.com/vi/\"></head><body>hello<a>world</a></body></html>"
      assert_equal(expected_html, translated_html)
    end

    def test_replace_snippet
      converter = prepare_html_converter('<html><head>
        <script src="/a"></script>
        <script src="//j.wovn.io/1" async="true">
        <script src="//j.wovn.io/1" data-wovnio="key=2wpv0n" async></script>
        <script src="https//cdn.wovn.io/" data-wovnio="key=2wpv0n async></script>
        <script src="https://wovn.global.ssl.fastly.net/widget/abcdef></script>
        </head></html>')
      converter.send(:replace_snippet)

      expected_html = "<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\"><script src=\"https://j.wovn.io/1\" async=\"true\" data-wovnio=\"key=123456&amp;backend=true&amp;currentLang=en&amp;defaultLang=en&amp;urlPattern=query&amp;langCodeAliases={}&amp;langParamName=wovn&amp;version=WOVN.rb_#{VERSION}\" data-wovnio-type=\"fallback_snippet\"></script><script src=\"/a\"></script></head><body></body></html>"
      assert_equal(expected_html.gsub(/\s+/, ''), converter.send(:html).gsub(/\s+/, ''))
    end

    def test_replace_hreflangs
      converter = prepare_html_converter('<html><head><link rel="alternate" hreflang="en" href="https://wovn.io/en/"></head></html>')
      converter.send(:replace_hreflangs)

      expected_html = '<html><head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8"><link rel="alternate" hreflang="en" href="http://my-site.com/"><link rel="alternate" hreflang="fr" href="http://my-site.com/?wovn=fr"><link rel="alternate" hreflang="ja" href="http://my-site.com/?wovn=ja"><link rel="alternate" hreflang="vi" href="http://my-site.com/?wovn=vi"></head><body></body></html>'
      assert_equal(expected_html, converter.send(:html))
    end

    def test_inject_lang_html_tag_with_no_lang_in_html_tag
      settings = default_store_settings
      store = Wovnrb::Store.instance
      store.update_settings(settings)

      headers = Wovnrb::Headers.new(
        Wovnrb.get_env('url' => 'http://my-site.com/'),
        Wovnrb.get_settings(settings)
      )
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)
      converter = HtmlConverter.new(get_dom('<html><body>hello</body></html>'), store, headers, url_lang_switcher)
      converter.send(:inject_lang_html_tag)
      expected_html = '<html lang="en"><head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8"></head><body>hello</body></html>'
      assert_equal(expected_html, converter.send(:html))
    end

    def test_inject_lang_html_tag_with_lang_in_html_tag
      settings = default_store_settings
      store = Wovnrb::Store.instance
      store.update_settings(settings)

      headers = Wovnrb::Headers.new(
        Wovnrb.get_env('url' => 'http://my-site.com/'),
        Wovnrb.get_settings(settings)
      )
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)
      converter = HtmlConverter.new(get_dom('<html lang="th"><body>hello</body></html>'), store, headers, url_lang_switcher)
      converter.send(:inject_lang_html_tag)
      expected_html = '<html lang="th"><head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8"></head><body>hello</body></html>'
      assert_equal(expected_html, converter.send(:html))
    end

    def test_translate_canonical_tag
      settings = default_store_settings
      store = Wovnrb::Store.instance
      store.update_settings(settings)

      headers = Wovnrb::Headers.new(
        Wovnrb.get_env('url' => 'http://my-site.com/?wovn=fr'),
        store.settings
      )
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)
      converter = HtmlConverter.new(get_dom('<html lang="th"><head><link rel="canonical" href="http://my-site.com" /></head><body>hello</body></html>'), store, headers, url_lang_switcher)
      converter.send(:translate_canonical_tag)
      expected_html = '<html lang="th"><head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8"><link rel="canonical" href="http://my-site.com?wovn=fr"></head><body>hello</body></html>'
      assert_equal(expected_html, converter.send(:html))
    end

    def test_translate_canonical_tag_path_pattern
      settings = default_store_settings
      settings['url_pattern'] = 'path'
      store = Wovnrb::Store.instance
      store.update_settings(settings)

      headers = Wovnrb::Headers.new(
        Wovnrb.get_env('url' => 'http://my-site.com/fr/'),
        store.settings
      )
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)
      converter = HtmlConverter.new(get_dom('<html lang="th"><head><link rel="canonical" href="http://my-site.com/" /></head><body>hello</body></html>'), store, headers, url_lang_switcher)
      converter.send(:translate_canonical_tag)
      expected_html = '<html lang="th"><head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8"><link rel="canonical" href="http://my-site.com/fr/"></head><body>hello</body></html>'
      assert_equal(expected_html, converter.send(:html))
    end

    def test_translate_canonical_tag_path_pattern_already_has_lang_code
      # NOTE: this behavior is not correct, but it is the same as html-swapper
      settings = default_store_settings
      settings['url_pattern'] = 'path'
      store = Wovnrb::Store.instance
      store.update_settings(settings)

      headers = Wovnrb::Headers.new(
        Wovnrb.get_env('url' => 'http://my-site.com/fr/'),
        store.settings
      )
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)
      converter = HtmlConverter.new(get_dom('<html lang="th"><head><link rel="canonical" href="http://my-site.com/fr/" /></head><body>hello</body></html>'), store, headers, url_lang_switcher)
      converter.send(:translate_canonical_tag)
      expected_html = '<html lang="th"><head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8"><link rel="canonical" href="http://my-site.com/fr/fr/"></head><body>hello</body></html>'
      assert_equal(expected_html, converter.send(:html))
    end

    private

    def prepare_html_converter(input_html, store_options = {})
      store, headers = store_headers_factory(store_options)
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)
      HtmlConverter.new(get_dom(input_html), store, headers, url_lang_switcher)
    end

    def store_headers_factory(setting_opts = {}, url = 'http://my-site.com')
      settings = default_store_settings.merge(setting_opts)
      store = Wovnrb::Store.instance
      store.update_settings(settings)

      headers = Wovnrb::Headers.new(
        Wovnrb.get_env('url' => url),
        store.settings
      )

      [store, headers]
    end

    def default_store_settings
      {
        'project_token' => '123456',
        'custom_lang_aliases' => {},
        'default_lang' => 'en',
        'url_pattern' => 'query',
        'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|)',
        'supported_langs' => %w[en fr ja vi]
      }
    end

    def get_dom(html)
      Helpers::NokogumboHelper.parse_html(html)
    end
  end
end
