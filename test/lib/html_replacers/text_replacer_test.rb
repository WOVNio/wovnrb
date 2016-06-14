require 'test_helper'
require 'webmock/minitest'

class Wovnrb
  class TextReplacerTest < WovnMiniTest
    def test_replace
      replacer = TextReplacer.new({
        'Hello' => {'ja' => [{'data' => 'こんにちは'}]}
      })

      dom = Wovnrb.get_dom('Hello')
      replacer.replace(dom, Lang.new('ja'))

      content = dom.xpath('//text()')[0].content
      assert_equal('こんにちは', content)
    end

    def test_replace_multiple
      replacer = TextReplacer.new({
        'Hello' => {'ja' => [{'data' => 'こんにちは'}]},
        'Bye' => {'ja' => [{'data' => 'さようなら'}]}
      })

      dom = Wovnrb.get_dom('<span>Hello</span><span>Bye</span>')
      replacer.replace(dom, Lang.new('ja'))

      content = dom.xpath('//text()')[0].content
      content2 = dom.xpath('//text()')[1].content
      assert_equal('こんにちは', content)
      assert_equal('さようなら', content2)
    end

    def test_replace_wovn_ignore
      replacer = TextReplacer.new({
        'Hello' => {'ja' => [{'data' => 'こんにちは'}]}
      })

      dom = Wovnrb.get_dom('<div wovn-ignore>Hello</div>')
      replacer.replace(dom, Lang.new('ja'))

      content = dom.xpath('//text()')[0].content
      assert_equal('Hello', content)
    end
  end
end
