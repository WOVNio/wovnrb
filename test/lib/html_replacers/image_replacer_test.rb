# -*- encoding: UTF-8 -*-
require 'test_helper'
require 'webmock/minitest'

module Wovnrb
  class ImageReplacerTest < WovnMiniTest
    def test_replace
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
      replacer = ImageReplacer.new(url, text_index, src_index, img_src_prefix)

      dom = Wovnrb.get_dom('<img src="http://www.example.com/test.img" alt="Hello"')
      replacer.replace(dom, Lang.new('ja'))

      img = dom.xpath('//img')[0]
      assert_equal('prefix::http://test.com/ttt.img', img.get_attribute('src'))
      assert_equal('こんにちは', img.get_attribute('alt'))
      assert_equal('wovn-src:Hello', img.previous.content)
    end

    def test_replace_relative_path
      url = {
        :protocol => 'http',
        :host => 'www.example.com',
        :path => '/hello/'
      }
      text_index = {}
      src_index = {
        'http://www.example.com/hello/test.img' => {'ja' => [{'data' => 'http://test.com/ttt.img'}]}
      }
      replacer = ImageReplacer.new(url, text_index, src_index, '')

      dom = Wovnrb.get_dom('<img src="test.img"')
      replacer.replace(dom, Lang.new('ja'))

      img = dom.xpath('//img')[0]
      assert_equal('http://test.com/ttt.img', img.get_attribute('src'))
      assert_nil(img.previous)
    end

    def test_replace_root_path
      url = {
        :protocol => 'http',
        :host => 'www.example.com',
        :path => '/hello/'
      }
      text_index = {}
      src_index = {
        'http://www.example.com/test.img' => {'ja' => [{'data' => 'http://test.com/ttt.img'}]}
      }
      replacer = ImageReplacer.new(url, text_index, src_index, '')

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
      url = {
        protocol: 'http',
        host: 'www.example.com',
        path: path,
      }
      text_index = {}
      src_index = {
        'http://www.test.com/test.img' => {'ja' => [{'data' => 'http://test.com/ttt.img'}]}
      }
      replacer = ImageReplacer.new(url, text_index, src_index, '')
      dom = Wovnrb.get_dom('<img src="http://www.test.com/test.img"')
      replacer.replace(dom, Lang.new('ja'))
      dom.xpath('//img')[0]
    end
  end
end
