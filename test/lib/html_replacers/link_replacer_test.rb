require 'test_helper'
require 'webmock/minitest'

module Wovnrb
  class ReplacerBaseTest < WovnMiniTest
    def test_replace
      replacer = LinkReplacer.new('query', get_header)
      dom = Wovnrb.get_dom('<a href="/index.html">link text</a>')
      replacer.replace(dom, Lang.new('en'))

      link = dom.xpath('//a')[0].get_attribute('href')
      assert_equal('/index.html?wovn=en', link)
    end

    def test_replace_multiple
      replacer = LinkReplacer.new('query', get_header)
      dom = Wovnrb.get_dom('<a href="/index.html">link text</a><div>aaa</div><a href="/index2.html">link text</a>')
      replacer.replace(dom, Lang.new('en'))

      link = dom.xpath('//a')[0].get_attribute('href')
      link2 = dom.xpath('//a')[1].get_attribute('href')

      assert_equal('/index.html?wovn=en', link)
      assert_equal('/index2.html?wovn=en', link2)
    end

    def test_replace_ignore
      replacer = LinkReplacer.new('query', get_header)
      dom = Wovnrb.get_dom('<a wovn-ignore href="/index.html">link text</a>')
      replacer.replace(dom, Lang.new('en'))

      link = dom.xpath('//a')[0].get_attribute('href')
      assert_equal('/index.html', link)
    end



    def get_header
      h = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'http://favy.tips'), Wovnrb.get_settings('url_pattern' => 'query', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    end
  end
end

