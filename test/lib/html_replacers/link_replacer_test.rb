require 'test_helper'
require 'webmock/minitest'

module Wovnrb
  class ReplacerBaseTest < WovnMiniTest
    def before_setup
      super

      @store = Store.instance
    end

    def test_replace
      replacer = LinkReplacer.new(@store, 'query', get_header)
      dom = Wovnrb.get_dom('<a href="/index.html">link text</a>')
      replacer.replace(dom, Lang.new('en'))

      link = dom.xpath('//a')[0].get_attribute('href')
      assert_equal('/index.html?wovn=en', link)
    end

    def test_replace_multiple
      replacer = LinkReplacer.new(@store, 'query', get_header)
      dom = Wovnrb.get_dom('<a href="/index.html">link text</a><div>aaa</div><a href="/index2.html">link text</a>')
      replacer.replace(dom, Lang.new('en'))

      link = dom.xpath('//a')[0].get_attribute('href')
      link2 = dom.xpath('//a')[1].get_attribute('href')

      assert_equal('/index.html?wovn=en', link)
      assert_equal('/index2.html?wovn=en', link2)
    end

    def test_replace_ignore
      replacer = LinkReplacer.new(@store, 'query', get_header)
      dom = Wovnrb.get_dom('<a wovn-ignore href="/index.html">link text</a>')
      replacer.replace(dom, Lang.new('en'))

      link = dom.xpath('//a')[0].get_attribute('href')
      assert_equal('/index.html', link)
    end

    def test_replace_ignored_class_is_not_replaced
      @store.update_settings('ignore_class' => ['ignored-class'])
      replacer = LinkReplacer.new(@store, 'query', get_header)
      dom = Wovnrb.get_dom('<a class="ignored-class" href="/index.html">link text</a>')
      replacer.replace(dom, Lang.new('en'))

      link = dom.xpath('//a')[0].get_attribute('href')
      assert_equal('/index.html', link)
    end

    def test_href_to_ignored_path_is_not_replaced
      @store.update_settings('ignore_paths' => ['/ignored_path/'])
      replacer = LinkReplacer.new(@store, 'query', get_header)
      dom = Wovnrb.get_dom('<a href="/dir/ignored_path/index.html">link text</a>')
      replacer.replace(dom, Lang.new('en'))

      link = dom.xpath('//a')[0].get_attribute('href')
      assert_equal('/dir/ignored_path/index.html', link)
    end

    def test_replace_empty_javascript_link_query
      replacer = LinkReplacer.new(@store, 'query', get_header)
      dom = Wovnrb.get_dom('<a href="javascript:void(0);">link text</a>')
      replacer.replace(dom, Lang.new('en'))

      link = dom.xpath('//a')[0].get_attribute('href')
      assert_equal('javascript:void(0);', link)
    end

    def test_replace_javascript_code_link_query
      replacer = LinkReplacer.new(@store, 'query', get_header)
      dom = Wovnrb.get_dom('<a href="javascript:onclick($(\'.any\').slideToggle());">link text</a>')
      replacer.replace(dom, Lang.new('en'))

      link = dom.xpath('//a')[0].get_attribute('href')
      assert_equal('javascript:onclick($(\'.any\').slideToggle());', link)
    end

    def test_replace_uppercased_javascript_code_link_query
      replacer = LinkReplacer.new(@store, 'query', get_header)
      dom = Wovnrb.get_dom('<a href="JAVASCRIPT:onclick($(\'.any\').slideToggle());">link text</a>')
      replacer.replace(dom, Lang.new('en'))

      link = dom.xpath('//a')[0].get_attribute('href')
      assert_equal('JAVASCRIPT:onclick($(\'.any\').slideToggle());', link)
    end

    def test_replace_empty_javascript_link_path
      replacer = LinkReplacer.new(@store, 'path', get_header)
      dom = Wovnrb.get_dom('<a href="javascript:void(0);">link text</a>')
      replacer.replace(dom, Lang.new('en'))

      link = dom.xpath('//a')[0].get_attribute('href')
      assert_equal('javascript:void(0);', link)
    end

    def test_replace_javascript_code_link_path
      replacer = LinkReplacer.new(@store, 'path', get_header)
      dom = Wovnrb.get_dom('<a href="javascript:onclick($(\'.any\').slideToggle());">link text</a>')
      replacer.replace(dom, Lang.new('en'))

      link = dom.xpath('//a')[0].get_attribute('href')
      assert_equal('javascript:onclick($(\'.any\').slideToggle());', link)
    end

    def test_replace_uppercased_javascript_code_link_path
      replacer = LinkReplacer.new(@store, 'path', get_header)
      dom = Wovnrb.get_dom('<a href="JAVASCRIPT:onclick($(\'.any\').slideToggle());">link text</a>')
      replacer.replace(dom, Lang.new('en'))

      link = dom.xpath('//a')[0].get_attribute('href')
      assert_equal('JAVASCRIPT:onclick($(\'.any\').slideToggle());', link)
    end

    def test_replace_link_path
      replacer = LinkReplacer.new(@store, 'path', get_header)
      dom = Wovnrb.get_dom('<a href="/index.html">link text</a>')
      replacer.replace(dom, Lang.new('en'))

      link = dom.xpath('//a')[0].get_attribute('href')
      assert_equal('/en/index.html', link)
    end

    def test_replace_link_path_with_canonical
      replacer = LinkReplacer.new(@store, 'path', get_header)
      dom = Wovnrb.get_dom('<html><head><link rel="canonical" href="http://wovn.io/hello/index.html"></head><body>hello</body></html>')
      replacer.replace(dom, Lang.new('en'))
      canonical_href = dom.xpath('//link').find { |d| d.attributes['rel'].value == 'canonical' }.attributes['href'].value
      assert_equal('http://wovn.io/en/hello/index.html', canonical_href)
    end

    def test_replace_link_with_style
      replacer = LinkReplacer.new(@store, 'path', get_header)
      dom = Wovnrb.get_dom('<html><head><link rel="stylesheet" type="text/css" href="http://wovn.io/hello/index.css"></head><body>hello</body></html>')
      replacer.replace(dom, Lang.new('en'))
      href = dom.xpath('//link').find { |d| d.attributes['rel'].value == 'stylesheet' }.attributes['href'].value
      assert_equal('http://wovn.io/hello/index.css', href, 'Should not change the href')
    end

    def test_replace_img_link_path
      replacer = LinkReplacer.new(@store, 'path', get_header)
      dom = Wovnrb.get_dom('<a href="http://wovn.io/index.jpg">link text</a>')
      replacer.replace(dom, Lang.new('ja'))

      link = dom.xpath('//a')[0].get_attribute('href')
      assert_equal('http://wovn.io/index.jpg', link)
    end

    def test_replace_img_link_path_with_query_or_hash
      replacer = LinkReplacer.new(@store, 'path', get_header)
      dom = Wovnrb.get_dom('<a href="http://wovn.io/index.jpg?test=1">link text</a>')
      replacer.replace(dom, Lang.new('ja'))

      link = dom.xpath('//a')[0].get_attribute('href')
      assert_equal('http://wovn.io/index.jpg?test=1', link)

      dom = Wovnrb.get_dom('<a href="http://wovn.io/index.jpg#test=1">link text</a>')
      replacer.replace(dom, Lang.new('ja'))

      link = dom.xpath('//a')[0].get_attribute('href')
      assert_equal('http://wovn.io/index.jpg#test=1', link)
    end

    def test_replace_audio_link_path
      replacer = LinkReplacer.new(@store, 'path', get_header)
      dom = Wovnrb.get_dom('<a href="/index.mp3">link text</a>')
      replacer.replace(dom, Lang.new('ja'))

      link = dom.xpath('//a')[0].get_attribute('href')
      assert_equal('/index.mp3', link)
    end

    def test_replace_audio_link_path_with_query_or_hash
      replacer = LinkReplacer.new(@store, 'path', get_header)
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
      replacer = LinkReplacer.new(@store, 'path', get_header)
      dom = Wovnrb.get_dom('<a href="/index.mpeg">link text</a>')
      replacer.replace(dom, Lang.new('ja'))

      link = dom.xpath('//a')[0].get_attribute('href')
      assert_equal('/index.mpeg', link)
    end

    def test_replace_video_link_path_with_query_or_hash
      replacer = LinkReplacer.new(@store, 'path', get_header)
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
      replacer = LinkReplacer.new(@store, 'path', get_header)
      dom = Wovnrb.get_dom('<a href="/index.pptx">link text</a>')
      replacer.replace(dom, Lang.new('ja'))

      link = dom.xpath('//a')[0].get_attribute('href')
      assert_equal('/index.pptx', link)
    end

    def test_replace_doc_link_path_with_query_or_hash
      replacer = LinkReplacer.new(@store, 'path', get_header)
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
      replacer = LinkReplacer.new(@store, 'subdomain', get_header)
      dom = Wovnrb.get_dom('<a href="javascript:void(0);">link text</a>')
      replacer.replace(dom, Lang.new('en'))

      link = dom.xpath('//a')[0].get_attribute('href')
      assert_equal('javascript:void(0);', link)
    end

    def test_replace_mustache
      replacer = LinkReplacer.new(@store, 'query', get_header)
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

    def test_base_href
      tests = [
        { pathname: '/dirname/index.php', base: '/absolute/path', expected_href: '/absolute/path' },
        { pathname: '/dirname/index.php', base: 'relative/path', expected_href: '/dirname/relative/path' },
        { pathname: '/dirname/index.php', base: './dot/path', expected_href: '/dirname/dot/path' },
        { pathname: '/dirname/index.php', base: '../doubledot/path', expected_href: '/doubledot/path' },
        { pathname: '/', base: '../errordots/path', expected_href: '/errordots/path' },
        { pathname: '/dirname/deep/index.php', base: './../.././../../../many/dots', expected_href: '/many/dots' },
        { pathname: 'index.php', base: 'no/dir/path', expected_href: '/no/dir/path' },
        { pathname: 'index.php', base: '/trailing/slash/', expected_href: '/trailing/slash/' },
        { pathname: 'index.php', base: '', expected_href: '/' }
      ]

      tests.each do |test|
        replacer = LinkReplacer.new(@store, 'path', get_header(url_pattern: 'path', pathname: test[:pathname]))
        dom = Wovnrb.get_dom("<base target=\"_blank\" href=\"#{test[:base]}\"><a href=\"/not_matter\">link text</a>")
        assert_equal(test[:expected_href], replacer.send(:base_href, dom))
      end
    end

    def get_header(url_pattern: 'query', pathname: nil)
      Wovnrb::Headers.new(
        Wovnrb.get_env('url' => "http://wovn.io#{pathname}"),
        Wovnrb.get_settings('url_pattern' => url_pattern, 'url_pattern_reg' => '^(?<lang>[^.]+).')
      )
    end

    def create_dom_by_base(base:, href:)
      replacer = LinkReplacer.new(@store, 'path', get_header(url_pattern: 'path', pathname: '/sp/entry2017/m/index.php'))
      dom = Wovnrb.get_dom("<base target=\"_blank\" href=\"#{base}\"><a href=\"#{href}\">link text</a>")

      [dom, replacer]
    end

    def assert_link(dom, expected)
      link = dom.xpath('//a')[0].get_attribute('href')
      assert_equal(expected, link)
    end
  end
end
