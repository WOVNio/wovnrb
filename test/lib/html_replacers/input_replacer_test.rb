# -*- encoding: UTF-8 -*-
require 'test_helper'
require 'webmock/minitest'

module Wovnrb
  class InputReplacerTest < WovnMiniTest
    def test_replace_submit_value
      replacer = InputReplacer.new({
        'Hello' => {'ja' => [{'data' => 'こんにちは'}]}
      })

      dom = Wovnrb.get_dom('<input type="submit" value="Hello">')
      replacer.replace(dom, Lang.new('ja'))

      content = dom.xpath('//input')[0].get_attribute('value')
      assert_equal('こんにちは', content)
    end

    def test_dont_replace_empty_submit_value
      replacer = InputReplacer.new({
        'Hello' => {'ja' => [{'data' => 'こんにちは'}]}
      })

      dom = Wovnrb.get_dom('<input type="submit" value="">')
      replacer.replace(dom, Lang.new('ja'))

      content = dom.xpath('//input')[0].get_attribute('value')
      assert_equal('', content)
    end

    def test_dont_replace_type_text_value
      replacer = InputReplacer.new({
        'Hello' => {'ja' => [{'data' => 'こんにちは'}]}
      })

      dom = Wovnrb.get_dom('<input type="text" value="Hello">')
      replacer.replace(dom, Lang.new('ja'))

      content = dom.xpath('//input')[0].get_attribute('value')
      assert_equal('Hello', content)
    end

    def test_dont_replace_type_search_value
      replacer = InputReplacer.new({
        'Hello' => {'ja' => [{'data' => 'こんにちは'}]}
      })

      dom = Wovnrb.get_dom('<input type="search" value="Hello">')
      replacer.replace(dom, Lang.new('ja'))

      content = dom.xpath('//input')[0].get_attribute('value')
      assert_equal('Hello', content)
    end

    def test_dont_replace_type_hidden_value
      replacer = InputReplacer.new({
        'Hello' => {'ja' => [{'data' => 'こんにちは'}]}
      })

      dom = Wovnrb.get_dom('<input type="hidden" value="Hello">')
      replacer.replace(dom, Lang.new('ja'))

      content = dom.xpath('//input')[0].get_attribute('value')
      assert_equal('Hello', content)
    end

    def test_dont_replace_type_password_value
      replacer = InputReplacer.new({
        'Hello' => {'ja' => [{'data' => 'こんにちは'}]}
      })

      dom = Wovnrb.get_dom('<input type="password" value="Hello">')
      replacer.replace(dom, Lang.new('ja'))

      content = dom.xpath('//input')[0].get_attribute('value')
      assert_equal('Hello', content)
    end

    def test_dont_replace_type_url_value
      replacer = InputReplacer.new({
        'Hello' => {'ja' => [{'data' => 'こんにちは'}]}
      })

      dom = Wovnrb.get_dom('<input type="url" value="Hello">')
      replacer.replace(dom, Lang.new('ja'))

      content = dom.xpath('//input')[0].get_attribute('value')
      assert_equal('Hello', content)
    end

    def test_dont_replace_no_type_value
      replacer = InputReplacer.new({
        'Hello' => {'ja' => [{'data' => 'こんにちは'}]}
      })

      dom = Wovnrb.get_dom('<input value="Hello">')
      replacer.replace(dom, Lang.new('ja'))

      content = dom.xpath('//input')[0].get_attribute('value')
      assert_equal('Hello', content)
    end
  end
end
