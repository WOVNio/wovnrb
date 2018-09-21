require 'test_helper'
require 'webmock/minitest'

module Wovnrb
  class ReplacerBaseTest < WovnMiniTest
    def test_replace
      store = Store.instance
      replacer = LinkReplacer.new(store, 'query', get_header)
      dom = Wovnrb.get_dom('<a href="/index.html">link text</a>')
      replacer.replace(dom, Lang.new('en'))

      link = dom.xpath('//a')[0].get_attribute('href')
      assert_equal('/index.html?wovn=en', link)
    end

    def test_replace_multiple
      store = Store.instance
      replacer = LinkReplacer.new(store, 'query', get_header)
      dom = Wovnrb.get_dom('<a href="/index.html">link text</a><div>aaa</div><a href="/index2.html">link text</a>')
      replacer.replace(dom, Lang.new('en'))

      link = dom.xpath('//a')[0].get_attribute('href')
      link2 = dom.xpath('//a')[1].get_attribute('href')

      assert_equal('/index.html?wovn=en', link)
      assert_equal('/index2.html?wovn=en', link2)
    end

    def test_replace_ignore
      store = Store.instance
      replacer = LinkReplacer.new(store, 'query', get_header)
      dom = Wovnrb.get_dom('<a wovn-ignore href="/index.html">link text</a>')
      replacer.replace(dom, Lang.new('en'))

      link = dom.xpath('//a')[0].get_attribute('href')
      assert_equal('/index.html', link)
    end

    def test_replace_empty_javascript_link_query
      store = Store.instance
      replacer = LinkReplacer.new(store, 'query', get_header)
      dom = Wovnrb.get_dom('<a href="javascript:void(0);">link text</a>')
      replacer.replace(dom, Lang.new('en'))

      link = dom.xpath('//a')[0].get_attribute('href')
      assert_equal('javascript:void(0);', link)
    end

    def test_replace_javascript_code_link_query
      store = Store.instance
      replacer = LinkReplacer.new(store, 'query', get_header)
      dom = Wovnrb.get_dom('<a href="javascript:onclick($(\'.any\').slideToggle());">link text</a>')
      replacer.replace(dom, Lang.new('en'))

      link = dom.xpath('//a')[0].get_attribute('href')
      assert_equal('javascript:onclick($(\'.any\').slideToggle());', link)
    end

    def test_replace_uppercased_javascript_code_link_query
      store = Store.instance
      replacer = LinkReplacer.new(store, 'query', get_header)
      dom = Wovnrb.get_dom('<a href="JAVASCRIPT:onclick($(\'.any\').slideToggle());">link text</a>')
      replacer.replace(dom, Lang.new('en'))

      link = dom.xpath('//a')[0].get_attribute('href')
      assert_equal('JAVASCRIPT:onclick($(\'.any\').slideToggle());', link)
    end

    def test_replace_empty_javascript_link_path
      store = Store.instance
      replacer = LinkReplacer.new(store, 'path', get_header)
      dom = Wovnrb.get_dom('<a href="javascript:void(0);">link text</a>')
      replacer.replace(dom, Lang.new('en'))

      link = dom.xpath('//a')[0].get_attribute('href')
      assert_equal('javascript:void(0);', link)
    end

    def test_replace_javascript_code_link_path
      store = Store.instance
      replacer = LinkReplacer.new(store, 'path', get_header)
      dom = Wovnrb.get_dom('<a href="javascript:onclick($(\'.any\').slideToggle());">link text</a>')
      replacer.replace(dom, Lang.new('en'))

      link = dom.xpath('//a')[0].get_attribute('href')
      assert_equal('javascript:onclick($(\'.any\').slideToggle());', link)
    end

    def test_replace_uppercased_javascript_code_link_path
      store = Store.instance
      replacer = LinkReplacer.new(store, 'path', get_header)
      dom = Wovnrb.get_dom('<a href="JAVASCRIPT:onclick($(\'.any\').slideToggle());">link text</a>')
      replacer.replace(dom, Lang.new('en'))

      link = dom.xpath('//a')[0].get_attribute('href')
      assert_equal('JAVASCRIPT:onclick($(\'.any\').slideToggle());', link)
    end

    def test_replace_link_path
      store = Store.instance
      replacer = LinkReplacer.new(store, 'path', get_header)
      dom = Wovnrb.get_dom('<a href="/index.html">link text</a>')
      replacer.replace(dom, Lang.new('en'))

      link = dom.xpath('//a')[0].get_attribute('href')
      assert_equal('/en/index.html', link)
    end

    def test_replace_link_path_with_canonical
      store = Store.instance
      replacer = LinkReplacer.new(store, 'path', get_header)
      dom = Wovnrb.get_dom('<html><head><link rel="canonical" href="http://favy.tips/hello/index.html"></head><body>hello</body></html>')
      replacer.replace(dom, Lang.new('en'))
      canonical_href = dom.xpath('//link').find { |d| d.attributes['rel'].value == 'canonical' }.attributes['href'].value
      assert_equal('http://favy.tips/en/hello/index.html', canonical_href)
    end

    def test_replace_link_with_style
      store = Store.instance
      replacer = LinkReplacer.new(store, 'path', get_header)
      dom = Wovnrb.get_dom('<html><head><link rel="stylesheet" type="text/css" href="http://favy.tips/hello/index.css"></head><body>hello</body></html>')
      replacer.replace(dom, Lang.new('en'))
      href = dom.xpath('//link').find { |d| d.attributes['rel'].value == 'stylesheet' }.attributes['href'].value
      assert_equal('http://favy.tips/hello/index.css', href, 'Should not change the href')
    end

    def test_replace_img_link_path
      store = Store.instance
      replacer = LinkReplacer.new(store, 'path', get_header)
      dom = Wovnrb.get_dom('<a href="http://favy.tips/index.jpg">link text</a>')
      replacer.replace(dom, Lang.new('ja'))

      link = dom.xpath('//a')[0].get_attribute('href')
      assert_equal('http://favy.tips/index.jpg', link)
    end

    def test_replace_img_link_path_with_query_or_hash
      store = Store.instance
      replacer = LinkReplacer.new(store, 'path', get_header)
      dom = Wovnrb.get_dom('<a href="http://favy.tips/index.jpg?test=1">link text</a>')
      replacer.replace(dom, Lang.new('ja'))

      link = dom.xpath('//a')[0].get_attribute('href')
      assert_equal('http://favy.tips/index.jpg?test=1', link)

      dom = Wovnrb.get_dom('<a href="http://favy.tips/index.jpg#test=1">link text</a>')
      replacer.replace(dom, Lang.new('ja'))

      link = dom.xpath('//a')[0].get_attribute('href')
      assert_equal('http://favy.tips/index.jpg#test=1', link)
    end

    def test_replace_audio_link_path
      store = Store.instance
      replacer = LinkReplacer.new(store, 'path', get_header)
      dom = Wovnrb.get_dom('<a href="/index.mp3">link text</a>')
      replacer.replace(dom, Lang.new('ja'))

      link = dom.xpath('//a')[0].get_attribute('href')
      assert_equal('/index.mp3', link)
    end

    def test_replace_audio_link_path_with_query_or_hash
      store = Store.instance
      replacer = LinkReplacer.new(store, 'path', get_header)
      dom = Wovnrb.get_dom('<a href="/index.mp3?test=1">link text</a>')
      replacer.replace(dom, Lang.new('ja'))

      link = dom.xpath('//a')[0].get_attribute('href')
      assert_equal('/index.mp3?test=1', link)

      dom = Wovnrb.get_dom('<a href="/index.mp3#test=1">link text</a>')
      replacer.replace(dom, Lang.new('ja'))

      link = dom.xpath('//a')[0].get_attribute('href')
      assert_equal('/index.mp3#test=1', link)
    end

    def test_replace_video_link_path
      store = Store.instance
      replacer = LinkReplacer.new(store, 'path', get_header)
      dom = Wovnrb.get_dom('<a href="/index.mpeg">link text</a>')
      replacer.replace(dom, Lang.new('ja'))

      link = dom.xpath('//a')[0].get_attribute('href')
      assert_equal('/index.mpeg', link)
    end

    def test_replace_video_link_path_with_query_or_hash
      store = Store.instance
      replacer = LinkReplacer.new(store, 'path', get_header)
      dom = Wovnrb.get_dom('<a href="/index.mp4?test=1">link text</a>')
      replacer.replace(dom, Lang.new('ja'))

      link = dom.xpath('//a')[0].get_attribute('href')
      assert_equal('/index.mp4?test=1', link)

      dom = Wovnrb.get_dom('<a href="/index.mp4#test=1">link text</a>')
      replacer.replace(dom, Lang.new('ja'))

      link = dom.xpath('//a')[0].get_attribute('href')
      assert_equal('/index.mp4#test=1', link)
    end

    def test_replace_doc_link_path
      store = Store.instance
      replacer = LinkReplacer.new(store, 'path', get_header)
      dom = Wovnrb.get_dom('<a href="/index.pptx">link text</a>')
      replacer.replace(dom, Lang.new('ja'))

      link = dom.xpath('//a')[0].get_attribute('href')
      assert_equal('/index.pptx', link)
    end

    def test_replace_doc_link_path_with_query_or_hash
      store = Store.instance
      replacer = LinkReplacer.new(store, 'path', get_header)
      dom = Wovnrb.get_dom('<a href="/index.pptx?test=1">link text</a>')
      replacer.replace(dom, Lang.new('ja'))

      link = dom.xpath('//a')[0].get_attribute('href')
      assert_equal('/index.pptx?test=1', link)

      dom = Wovnrb.get_dom('<a href="/index.pptx#test=1">link text</a>')
      replacer.replace(dom, Lang.new('ja'))

      link = dom.xpath('//a')[0].get_attribute('href')
      assert_equal('/index.pptx#test=1', link)
    end

    def test_replace_javascript_link_subdomain
      store = Store.instance
      replacer = LinkReplacer.new(store, 'subdomain', get_header)
      dom = Wovnrb.get_dom('<a href="javascript:void(0);">link text</a>')
      replacer.replace(dom, Lang.new('en'))

      link = dom.xpath('//a')[0].get_attribute('href')
      assert_equal('javascript:void(0);', link)
    end

    def test_replace_mustache
      store = Store.instance
      replacer = LinkReplacer.new(store, 'query', get_header)
      dom = Wovnrb.get_dom('<a href="{{hello}}">link text</a>')
      replacer.replace(dom, Lang.new('en'))

      link = dom.xpath('//a')[0].get_attribute('href')
      assert_equal('{{hello}}', link)

      dom = Wovnrb.get_dom('<a href=" {{hello}} ">link text</a>')
      replacer.replace(dom, Lang.new('en'))

      link = dom.xpath('//a')[0].get_attribute('href')
      assert_equal(' {{hello}} ', link)
    end

    def test_with_base_as_previous_directory
      dom, replacer = create_dom_by_base(base: '../', href: 'm/css/iphone.css')
      replacer.replace(dom, Lang.new('en'))
      assert_link(dom, '/en/sp/entry2017/m/css/iphone.css')
    end

    def test_with_base_as_different_host
      dom, replacer = create_dom_by_base(base: 'http://test.com', href: 'm/css/iphone.css')
      replacer.replace(dom, Lang.new('en'))
      assert_link(dom, 'http://test.com/m/css/iphone.css')
    end

    def test_with_base_as_different_host_without_protocol
      dom, replacer = create_dom_by_base(base: '//test.com', href: 'm/css/iphone.css')
      replacer.replace(dom, Lang.new('en'))
      assert_link(dom, '//test.com/m/css/iphone.css')
    end

    def test_with_base_as_relative_path
      dom, replacer = create_dom_by_base(base: '/test', href: 'm/css/iphone.css')
      replacer.replace(dom, Lang.new('en'))
      assert_link(dom, '/en/test/m/css/iphone.css')
    end

    def test_with_base_as_relative_path_without_starting_slash
      dom, replacer = create_dom_by_base(base: 'test/', href: 'm/css/iphone.css')
      replacer.replace(dom, Lang.new('en'))
      assert_link(dom, '/en/sp/entry2017/m/test/m/css/iphone.css')
    end

    def get_header(url_pattern: 'query', pathname: nil)
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => "http://favy.tips#{pathname}"), Wovnrb.get_settings('url_pattern' => url_pattern, 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    end

    def create_dom_by_base(base:, href:)
      store = Store.instance
      replacer = LinkReplacer.new(store, 'path', get_header(url_pattern: 'path', pathname: '/sp/entry2017/m/index.php'))
      dom = Wovnrb.get_dom("<base target=\"_blank\" href=\"#{base}\"><a href=\"#{href}\">link text</a>")

      [dom, replacer]
    end

    def assert_link(dom, expected)
      link = dom.xpath('//a')[0].get_attribute('href')
      assert_equal(expected, link)
    end
  end
end
