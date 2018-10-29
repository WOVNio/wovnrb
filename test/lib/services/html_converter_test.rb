require 'test_helper'

module Wovnrb
  class HtmlConverterTest < WovnMiniTest
    # TODO: Add more tests
    def test_transform_html
      html = '<html><body><a>hello</a></body></html>'
      store, headers = store_headers_factory(supported_langs: %w(en vi))
      converter = HtmlConverter.new(html, store, headers)
      translated_html, _ = converter.build

      expected_html = "<html><body><link rel=\"alternate\" hreflang=\"en\" href=\"http://my-site.com/\"><link rel=\"alternate\" hreflang=\"vi\" href=\"http://my-site.com/?wovn=vi\"><script src=\"//j.wovn.io/1\" data-wovnio=\"key=123456&amp;backend=true&amp;currentLang=en&amp;defaultLang=en&amp;urlPattern=query&amp;langCodeAliases={}&amp;version=WOVN.rb\" async></script><a>hello</a></body></html>"
      assert_equal(expected_html, translated_html)
    end

    def test_insert_snippet
      html = prepare_html.build
      assert(html =~ /j.wovn.io/)
      assert(html =~ /hreflang/)
    end

    def test_replace_dom
      html_converter = prepare_html
      converted_html, marker = html_converter.send(:build_api_compatible_html)
      assert_nil(converted_html =~ /hreflang/)
      assert_nil(converted_html =~ /j.(dev-)?wovn.io/)
    end

    def test_strip_snippet
      html_converter = prepare_html

      dom = Helpers::NokogumboHelper::parse_html(html)
      dom.xpath('//script').each do |node|
        html_converter.send(:strip_snippet_code, node)
      end

      assert_same_elements([], dom.xpath("//script"))
    end

    def test_strip_hreflangs
      html_converter = prepare_html
      dom = Helpers::NokogumboHelper::parse_html(html)
      dom.xpath('//link').each do |node|
        html_converter.send(:strip_hreflang, node)
      end

      assert_same_elements([], dom.xpath("//link"))
    end

    private

    def prepare_html
      store, headers = store_headers_factory
      HtmlConverter.new(html, store, headers)
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

    def store_headers_factory(options = {})
      settings = {
        'project_token' => '123456',
        'custom_lang_aliases' => {},
        'default_lang' => 'en',
        'url_pattern' => 'query',
        'url_pattern_reg' => '^(?<lang>[^.]+).',
        'supported_langs' => ['en', 'fr', 'ja', 'vi']
      }.merge(options)

      store = Wovnrb::Store.instance
      store.update_settings(settings)

      headers = Wovnrb::Headers.new(
        Wovnrb.get_env('url' => "http://my-site.com"),
        Wovnrb.get_settings(settings)
      )

      [store, headers]
    end
  end
end
