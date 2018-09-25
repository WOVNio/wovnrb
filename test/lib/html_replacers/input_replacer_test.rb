# -*- encoding: UTF-8 -*-
require 'test_helper'
require 'webmock/minitest'

module Wovnrb
  class InputReplacerTest < WovnMiniTest
    def test_replace_submit_value
      store = Store.instance
      replacer = InputReplacer.new(store, {
        'Hello' => {'ja' => [{'data' => 'こんにちは'}]}
      })

      dom = Wovnrb.get_dom('<input type="submit" value="Hello">')
      replacer.replace(dom, Lang.new('ja'))

      content = dom.xpath('//input')[0].get_attribute('value')
      assert_equal('こんにちは', content)
    end

    def test_replace_in_fragment
      store = Store.instance
      replacer = InputReplacer.new(store, {
        'Hello' => {'ja' => [{'data' => 'こんにちは'}]}
      })

      dom = Helpers::NokogumboHelper::parse_fragment('<input type="submit" value="Hello">')
      replacer.replace(dom, Lang.new('ja'))

      content = dom.xpath('.//input')[0].get_attribute('value')
      assert_equal('こんにちは', content)
    end

    def test_dont_replace_empty_submit_value
      store = Store.instance
      replacer = InputReplacer.new(store, {
        'Hello' => {'ja' => [{'data' => 'こんにちは'}]}
      })

      dom = Wovnrb.get_dom('<input type="submit" value="">')
      replacer.replace(dom, Lang.new('ja'))

      content = dom.xpath('//input')[0].get_attribute('value')
      assert_equal('', content)
    end

    def test_dont_replace_type_text_value
      store = Store.instance
      replacer = InputReplacer.new(store, {
        'Hello' => {'ja' => [{'data' => 'こんにちは'}]}
      })

      dom = Wovnrb.get_dom('<input type="text" value="Hello">')
      replacer.replace(dom, Lang.new('ja'))

      content = dom.xpath('//input')[0].get_attribute('value')
      assert_equal('Hello', content)
    end

    def test_dont_replace_type_search_value
      store = Store.instance
      replacer = InputReplacer.new(store, {
        'Hello' => {'ja' => [{'data' => 'こんにちは'}]}
      })

      dom = Wovnrb.get_dom('<input type="search" value="Hello">')
      replacer.replace(dom, Lang.new('ja'))

      content = dom.xpath('//input')[0].get_attribute('value')
      assert_equal('Hello', content)
    end

    def test_dont_replace_type_hidden_value
      store = Store.instance
      replacer = InputReplacer.new(store, {
        'Hello' => {'ja' => [{'data' => 'こんにちは'}]}
      })

      dom = Wovnrb.get_dom('<input type="hidden" value="Hello">')
      replacer.replace(dom, Lang.new('ja'))

      content = dom.xpath('//input')[0].get_attribute('value')
      assert_equal('Hello', content)
    end

    def test_dont_replace_type_password_value
      store = Store.instance
      replacer = InputReplacer.new(store, {
        'Hello' => {'ja' => [{'data' => 'こんにちは'}]}
      })

      dom = Wovnrb.get_dom('<input type="password" value="Hello">')
      replacer.replace(dom, Lang.new('ja'))

      content = dom.xpath('//input')[0].get_attribute('value')
      assert_equal('Hello', content)
    end

    def test_replace_type_password_placeholder
      store = Store.instance
      replacer = InputReplacer.new(store, {
        'Hello' => {'ja' => [{'data' => 'こんにちは'}]},
        'Hi' => {'ja' => [{'data' => 'やぁ'}]},
      })

      dom = Wovnrb.get_dom('<input type="password" value="Hello" placeholder="Hi">')
      replacer.replace(dom, Lang.new('ja'))

      value_content = dom.xpath('//input')[0].get_attribute('value')
      placeholder_content = dom.xpath('//input')[0].get_attribute('placeholder')
      assert_equal('Hello', value_content)
      assert_equal('やぁ', placeholder_content)
    end

    def test_dont_replace_type_url_value
      store = Store.instance
      replacer = InputReplacer.new(store, {
        'Hello' => {'ja' => [{'data' => 'こんにちは'}]}
      })

      dom = Wovnrb.get_dom('<input type="url" value="Hello">')
      replacer.replace(dom, Lang.new('ja'))

      content = dom.xpath('//input')[0].get_attribute('value')
      assert_equal('Hello', content)
    end

    def test_dont_replace_no_type_value
      store = Store.instance
      replacer = InputReplacer.new(store, {
        'Hello' => {'ja' => [{'data' => 'こんにちは'}]}
      })

      dom = Wovnrb.get_dom('<input value="Hello">')
      replacer.replace(dom, Lang.new('ja'))

      content = dom.xpath('//input')[0].get_attribute('value')
      assert_equal('Hello', content)
    end
  end
end
