# -*- encoding: UTF-8 -*-
require 'test_helper'
require 'webmock/minitest'

module Wovnrb
  class HTMLTextReplacerTest < WovnMiniTest
    def test_replace
      replacer = HTMLTextReplacer.new({
        'Hello' => {'ja' => [{'data' => 'こんにちは'}]}
      }, {})

      dom = Wovnrb.get_dom('Hello')
      replacer.replace(dom, Lang.new('ja'))

      content = dom.xpath('//text()')[0].content
      assert_equal('こんにちは', content)
    end

    def test_replace_multiple
      replacer = HTMLTextReplacer.new({
        'Hello' => {'ja' => [{'data' => 'こんにちは'}]},
        'Bye' => {'ja' => [{'data' => 'さようなら'}]}
      }, {})

      dom = Wovnrb.get_dom('<span>Hello</span><span>Bye</span>')
      replacer.replace(dom, Lang.new('ja'))

      content = dom.xpath('//text()')[0].content
      content2 = dom.xpath('//text()')[1].content
      assert_equal('こんにちは', content)
      assert_equal('さようなら', content2)
    end

    def test_replace_wovn_ignore
      replacer = HTMLTextReplacer.new({
        'Hello' => {'ja' => [{'data' => 'こんにちは'}]}
      }, {})

      dom = Wovnrb.get_dom('<div id="test" wovn-ignore>Hello</div>')
      replacer.replace(dom, Lang.new('ja'))

      content = dom.xpath('//text()')[0].content
      assert_equal('Hello', content)
    end

    def test_replace_with_complex_value
      replacer = HTMLTextReplacer.new({}, {
        'Hello<a>World</a>' => {'ja' => [{'data' => 'こんにちは<a>World</a>'}]}
      })

      dom = Wovnrb.get_dom('<p>Hello <a>World</a></p>')
      replacer.replace(dom, Lang.new('ja'))

      inner_html = dom.xpath('//p')[0].inner_html
      assert_equal('こんにちは<a>World</a>', inner_html)
    end

    def test_replace_multiple_with_complex_value
      replacer = HTMLTextReplacer.new({}, {
        'Hello<a>World</a>' => {'ja' => [{'data' => 'こんにちは<a>World</a>'}]},
        'Another Hello<a>World ;)</a>' => {'ja' => [{'data' => 'こんにちは<a>World ;)</a>'}]},
      })

      dom = Wovnrb.get_dom('<p>Hello <a>World</a></p><p>Another Hello <a>World ;)</a></p>')
      replacer.replace(dom, Lang.new('ja'))

      inner_html_1 = dom.xpath('//p')[0].inner_html
      inner_html_2 = dom.xpath('//p')[1].inner_html
      assert_equal('こんにちは<a>World</a>', inner_html_1)
      assert_equal('こんにちは<a>World ;)</a>', inner_html_2)
    end

    def test_replace_wovn_ignore_with_complex_value
      replacer = HTMLTextReplacer.new({}, {
        'Hello<a>World</a>' => {'ja' => [{'data' => 'こんにちは<a>World</a>'}]}
      })

      dom = Wovnrb.get_dom('<p wovn-ignore>Hello <a>World</a></p>')
      replacer.replace(dom, Lang.new('ja'))

      inner_html = dom.xpath('//p')[0].inner_html
      assert_equal('Hello <a>World</a>', inner_html)
    end

    def test_replace_with_complex_value_src_unballanced_left_alignment
      replacer = HTMLTextReplacer.new({}, {
        'Hello<a>World</a>' => {'ja' => [{'data' => '<a>こんにちは World</a>'}]}
      })

      dom = Wovnrb.get_dom('<p>Hello <a>World</a></p>')
      replacer.replace(dom, Lang.new('ja'))

      inner_html = dom.xpath('//p')[0].inner_html
      assert_equal("<a>こんにちは World</a>", inner_html)
    end

    def test_replace_with_complex_value_src_unballanced_right_alignment
      replacer = HTMLTextReplacer.new({}, {
        'Hello<a>World</a>!' => {'ja' => [{'data' => 'こんにちは<a>World</a>'}]}
      })

      dom = Wovnrb.get_dom('<p>Hello <a>World</a>!</p>')
      replacer.replace(dom, Lang.new('ja'))

      inner_html = dom.xpath('//p')[0].inner_html
      assert_equal("こんにちは<a>World</a>", inner_html)
    end

    def test_replace_with_complex_value_dst_unballanced_left_alignment
      replacer = HTMLTextReplacer.new({}, {
        '<a>Hello World</a>!' => {'ja' => [{'data' => 'こんにちは<a>World</a>!'}]}
      })

      dom = Wovnrb.get_dom('<p><a>Hello World</a>!</p>')
      replacer.replace(dom, Lang.new('ja'))

      inner_html = dom.xpath('//p')[0].inner_html
      assert_equal('こんにちは<a>World</a>!', inner_html)
    end

    def test_replace_with_complex_value_dst_unballanced_right_alignment
      replacer = HTMLTextReplacer.new({}, {
        'Hello<a>World</a>' => {'ja' => [{'data' => 'こんにちは<a>World</a>!'}]}
      })

      dom = Wovnrb.get_dom('<p>Hello <a>World</a></p>')
      replacer.replace(dom, Lang.new('ja'))

      inner_html = dom.xpath('//p')[0].inner_html
      assert_equal('こんにちは<a>World</a>!', inner_html)
    end
  end
end
