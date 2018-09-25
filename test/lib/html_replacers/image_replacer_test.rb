# -*- encoding: UTF-8 -*-
require 'test_helper'
require 'webmock/minitest'

module Wovnrb
  class ImageReplacerTest < WovnMiniTest
    def test_replace
      store = Store.instance
      url = {
        :protocol => 'http',
        :host => 'www.example.com',
        :pathname => 'hello/index.html'
      }
      text_index = {
        'Hello' => {'ja' => [{'data' => 'こんにちは'}]}
      }
      src_index = {
        'http://www.example.com/test.img' => {'ja' => [{'data' => 'http://test.com/ttt.img'}]}
      }
      img_src_prefix = 'prefix::'
      replacer = ImageReplacer.new(store, url, text_index, src_index, img_src_prefix, [])

      dom = Wovnrb.get_dom('<img src="http://www.example.com/test.img" alt="Hello"')
      replacer.replace(dom, Lang.new('ja'))

      img = dom.xpath('//img')[0]
      assert_equal('prefix::http://test.com/ttt.img', img.get_attribute('src'))
      assert_equal('こんにちは', img.get_attribute('alt'))
      assert_equal('wovn-src:Hello', img.previous.content)
    end

    def test_replace_in_fragment
      store = Store.instance
      url = {
        :protocol => 'http',
        :host => 'www.example.com',
        :pathname => 'hello/index.html'
      }
      text_index = {
        'Hello' => {'ja' => [{'data' => 'こんにちは'}]}
      }
      src_index = {
        'http://www.example.com/test.img' => {'ja' => [{'data' => 'http://test.com/ttt.img'}]}
      }
      img_src_prefix = 'prefix::'
      replacer = ImageReplacer.new(store, url, text_index, src_index, img_src_prefix, [])

      dom = Helpers::NokogumboHelper::parse_fragment('<img src="http://www.example.com/test.img" alt="Hello">')
      replacer.replace(dom, Lang.new('ja'))

      img = dom.xpath('.//img')[0]
      assert_equal('prefix::http://test.com/ttt.img', img.get_attribute('src'))
      assert_equal('こんにちは', img.get_attribute('alt'))
      assert_equal('wovn-src:Hello', img.previous.content)
    end

    def test_replace_relative_path
      store = Store.instance
      url = {
        :protocol => 'http',
        :host => 'www.example.com',
        :path => '/hello/'
      }
      text_index = {}
      src_index = {
        'http://www.example.com/hello/test.img' => {'ja' => [{'data' => 'http://test.com/ttt.img'}]}
      }
      replacer = ImageReplacer.new(store, url, text_index, src_index, '', [])

      dom = Wovnrb.get_dom('<img src="test.img"')
      replacer.replace(dom, Lang.new('ja'))

      img = dom.xpath('//img')[0]
      assert_equal('http://test.com/ttt.img', img.get_attribute('src'))
      assert_nil(img.previous)
    end

    def test_replace_root_path
      store = Store.instance
      url = {
        :protocol => 'http',
        :host => 'www.example.com',
        :path => '/hello/'
      }
      text_index = {}
      src_index = {
        'http://www.example.com/test.img' => {'ja' => [{'data' => 'http://test.com/ttt.img'}]}
      }
      replacer = ImageReplacer.new(store, url, text_index, src_index, '', [])

      dom = Wovnrb.get_dom('<img src="/test.img"')
      replacer.replace(dom, Lang.new('ja'))

      img = dom.xpath('//img')[0]
      assert_equal('http://test.com/ttt.img', img.get_attribute('src'))
      assert_nil(img.previous)
    end

    def test_replace_absolute_path
      img = img_test_helper('/hello/')
      assert_equal('http://test.com/ttt.img', img.get_attribute('src'))
      assert_nil(img.previous)
    end

    def test_replace_empty_path
      img = img_test_helper('')
      assert_equal('http://test.com/ttt.img', img.get_attribute('src'))
      assert_nil(img.previous)
    end

    private
    def img_test_helper path
      store = Store.instance
      url = {
        protocol: 'http',
        host: 'www.example.com',
        path: path,
      }
      text_index = {}
      src_index = {
        'http://www.test.com/test.img' => {'ja' => [{'data' => 'http://test.com/ttt.img'}]}
      }
      replacer = ImageReplacer.new(store, url, text_index, src_index, '', [])
      dom = Wovnrb.get_dom('<img src="http://www.test.com/test.img"')
      replacer.replace(dom, Lang.new('ja'))
      dom.xpath('//img')[0]
    end

    def test_replace_host_alias
      store = Store.instance
      url = {
        :protocol => 'http',
        :host => 'www.example.com',
        :path => '/hello/'
      }
      src_index = {
        'http://www.test.com/test.img' => {'ja' => [{'data' => 'http://test.com/ttt.img'}]}
      }
      path = '/test.img'

      # no replace image if not exist host alias
      img = img_dom_helper(store, url, src_index, path, [])
      assert_equal('/test.img', img.get_attribute('src'))
      img = img_dom_helper(store, url, src_index, path, ['www.test.com'])
      assert_equal('/test.img', img.get_attribute('src'))
      img = img_dom_helper(store, url, src_index, path, ['www.example.com'])
      assert_equal('/test.img', img.get_attribute('src'))
      img = img_dom_helper(store, url, src_index, path, ['www.test.com', 'www.wrong.com'])
      assert_equal('/test.img', img.get_attribute('src'))

      # replace image if exist host alias
      img = img_dom_helper(store, url, src_index, path, ['www.test.com', 'www.example.com'])
      assert_equal('http://test.com/ttt.img', img.get_attribute('src'))
    end

    private
    def img_dom_helper(store, url, src_index, path, host_aliases)
      text_index = {}
      replacer = ImageReplacer.new(store, url, text_index, src_index, '', host_aliases)
      dom = Wovnrb.get_dom('<img src="' + path + '"')
      replacer.replace(dom, Lang.new('ja'))
      dom.xpath('//img')[0]
    end
  end
end
