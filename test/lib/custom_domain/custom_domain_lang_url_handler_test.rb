require 'test_helper'
require 'wovnrb/custom_domain/custom_domain_langs'
require 'wovnrb/custom_domain/custom_domain_lang_url_handler'

module Wovnrb
  class CustomDomainLangUrlHandlerTest < WovnMiniTest
    def setup
      custom_domain_langs_setting = {
        'fr' => { 'url' => 'foo.com/' },
        'ja' => { 'url' => 'foo.com/path' },
        'zh-CHS' => { 'url' => 'foo.com/dir/path' },
        'en' => { 'url' => 'english.foo.com/' },
        'zh-Hant-HK' => { 'url' => 'zh-hant-hk.foo.com/zh' },
        'pt' => { 'url' => '17797-trial2.foo.com/' }
      }
      @custom_domain_langs = CustomDomainLangs.new(custom_domain_langs_setting)
    end

    def test_add_custom_domain_lang_to_absolute_url
      # apply to original lang
      assert_equal('foo.com', CustomDomainLangUrlHandler.add_custom_domain_lang_to_absolute_url('foo.com', 'fr', @custom_domain_langs))
      assert_equal('foo.com/path', CustomDomainLangUrlHandler.add_custom_domain_lang_to_absolute_url('foo.com', 'ja', @custom_domain_langs))
      assert_equal('foo.com/dir/path', CustomDomainLangUrlHandler.add_custom_domain_lang_to_absolute_url('foo.com', 'zh-CHS', @custom_domain_langs))
      assert_equal('english.foo.com', CustomDomainLangUrlHandler.add_custom_domain_lang_to_absolute_url('foo.com', 'en', @custom_domain_langs))
      assert_equal('zh-hant-hk.foo.com/zh', CustomDomainLangUrlHandler.add_custom_domain_lang_to_absolute_url('foo.com', 'zh-Hant-HK', @custom_domain_langs))

      # apply to target lang
      assert_equal('foo.com', CustomDomainLangUrlHandler.add_custom_domain_lang_to_absolute_url('zh-hant-hk.foo.com/zh', 'fr', @custom_domain_langs))
      assert_equal('foo.com/path', CustomDomainLangUrlHandler.add_custom_domain_lang_to_absolute_url('zh-hant-hk.foo.com/zh', 'ja', @custom_domain_langs))
      assert_equal('foo.com/dir/path', CustomDomainLangUrlHandler.add_custom_domain_lang_to_absolute_url('zh-hant-hk.foo.com/zh', 'zh-CHS', @custom_domain_langs))
      assert_equal('english.foo.com', CustomDomainLangUrlHandler.add_custom_domain_lang_to_absolute_url('zh-hant-hk.foo.com/zh', 'en', @custom_domain_langs))
      assert_equal('zh-hant-hk.foo.com/zh', CustomDomainLangUrlHandler.add_custom_domain_lang_to_absolute_url('zh-hant-hk.foo.com/zh', 'zh-Hant-HK', @custom_domain_langs))

      assert_equal('zh-hant-hk.foo.com/zh', CustomDomainLangUrlHandler.add_custom_domain_lang_to_absolute_url('foo.com/path', 'zh-Hant-HK', @custom_domain_langs))
      assert_equal('zh-hant-hk.foo.com/zh/', CustomDomainLangUrlHandler.add_custom_domain_lang_to_absolute_url('foo.com/path/', 'zh-Hant-HK', @custom_domain_langs))
      assert_equal('zh-hant-hk.foo.com/zh/index.html', CustomDomainLangUrlHandler.add_custom_domain_lang_to_absolute_url('foo.com/path/index.html', 'zh-Hant-HK', @custom_domain_langs))
      assert_equal('zh-hant-hk.foo.com/zh/path2/index.html', CustomDomainLangUrlHandler.add_custom_domain_lang_to_absolute_url('foo.com/path/path2/index.html', 'zh-Hant-HK', @custom_domain_langs))
      assert_equal('zh-hant-hk.foo.com/zh/path2/index.html?test=1', CustomDomainLangUrlHandler.add_custom_domain_lang_to_absolute_url('foo.com/path/path2/index.html?test=1', 'zh-Hant-HK', @custom_domain_langs))
      assert_equal('zh-hant-hk.foo.com/zh/path2/index.html#hash', CustomDomainLangUrlHandler.add_custom_domain_lang_to_absolute_url('foo.com/path/path2/index.html#hash', 'zh-Hant-HK', @custom_domain_langs))
    end

    def test_change_to_new_custom_domain_lang
      fr = @custom_domain_langs.custom_domain_lang_by_lang('fr')
      ja = @custom_domain_langs.custom_domain_lang_by_lang('ja')
      zh_chs = @custom_domain_langs.custom_domain_lang_by_lang('zh-CHS')
      en = @custom_domain_langs.custom_domain_lang_by_lang('en')
      zh_hant_hk = @custom_domain_langs.custom_domain_lang_by_lang('zh-Hant-HK')
      pt = @custom_domain_langs.custom_domain_lang_by_lang('pt')

      assert_equal('foo.com', CustomDomainLangUrlHandler.change_to_new_custom_domain_lang('foo.com', fr, fr))
      assert_equal('foo.com/path', CustomDomainLangUrlHandler.change_to_new_custom_domain_lang('foo.com', fr, ja))
      assert_equal('foo.com/dir/path', CustomDomainLangUrlHandler.change_to_new_custom_domain_lang('foo.com', fr, zh_chs))
      assert_equal('english.foo.com', CustomDomainLangUrlHandler.change_to_new_custom_domain_lang('foo.com', fr, en))
      assert_equal('zh-hant-hk.foo.com/zh', CustomDomainLangUrlHandler.change_to_new_custom_domain_lang('foo.com', fr, zh_hant_hk))

      assert_equal('foo.com', CustomDomainLangUrlHandler.change_to_new_custom_domain_lang('zh-hant-hk.foo.com/zh', zh_hant_hk, fr))
      assert_equal('foo.com/path', CustomDomainLangUrlHandler.change_to_new_custom_domain_lang('zh-hant-hk.foo.com/zh', zh_hant_hk, ja))
      assert_equal('foo.com/dir/path', CustomDomainLangUrlHandler.change_to_new_custom_domain_lang('zh-hant-hk.foo.com/zh', zh_hant_hk, zh_chs))
      assert_equal('english.foo.com', CustomDomainLangUrlHandler.change_to_new_custom_domain_lang('zh-hant-hk.foo.com/zh', zh_hant_hk, en))
      assert_equal('zh-hant-hk.foo.com/zh', CustomDomainLangUrlHandler.change_to_new_custom_domain_lang('zh-hant-hk.foo.com/zh', zh_hant_hk, zh_hant_hk))

      assert_equal('foo.com/path', CustomDomainLangUrlHandler.change_to_new_custom_domain_lang('zh-hant-hk.foo.com/zh', zh_hant_hk, ja))
      assert_equal('foo.com/path/', CustomDomainLangUrlHandler.change_to_new_custom_domain_lang('zh-hant-hk.foo.com/zh/', zh_hant_hk, ja))
      assert_equal('foo.com/path/index.html', CustomDomainLangUrlHandler.change_to_new_custom_domain_lang('zh-hant-hk.foo.com/zh/index.html', zh_hant_hk, ja))
      assert_equal('foo.com/path/path', CustomDomainLangUrlHandler.change_to_new_custom_domain_lang('zh-hant-hk.foo.com/zh/path', zh_hant_hk, ja))
      assert_equal('foo.com/path/path/index.html', CustomDomainLangUrlHandler.change_to_new_custom_domain_lang('zh-hant-hk.foo.com/zh/path/index.html', zh_hant_hk, ja))
      assert_equal('foo.com/path/path/index.html?test=1', CustomDomainLangUrlHandler.change_to_new_custom_domain_lang('zh-hant-hk.foo.com/zh/path/index.html?test=1', zh_hant_hk, ja))
      assert_equal('foo.com/path/path/index.html#hash', CustomDomainLangUrlHandler.change_to_new_custom_domain_lang('zh-hant-hk.foo.com/zh/path/index.html#hash', zh_hant_hk, ja))

      assert_equal('zh-hant-hk.foo.com/zhtrap', CustomDomainLangUrlHandler.change_to_new_custom_domain_lang('zh-hant-hk.foo.com/zhtrap', zh_hant_hk, ja))
      assert_equal('english.foo.com/zhtrap', CustomDomainLangUrlHandler.change_to_new_custom_domain_lang('17797-trial2.foo.com/zhtrap', pt, en))
      assert_equal('17797-trial2.foo.com/zhtrap', CustomDomainLangUrlHandler.change_to_new_custom_domain_lang('17797-trial2.foo.com/zhtrap', pt, pt))
    end
  end
end
