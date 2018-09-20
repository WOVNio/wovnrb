# -*- encoding: UTF-8 -*-
require 'test_helper'
require 'webmock/minitest'

module Wovnrb
  class ReplacerBaseTest < WovnMiniTest
    def test_wovn_ignore
      store = Store.instance
      replacer = ReplacerBase.new(store)
      dom = Wovnrb.to_dom('<html><body><div wovn-ignore></div></body></html>')
      actual = replacer.send(:wovn_ignore?, dom.xpath('//div')[0])

      assert(actual)
    end

    def test_wovn_ignore_parent
      store = Store.instance
      replacer = ReplacerBase.new(store)
      dom = Wovnrb.to_dom('<html wovn-ignore><body><div wovn-ignore></div></body></html>')
      actual = replacer.send(:wovn_ignore?, dom.xpath('//div')[0])

      assert(actual)
    end

    def test_wovn_ignore_without_attribute
      store = Store.instance
      replacer = ReplacerBase.new(store)
      dom = Wovnrb.to_dom('<html><body><div></div></body></html>')
      actual = replacer.send(:wovn_ignore?, dom.xpath('//div')[0])

      assert_equal(false, actual)
    end

    def test_wovn_ignore_class
      store = Store.instance
      store.settings('ignore_class' => ['base_ignore'])
      replacer = ReplacerBase.new(store)
      dom = Wovnrb.to_dom('<html><body><div class="base_ignore"></div></body></html>')
      actual = replacer.send(:wovn_ignore?, dom.xpath('//div')[0])

      assert(actual)
    end

    def test_wovn_ignore_multiple_classes
      store = Store.instance
      store.settings('ignore_class' => ['base_ignore', 'base_ignore2'])
      replacer = ReplacerBase.new(store)
      html = <<HTML
<html>
<body>
<div class="base_ignore"></div>
<span class="base_ignore2"></span>
<p class="base_ignore_liar"></p>
</body>
</html>
HTML
      dom = Wovnrb.to_dom(html)
      assert(replacer.send(:wovn_ignore?, dom.xpath('//div')[0]))
      assert(replacer.send(:wovn_ignore?, dom.xpath('//span')[0]))
      assert_equal(false, replacer.send(:wovn_ignore?, dom.xpath('//p')[0]))

    def test_wovn_ignore_fragment
      store = Store.instance
      replacer = ReplacerBase.new(store)
      dom = Helpers::NokogumboHelper.parse_fragment('<div wovn-ignore></div>')
      actual = replacer.send(:wovn_ignore?, dom.xpath('.//div')[0])

      assert(actual)
    end
    end

    def test_wovn_ignore_fragment_parent
      store = Store.instance
      replacer = ReplacerBase.new(store)
      dom = Helpers::NokogumboHelper.parse_fragment('<div wovn-ignore><span></span></div>')
      actual = replacer.send(:wovn_ignore?, dom.xpath('.//span')[0])

      assert(actual)
    end

    def test_wovn_ignore_fragment_no_wovn_ignore
      store = Store.instance
      replacer = ReplacerBase.new(store)
      dom = Helpers::NokogumboHelper.parse_fragment('<div><span></span></div>')
      actual = replacer.send(:wovn_ignore?, dom.xpath('.//span')[0])

      assert(!actual)
    end

    def test_replace_text
      store = Store.instance
      replacer = ReplacerBase.new(store)
      actual = replacer.send(:replace_text, 'Hello', 'こんにちは')
      assert_equal('こんにちは', actual)
    end

    def test_replace_text_with_space
      store = Store.instance
      replacer = ReplacerBase.new(store)
      actual = replacer.send(:replace_text, '    Hello    ', 'こんにちは')
      assert_equal('    こんにちは    ', actual)
    end

    def test_replace_text_with_line_break
      store = Store.instance
      replacer = ReplacerBase.new(store)
      actual = replacer.send(:replace_text, "    Hello  \n   Hello    ", 'こんにちは')
      assert_equal('    こんにちは    ', actual)
    end

    def test_add_comment_node
      store = Store.instance
      replacer = ReplacerBase.new(store)
      html = Nokogiri::HTML5('<html><body><h1 id="test-node">Test Content</h1></body></html>')
      h1 = html.xpath("//h1[@id='test-node']")[0]

      assert_equal('Test Content', h1.inner_html)
      h1.xpath('//text()').each do |node|
        text_content = node.content
        if text_content == 'Test Content'
          replacer.send(:add_comment_node, node, 'test content')
        end
      end
      assert_equal("<!--wovn-src:test content-->Test Content", h1.inner_html)
    end
  end
end

