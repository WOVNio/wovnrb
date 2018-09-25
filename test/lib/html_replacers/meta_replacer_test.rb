# -*- encoding: UTF-8 -*-
require 'test_helper'
require 'webmock/minitest'

module Wovnrb
  class MetaReplacerTest < WovnMiniTest
    def test_replace_description
      store = Store.instance
      replacer = MetaReplacer.new(store, {
        'Hello' => {'ja' => [{'data' => 'こんにちは'}]}
      })

      dom = Wovnrb.get_dom('<meta name="description" content="Hello">')
      replacer.replace(dom, Lang.new('ja'))

      content = dom.xpath('//meta')[0].get_attribute('content')
      assert_equal('こんにちは', content)
    end

    def test_replace_description_in_fragment
      store = Store.instance
      replacer = MetaReplacer.new(store, {
        'Hello' => {'ja' => [{'data' => 'こんにちは'}]}
      })

      dom = Helpers::NokogumboHelper::parse_fragment('<meta name="description" content="Hello">')
      replacer.replace(dom, Lang.new('ja'))

      content = dom.xpath('.//meta')[0].get_attribute('content')
      assert_equal('こんにちは', content)
    end

    def test_replace_og_description
      store = Store.instance
      replacer = MetaReplacer.new(store, {
        'Hello' => {'ja' => [{'data' => 'こんにちは'}]}
      })

      dom = Wovnrb.get_dom('<meta property="og:description" content="Hello">')
      replacer.replace(dom, Lang.new('ja'))

      content = dom.xpath('//meta')[0].get_attribute('content')
      assert_equal('こんにちは', content)
    end

    def test_replace_og_title
      store = Store.instance
      replacer = MetaReplacer.new(store, {
        'Hello' => {'ja' => [{'data' => 'こんにちは'}]}
      })

      dom = Wovnrb.get_dom('<meta property="og:title" content="Hello">')
      replacer.replace(dom, Lang.new('ja'))

      content = dom.xpath('//meta')[0].get_attribute('content')
      assert_equal('こんにちは', content)
    end

    def test_replace_twitter_title
      store = Store.instance
      replacer = MetaReplacer.new(store, {
        'Hello' => {'ja' => [{'data' => 'こんにちは'}]}
      })

      dom = Wovnrb.get_dom('<meta property="twitter:title" content="Hello">')
      replacer.replace(dom, Lang.new('ja'))

      content = dom.xpath('//meta')[0].get_attribute('content')
      assert_equal('こんにちは', content)
    end

    def test_replace_twitter_description
      store = Store.instance
      replacer = MetaReplacer.new(store, {
        'Hello' => {'ja' => [{'data' => 'こんにちは'}]}
      })

      dom = Wovnrb.get_dom('<meta property="twitter:description" content="Hello">')
      replacer.replace(dom, Lang.new('ja'))

      content = dom.xpath('//meta')[0].get_attribute('content')
      assert_equal('こんにちは', content)
    end

    def test_replace_multi
      store = Store.instance
      replacer = MetaReplacer.new(store, {
        'Hello' => {'ja' => [{'data' => 'こんにちは'}]},
        'Bye' => {'ja' => [{'data' => 'さようなら'}]}
      })

      dom = Wovnrb.get_dom('<meta property="title" content="Hello"><meta property="title" content="Bye">')
      replacer.replace(dom, Lang.new('ja'))

      content = dom.xpath('//meta')[0].get_attribute('content')
      content2 = dom.xpath('//meta')[1].get_attribute('content')
      assert_equal('こんにちは', content)
      assert_equal('さようなら', content2)
    end

    def test_replace_multi_in_fragment
      store = Store.instance
      replacer = MetaReplacer.new(store, {
        'Hello' => {'ja' => [{'data' => 'こんにちは'}]},
        'Bye' => {'ja' => [{'data' => 'さようなら'}]}
      })

      dom = Helpers::NokogumboHelper::parse_fragment('<meta property="title" content="Hello"><meta property="title" content="Bye">')
      replacer.replace(dom, Lang.new('ja'))

      content = dom.xpath('.//meta')[0].get_attribute('content')
      content2 = dom.xpath('.//meta')[1].get_attribute('content')
      assert_equal('こんにちは', content)
      assert_equal('さようなら', content2)
    end

    def test_replace_wovn_ignore
      store = Store.instance
      replacer = MetaReplacer.new(store, {
        'Hello' => {'ja' => [{'data' => 'こんにちは'}]},
      })

      dom = Wovnrb.get_dom('<meta wovn-ignore property="title" content="Hello">')
      replacer.replace(dom, Lang.new('ja'))

      content = dom.xpath('//meta')[0].get_attribute('content')
      assert_equal('Hello', content)
    end

    def test_replace_wovn_ignore_on_fragment
      store = Store.instance
      replacer = MetaReplacer.new(store, {
        'Hello' => {'ja' => [{'data' => 'こんにちは'}]},
      })

      dom = Helpers::NokogumboHelper::parse_fragment('<meta wovn-ignore property="title" content="Hello">')
      replacer.replace(dom, Lang.new('ja'))

      content = dom.xpath('.//meta')[0].get_attribute('content')
      assert_equal('Hello', content)
    end

    def test_replace_wovn_ignore_og
      store = Store.instance
      headers = Wovnrb::Headers.new(Wovnrb.get_env('url' => 'https://test.com'), Wovnrb.get_settings)
      replacer = MetaReplacer.new(store, {
        'Hello' => {'ja' => [{'data' => 'こんにちは'}]},
      }, 'path', headers)

      dom = Wovnrb.get_dom('<meta property="og:url" content="https://test.com">')
      replacer.replace(dom, Lang.new('ja'))

      content = dom.xpath('//meta')[0].get_attribute('content')
      assert_equal('https://test.com/ja/', content)
    end
  end
end
