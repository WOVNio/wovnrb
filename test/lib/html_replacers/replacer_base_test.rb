# -*- encoding: UTF-8 -*-
require 'test_helper'
require 'webmock/minitest'

module Wovnrb
  class ReplacerBaseTest < WovnMiniTest
    def test_wovn_ignore
      replacer = ReplacerBase.new
      dom = Wovnrb.to_dom('<html><body><div wovn-ignore></div></body></html>')
      actual = replacer.send(:wovn_ignore?, dom.xpath('//div')[0])

      assert(actual)
    end

    def test_wovn_ignore_parent
      replacer = ReplacerBase.new
      dom = Wovnrb.to_dom('<html wovn-ignore><body><div wovn-ignore></div></body></html>')
      actual = replacer.send(:wovn_ignore?, dom.xpath('//div')[0])

      assert(actual)
    end

    def test_wovn_ignore_without_attribute
      replacer = ReplacerBase.new
      dom = Wovnrb.to_dom('<html><body><div></div></body></html>')
      actual = replacer.send(:wovn_ignore?, dom.xpath('//div')[0])

      assert_equal(false, actual)
    end

    def test_replace_text
      replacer = ReplacerBase.new
      actual = replacer.send(:replace_text, 'Hello', 'こんにちは')
      assert_equal('こんにちは', actual)
    end

    def test_replace_text_with_space
      replacer = ReplacerBase.new
      actual = replacer.send(:replace_text, '    Hello    ', 'こんにちは')
      assert_equal('    こんにちは    ', actual)
    end

    def test_replace_text_with_line_break
      replacer = ReplacerBase.new
      actual = replacer.send(:replace_text, "    Hello  \n   Hello    ", 'こんにちは')
      assert_equal('    こんにちは    ', actual)
    end

    def test_add_comment_node
      replacer = ReplacerBase.new
      html = Nokogiri::HTML("<html><body><h1 id=\"test-node\">Test Content</h1></body></html>")
      h1 = html.xpath("//h1[@id='test-node']")[0]
      text_node = h1.children[0]

      assert_equal("Test Content", h1.inner_html)
      replacer.send(:add_comment_node, text_node, 'test content')
      assert_equal("<!--wovn-src:test content-->Test Content", h1.inner_html)
    end
  end
end

