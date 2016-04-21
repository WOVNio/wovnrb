require 'test_helper'
require 'webmock/minitest'

module Wovnrb
  class ScriptReplacerTest < WovnMiniTest
    def test_replace
      store = Store.instance
      store.settings['user_token'] = 'test_token'
      store.settings['default_lang'] = 'en'
      store.settings['url_pattern'] = 'domain'

      replacer = ScriptReplacer.new(store)
      dom = to_head_dom('<script src="test/test.js"></script>')
      replacer.replace(dom, Lang.new('ja'))

      scripts = dom.xpath('//script')
      assert_equal(2, scripts.length)

      wovn_script = scripts[0]
      other_script = scripts[1]

      check_wovn_script(wovn_script, 'test_token', 'ja', 'en', 'domain')
      assert_equal('test/test.js', other_script.get_attribute('src'))
    end

    def test_with_embed_wovn
      store = Store.instance
      store.settings['user_token'] = 'test_token'
      store.settings['default_lang'] = 'en'
      store.settings['url_pattern'] = 'domain'

      replacer = ScriptReplacer.new(store)
      dom = to_head_dom('<script src="//j.wovn.io/aaaa" data-wovnio="key=test_token" async></script>')
      replacer.replace(dom, Lang.new('ja'))

      scripts = dom.xpath('//script')
      assert_equal(1, scripts.length)

      check_wovn_script(scripts[0], 'test_token', 'ja', 'en', 'domain')
    end

    def test_with_multiple_embed_wovn
      store = Store.instance
      store.settings['user_token'] = 'test_token'
      store.settings['default_lang'] = 'en'
      store.settings['url_pattern'] = 'domain'

      replacer = ScriptReplacer.new(store)
      dom = to_head_dom('<script src="//j.wovn.io/aaaa" data-wovnio="key=test_token" async></script><script src="//j.wovn.io/bbb" data-wovnio="key=test_token" async></script>')
      replacer.replace(dom, Lang.new('ja'))

      scripts = dom.xpath('//script')
      assert_equal(1, scripts.length)

      check_wovn_script(scripts[0], 'test_token', 'ja', 'en', 'domain')
    end

    def test_with_embed_wovn_at_body
      store = Store.instance
      store.settings['user_token'] = 'test_token'
      store.settings['default_lang'] = 'en'
      store.settings['url_pattern'] = 'domain'

      replacer = ScriptReplacer.new(store)
      dom = Wovnrb.get_dom('<script src="//j.wovn.io/aaaa" data-wovnio="key=test_token" async></script>')
      replacer.replace(dom, Lang.new('ja'))

      scripts = dom.xpath('//script')
      assert_equal(1, scripts.length)

      check_wovn_script(scripts[0], 'test_token', 'ja', 'en', 'domain')
    end

    def check_wovn_script(node, user_token, current_lang, default_lang, url_pattern)
      wovn_data = [
        ['src', '//j.wovn.io/1'],
        ['async', 'true'],
        ['data-wovnio', "key=#{user_token}&backend=true&currentLang=#{current_lang}&defaultLang=#{default_lang}&urlPattern=#{url_pattern}&version=#{Wovnrb::VERSION}"]
      ]
      wovn_data.each do |data|
        assert_equal(data[1], node.get_attribute(data[0]))
      end
      assert_equal(wovn_data.length, node.attributes.length)
    end

    def to_head_dom(html)
      Wovnrb.to_dom("<html><head>#{html}</head></html>")
    end
  end
end
