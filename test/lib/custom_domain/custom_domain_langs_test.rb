require 'test_helper'
require 'wovnrb/custom_domain/custom_domain_langs'

module Wovnrb
  class CustomDomainLangsTest < WovnMiniTest
    def setup
      custom_domain_langs_setting = {
        'fr' => { 'url' => 'foo.com/' },
        'ja' => { 'url' => 'foo.com/path', 'source' => 'japan.foo.com/' },
        'zh-CHS' => { 'url' => 'foo.com/dir/path' },
        'en' => { 'url' => 'english.foo.com/', 'source' => 'global.foo.com/' }
      }
      @custom_domain_langs = CustomDomainLangs.new(custom_domain_langs_setting)
    end

    def test_get_custom_domain_lang_by_lang
      assert_nil(@custom_domain_langs.custom_domain_lang_by_lang('unknown'))

      assert_equal('fr', lang_for(@custom_domain_langs.custom_domain_lang_by_lang('fr')))
      assert_equal('ja', lang_for(@custom_domain_langs.custom_domain_lang_by_lang('ja')))
      assert_equal('zh-CHS', lang_for(@custom_domain_langs.custom_domain_lang_by_lang('zh-CHS')))
      assert_equal('en', lang_for(@custom_domain_langs.custom_domain_lang_by_lang('en')))
    end

    def test_get_custom_domain_lang_by_url
      assert_nil(@custom_domain_langs.custom_domain_lang_by_url('http://otherdomain.com'))
      assert_nil(@custom_domain_langs.custom_domain_lang_by_url('http://otherdomain.com/path/test.html'))
      assert_nil(@custom_domain_langs.custom_domain_lang_by_url('http://otherdomain.com/dir/path/test.html'))

      assert_equal('fr', lang_for(@custom_domain_langs.custom_domain_lang_by_url('http://foo.com')))
      assert_equal('fr', lang_for(@custom_domain_langs.custom_domain_lang_by_url('http://foo.com/')))
      assert_equal('fr', lang_for(@custom_domain_langs.custom_domain_lang_by_url('http://foo.com/test.html')))

      assert_equal('ja', lang_for(@custom_domain_langs.custom_domain_lang_by_url('http://foo.com/path')))
      assert_equal('ja', lang_for(@custom_domain_langs.custom_domain_lang_by_url('http://foo.com/path/')))
      assert_equal('ja', lang_for(@custom_domain_langs.custom_domain_lang_by_url('http://foo.com/path/dir')))
      assert_equal('ja', lang_for(@custom_domain_langs.custom_domain_lang_by_url('http://foo.com/path/test.html')))

      assert_equal('zh-CHS', lang_for(@custom_domain_langs.custom_domain_lang_by_url('http://foo.com/dir/path')))
      assert_equal('zh-CHS', lang_for(@custom_domain_langs.custom_domain_lang_by_url('http://foo.com/dir/path/')))
      assert_equal('zh-CHS', lang_for(@custom_domain_langs.custom_domain_lang_by_url('http://foo.com/dir/path/dir')))
      assert_equal('zh-CHS', lang_for(@custom_domain_langs.custom_domain_lang_by_url('http://foo.com/dir/path/test.html')))

      assert_equal('en', lang_for(@custom_domain_langs.custom_domain_lang_by_url('http://english.foo.com/dir/path')))
      assert_equal('en', lang_for(@custom_domain_langs.custom_domain_lang_by_url('http://english.foo.com/dir/path/')))
      assert_equal('en', lang_for(@custom_domain_langs.custom_domain_lang_by_url('http://english.foo.com/dir/path/test.html')))
    end

    def test_get_custom_domain_lang_by_url_with_nested_paths
      custom_domain_langs_setting = {
        'ja' => { 'url' => 'foo.com/path' },
        'en' => { 'url' => 'foo.com/path/en' },
        'fr' => { 'url' => 'foo.com/path/fr' }
      }
      custom_domain_langs = CustomDomainLangs.new(custom_domain_langs_setting)
      assert_equal('ja', lang_for(custom_domain_langs.custom_domain_lang_by_url('http://foo.com/path')))
      assert_equal('en', lang_for(custom_domain_langs.custom_domain_lang_by_url('http://foo.com/path/en')))
      assert_equal('fr', lang_for(custom_domain_langs.custom_domain_lang_by_url('http://foo.com/path/fr')))
    end

    def test_to_html_swapper_hash
      expected = {
        'foo.com' => 'fr',
        'foo.com/path' => 'ja',
        'foo.com/dir/path' => 'zh-CHS',
        'english.foo.com' => 'en'
      }

      assert(hash_equals(expected, @custom_domain_langs.to_html_swapper_hash))
    end

    private

    def lang_for(custom_domain_lang)
      custom_domain_lang.lang
    end

    def hash_equals(orig_hash, test_hash)
      (orig_hash <=> test_hash) == 0
    end
  end
end
