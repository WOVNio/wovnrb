# -*- encoding: UTF-8 -*-
require 'test_helper'
require 'webmock/minitest'

module Wovnrb
  class TextReplacerTest < WovnMiniTest
    def test_replace
      store = Store.instance
      replacer = TextReplacer.new(store,{
        'Hello' => {'ja' => [{'data' => 'こんにちは'}]}
      })

      dom = Wovnrb.get_dom('Hello')
      replacer.replace(dom, Lang.new('ja'))

      node = dom.xpath('//text()')[0]
      assert_equal('こんにちは', node.content)
      assert_equal('wovn-src:Hello', node.previous.content)
    end

    def test_replace_in_fragment
      store = Store.instance
      replacer = TextReplacer.new(store,{
        'Hello' => {'ja' => [{'data' => 'こんにちは'}]}
      })

      dom = Helpers::NokogumboHelper::parse_html('<span>Hello</span>')
      replacer.replace(dom, Lang.new('ja'))

      node = dom.xpath('.//text()')[0]
      assert_equal('こんにちは', node.content)
      assert_equal('wovn-src:Hello', node.previous.content)
    end

    def test_replace_multiple
      store = Store.instance
      replacer = TextReplacer.new(store, {
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

    def test_replace_multiple_in_fragment
      store = Store.instance
      replacer = TextReplacer.new(store, {
        'Hello' => {'ja' => [{'data' => 'こんにちは'}]},
        'Bye' => {'ja' => [{'data' => 'さようなら'}]}
      })

      dom = Helpers::NokogumboHelper::parse_html('<span>Hello</span><span>Bye</span>')
      replacer.replace(dom, Lang.new('ja'))

      node = dom.xpath('.//text()')[0]
      node2 = dom.xpath('.//text()')[1]
      assert_equal('こんにちは', node.content)
      assert_equal('wovn-src:Hello', node.previous.content)
      assert_equal('さようなら', node2.content)
      assert_equal('wovn-src:Bye', node2.previous.content)
    end

    def test_replace_wovn_ignore
      store = Store.instance
      replacer = TextReplacer.new(store, {
        'Hello' => {'ja' => [{'data' => 'こんにちは'}]}
      })

      dom = Wovnrb.get_dom('<div wovn-ignore>Hello</div>')
      replacer.replace(dom, Lang.new('ja'))

      node = dom.xpath('//text()')[0]
      assert_equal('Hello', node.content)
      assert_nil(node.previous)
    end

    def test_replace_wovn_ignore_on_fragment
      store = Store.instance
      replacer = TextReplacer.new(store, {
        'Hello' => {'ja' => [{'data' => 'こんにちは'}]}
      })

      dom = Helpers::NokogumboHelper::parse_html('<div wovn-ignore>Hello</div>')
      replacer.replace(dom, Lang.new('ja'))

      node = dom.xpath('.//text()')[0]
      assert_equal('Hello', node.content)
      assert_nil(node.previous)
    end
  end
end
