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
  end
end

