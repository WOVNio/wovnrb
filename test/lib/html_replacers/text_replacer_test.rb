# -*- encoding: UTF-8 -*-
require 'test_helper'
require 'webmock/minitest'

module Wovnrb
  class TextReplacerTest < WovnMiniTest
    def test_replace
      replacer = TextReplacer.new({
        'Hello' => {'ja' => [{'data' => 'こんにちは'}]}
      })

      dom = Wovnrb.get_dom('Hello')
      replacer.replace(dom, Lang.new('ja'))

      node = dom.xpath('//text()')[0]
      assert_equal('こんにちは', node.content)
      assert_equal('wovn-src:Hello', node.previous.content)
    end

    def test_replace_multiple
      replacer = TextReplacer.new({
        'Hello' => {'ja' => [{'data' => 'こんにちは'}]},
        'Bye' => {'ja' => [{'data' => 'さようなら'}]}
      })

      dom = Wovnrb.get_dom('<span>Hello</span><span>Bye</span>')
      replacer.replace(dom, Lang.new('ja'))

      node = dom.xpath('//text()')[0]
      node2 = dom.xpath('//text()')[1]
      assert_equal('こんにちは', node.content)
      assert_equal('wovn-src:Hello', node.previous.content)
      assert_equal('さようなら', node2.content)
      assert_equal('wovn-src:Bye', node2.previous.content)
    end

    def test_replace_wovn_ignore
      replacer = TextReplacer.new({
        'Hello' => {'ja' => [{'data' => 'こんにちは'}]}
      })

      dom = Wovnrb.get_dom('<div wovn-ignore>Hello</div>')
      replacer.replace(dom, Lang.new('ja'))

      node = dom.xpath('//text()')[0]
      assert_equal('Hello', node.content)
      assert_equal(nil, node.previous)
    end
  end
end
