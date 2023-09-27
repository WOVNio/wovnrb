require 'test_helper'

module Wovnrb
  class UrlLanguageSwitcherTest < WovnMiniTest
    def test_add_lang_code
      lang_code = 'zh-cht'
      store_options = { 'url_pattern' => 'subdomain' }

      store, headers = store_headers_factory(store_options, 'http://favy.tips')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('http://www.facebook.com', lang_code, headers)

      assert_equal('http://www.facebook.com', res)
    end

    def test_add_lang_code_relative_slash_href_url_with_path
      lang_code = 'fr'

      store_options = { 'url_pattern' => 'subdomain' }

      store, headers = store_headers_factory(store_options, 'http://favy.tips/topics/44')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('/topics/50', lang_code, headers)

      assert_equal('http://fr.favy.tips/topics/50', res)
    end

    def test_add_lang_code_relative_dot_href_url_with_path
      lang_code = 'fr'

      store_options = { 'url_pattern' => 'subdomain' }

      store, headers = store_headers_factory(store_options, 'http://favy.tips/topics/44')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('./topics/50', lang_code, headers)

      assert_equal('http://fr.favy.tips/topics/topics/50', res)
    end

    def test_add_lang_code_relative_two_dots_href_url_with_path
      lang_code = 'fr'

      store_options = { 'url_pattern' => 'subdomain' }

      store, headers = store_headers_factory(store_options, 'http://favy.tips/topics/44')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('../topics/50', lang_code, headers)

      assert_equal('http://fr.favy.tips/topics/50', res)
    end

    def test_add_lang_code_trad_chinese
      lang_code = 'zh-cht'

      store_options = { 'url_pattern' => 'subdomain' }

      store, headers = store_headers_factory(store_options, 'http://favy.tips')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('http://favy.tips/topics/31', lang_code, headers)

      assert_equal('http://zh-cht.favy.tips/topics/31', res)
    end

    def test_add_lang_code_trad_chinese_two
      lang_code = 'zh-cht'

      store_options = { 'url_pattern' => 'subdomain' }

      store, headers = store_headers_factory(store_options, 'http://favy.tips')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('/topics/31', lang_code, headers)

      assert_equal('http://zh-cht.favy.tips/topics/31', res)
    end

    def test_add_lang_code_trad_chinese_lang_in_link_already
      lang_code = 'zh-cht'

      store_options = { 'url_pattern' => 'subdomain' }

      store, headers = store_headers_factory(store_options, 'http://favy.tips')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('http://zh-cht.favy.tips/topics/31', lang_code, headers)

      assert_equal('http://zh-cht.favy.tips/topics/31', res)
    end

    def test_add_lang_code_no_protocol
      lang_code = 'zh-cht'

      store_options = { 'url_pattern' => 'subdomain' }

      store, headers = store_headers_factory(store_options, 'https://google.com')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('//google.com', lang_code, headers)

      assert_equal('//zh-cht.google.com', res)
    end

    def test_add_lang_code_no_protocol_two
      lang_code = 'zh-cht'

      store_options = { 'url_pattern' => 'subdomain' }

      store, headers = store_headers_factory(store_options, 'https://favy.tips')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('//google.com', lang_code, headers)

      assert_equal('//google.com', res)
    end

    def test_add_lang_code_invalid_url
      lang_code = 'zh-cht'
      store_options = { 'url_pattern' => 'subdomain' }

      store, headers = store_headers_factory(store_options, 'https://favy.tips')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('http://www.facebook.com/sharer.php?u=http://favy.tips/topics/50&amp;amp;t=Gourmet Tofu World: Vegetarian-Friendly Japanese Food is Here!', lang_code, headers)

      assert_equal('http://www.facebook.com/sharer.php?u=http://favy.tips/topics/50&amp;amp;t=Gourmet Tofu World: Vegetarian-Friendly Japanese Food is Here!', res)
    end

    def test_add_lang_code_path_only_with_slash
      lang_code = 'zh-cht'

      store_options = { 'url_pattern' => 'subdomain' }

      store, headers = store_headers_factory(store_options, 'http://favy.tips')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('/topics/31', lang_code, headers)

      assert_equal('http://zh-cht.favy.tips/topics/31', res)
    end

    def test_add_lang_code_path_only_no_slash
      lang_code = 'zh-cht'
      store_options = { 'url_pattern' => 'subdomain' }

      store, headers = store_headers_factory(store_options, 'http://favy.tips')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('topics/31', lang_code, headers)

      assert_equal('http://zh-cht.favy.tips/topics/31', res)
    end

    def test_add_lang_code_path_explicit_page_no_slash
      lang_code = 'zh-cht'

      store_options = { 'url_pattern' => 'subdomain' }

      store, headers = store_headers_factory(store_options, 'http://favy.tips')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('topics/31.html', lang_code, headers)

      assert_equal('http://zh-cht.favy.tips/topics/31.html', res)
    end

    def test_add_lang_code_path_explicit_page_with_slash
      lang_code = 'zh-cht'

      store_options = { 'url_pattern' => 'subdomain' }

      store, headers = store_headers_factory(store_options, 'http://favy.tips')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('/topics/31.html', lang_code, headers)

      assert_equal('http://zh-cht.favy.tips/topics/31.html', res)
    end

    def test_add_lang_code_no_protocol_with_path_explicit_page
      lang_code = 'zh-cht'

      store_options = { 'url_pattern' => 'subdomain' }

      store, headers = store_headers_factory(store_options, 'http://favy.tips')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('//www.google.com/topics/31.php', lang_code, headers)

      assert_equal('//www.google.com/topics/31.php', res)
    end

    def test_add_lang_code_protocol_with_path_explicit_page
      lang_code = 'zh-cht'

      store_options = { 'url_pattern' => 'subdomain' }

      store, headers = store_headers_factory(store_options, 'http://favy.tips')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('http://www.google.com/topics/31.php', lang_code, headers)

      assert_equal('http://www.google.com/topics/31.php', res)
    end

    def test_add_lang_code_relative_path_double_period
      lang_code = 'zh-cht'

      store_options = { 'url_pattern' => 'subdomain' }

      store, headers = store_headers_factory(store_options, 'http://favy.tips')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('../topics/31', lang_code, headers)

      assert_equal('http://zh-cht.favy.tips/topics/31', res)
    end

    def test_add_lang_code_relative_path_single_period
      lang_code = 'zh-cht'

      store_options = { 'url_pattern' => 'subdomain' }

      store, headers = store_headers_factory(store_options, 'http://favy.tips')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('./topics/31', lang_code, headers)

      assert_equal('http://zh-cht.favy.tips/topics/31', res)
    end

    def test_add_lang_code_empty_href
      lang_code = 'zh-cht'

      store_options = { 'url_pattern' => 'subdomain' }

      store, headers = store_headers_factory(store_options, 'http://favy.tips')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('', lang_code, headers)

      assert_equal('', res)
    end

    def test_add_lang_code_hash_href
      lang_code = 'zh-cht'

      store_options = { 'url_pattern' => 'subdomain' }

      store, headers = store_headers_factory(store_options, 'http://favy.tips')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('#', lang_code, headers)

      assert_equal('#', res)
    end

    def test_add_lang_code_nil_href
      lang_code = 'en'
      store_options = { 'url_pattern' => 'subdomain' }

      store, headers = store_headers_factory(store_options, 'http://favy.tips')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code(nil, lang_code, headers)

      assert_nil(res)
    end

    def test_add_lang_code_absolute_different_host
      lang_code = 'fr'
      store_options = { 'url_pattern' => 'subdomain' }

      store, headers = store_headers_factory(store_options, 'http://google.com')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('http://yahoo.co.jp', lang_code, headers)

      assert_equal('http://yahoo.co.jp', res)
    end

    def test_add_lang_code_absolute_subdomain_no_subdomain
      lang_code = 'fr'
      store_options = { 'url_pattern' => 'subdomain' }

      store, headers = store_headers_factory(store_options, 'http://google.com')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('http://google.com', lang_code, headers)

      assert_equal('http://fr.google.com', res)
    end

    def test_add_lang_code_absolute_subdomain_with_subdomain
      lang_code = 'fr'

      store_options = { 'url_pattern' => 'subdomain' }

      store, headers = store_headers_factory(store_options, 'http://home.google.com')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('http://home.google.com', lang_code, headers)

      assert_equal('http://fr.home.google.com', res)
    end

    def test_add_lang_code_absolute_query_no_query
      lang_code = 'fr'

      store_options = { 'url_pattern' => 'query' }

      store, headers = store_headers_factory(store_options, 'http://google.com')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('http://google.com', lang_code, headers)

      assert_equal('http://google.com?wovn=fr', res)
    end

    def test_add_lang_code_absolute_query_with_query
      lang_code = 'fr'

      store_options = { 'url_pattern' => 'query' }

      store, headers = store_headers_factory(store_options, 'http://google.com')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('http://google.com?hey=yo', lang_code, headers)

      assert_equal('http://google.com?hey=yo&wovn=fr', res)
    end

    def test_add_lang_code_absolute_query_with_hash
      lang_code = 'fr'

      store_options = { 'url_pattern' => 'query' }

      store, headers = store_headers_factory(store_options, 'http://google.com')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('http://google.com#test', lang_code, headers)

      assert_equal('http://google.com?wovn=fr#test', res)
    end

    def test_add_lang_code_absolute_query_and_lang_param_name_with_no_query
      lang_code = 'fr'

      store_options = { 'url_pattern' => 'query', 'lang_param_name' => 'test_param' }

      store, headers = store_headers_factory(store_options, 'http://google.com')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('http://google.com', lang_code, headers)

      assert_equal('http://google.com?test_param=fr', res)
    end

    def test_add_lang_code_absolute_query_and_lang_param_name_with_query
      lang_code = 'fr'

      store_options = { 'url_pattern' => 'query', 'lang_param_name' => 'test_param' }

      store, headers = store_headers_factory(store_options, 'http://google.com')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('http://google.com?hey=yo', lang_code, headers)

      assert_equal('http://google.com?hey=yo&test_param=fr', res)
    end

    def test_add_lang_code_absolute_query_and_lang_param_name_with_hash
      lang_code = 'fr'

      store_options = { 'url_pattern' => 'query', 'lang_param_name' => 'test_param' }

      store, headers = store_headers_factory(store_options, 'http://google.com')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('http://google.com#test', lang_code, headers)

      assert_equal('http://google.com?test_param=fr#test', res)
    end

    def test_add_lang_code_absolute_path_no_pathname
      lang_code = 'fr'

      store_options = { 'url_pattern' => 'path' }

      store, headers = store_headers_factory(store_options, 'http://google.com')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('http://google.com', lang_code, headers)

      assert_equal('http://google.com/fr', res)
    end

    def test_add_lang_code__requested_with_deep_path
      lang_code = 'fr'

      store_options = { 'url_pattern' => 'path' }

      store, headers = store_headers_factory(store_options, 'http://google.com/dir1/dir2')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      assert_equal('http://google.com/fr', url_lang_switcher.add_lang_code('http://google.com', lang_code, headers))
      assert_equal('/fr/', url_lang_switcher.add_lang_code('/', lang_code, headers))
      assert_equal('', url_lang_switcher.add_lang_code('', lang_code, headers))
    end

    def test_add_lang_code_absolute_path_with_pathname
      lang_code = 'fr'

      store_options = { 'url_pattern' => 'path' }

      store, headers = store_headers_factory(store_options, 'http://google.com')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('http://google.com/index.html', lang_code, headers)

      assert_equal('http://google.com/fr/index.html', res)
    end

    def test_add_lang_code_absolute_path_with_pathname_hash_is_preserved
      lang_code = 'fr'

      store_options = { 'url_pattern' => 'path' }

      store, headers = store_headers_factory(store_options, 'http://google.com')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('http://google.com/index.html?foo=bar#hash', lang_code, headers)

      assert_equal('http://google.com/fr/index.html?foo=bar#hash', res)
    end

    def test_add_lang_code_absolute_path_with_long_pathname
      lang_code = 'fr'

      store_options = { 'url_pattern' => 'path' }

      store, headers = store_headers_factory(store_options, 'http://google.com')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('http://google.com/hello/long/path/index.html', lang_code, headers)

      assert_equal('http://google.com/fr/hello/long/path/index.html', res)
    end

    def test_add_lang_code_relative_subdomain_leading_slash
      lang_code = 'fr'

      store_options = { 'url_pattern' => 'subdomain' }

      store, headers = store_headers_factory(store_options, 'http://google.com')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('/', lang_code, headers)

      assert_equal('http://fr.google.com/', res)
    end

    def test_add_lang_code_relative_subdomain_leading_slash_filename
      lang_code = 'fr'

      store_options = { 'url_pattern' => 'subdomain' }

      store, headers = store_headers_factory(store_options, 'http://google.com')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('/index.html', lang_code, headers)

      assert_equal('http://fr.google.com/index.html', res)
    end

    def test_add_lang_code_relative_subdomain_no_leading_slash_filename
      lang_code = 'fr'

      store_options = { 'url_pattern' => 'subdomain' }

      store, headers = store_headers_factory(store_options, 'http://google.com')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('index.html', lang_code, headers)

      assert_equal('http://fr.google.com/index.html', res)
    end

    def test_add_lang_code_relative_query_with_no_query
      lang_code = 'fr'

      store_options = { 'url_pattern' => 'query' }

      store, headers = store_headers_factory(store_options, 'http://google.com')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('/index.html', lang_code, headers)

      assert_equal('/index.html?wovn=fr', res)
    end

    def test_add_lang_code_relative_query_with_query
      lang_code = 'fr'

      store_options = { 'url_pattern' => 'query' }

      store, headers = store_headers_factory(store_options, 'http://google.com')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('/index.html?hey=yo', lang_code, headers)

      assert_equal('/index.html?hey=yo&wovn=fr', res)
    end

    def test_add_lang_code_relative_query_with_hash
      lang_code = 'fr'

      store_options = { 'url_pattern' => 'query' }

      store, headers = store_headers_factory(store_options, 'http://google.com')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('/index.html?hey=yo', lang_code, headers)

      assert_equal('/index.html?hey=yo&wovn=fr', res)
    end

    def test_add_lang_code_relative_query_and_lang_param_name_with_no_query
      lang_code = 'fr'

      store_options = { 'url_pattern' => 'query', 'lang_param_name' => 'test_param' }

      store, headers = store_headers_factory(store_options, 'http://google.com')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('/index.html', lang_code, headers)

      assert_equal('/index.html?test_param=fr', res)
    end

    def test_add_lang_code_relative_query_and_lang_param_name_with_query
      lang_code = 'fr'

      store_options = { 'url_pattern' => 'query', 'lang_param_name' => 'test_param' }

      store, headers = store_headers_factory(store_options, 'http://google.com')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('/index.html?hey=yo', lang_code, headers)

      assert_equal('/index.html?hey=yo&test_param=fr', res)
    end

    def test_add_lang_code_relative_query_and_lang_param_name_with_hash
      lang_code = 'fr'

      store_options = { 'url_pattern' => 'query', 'lang_param_name' => 'test_param' }

      store, headers = store_headers_factory(store_options, 'http://google.com')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('/index.html?hey=yo#hey', lang_code, headers)

      assert_equal('/index.html?hey=yo&test_param=fr#hey', res)
    end

    def test_add_lang_code_relative_path_with_leading_slash
      lang_code = 'fr'

      store_options = { 'url_pattern' => 'path' }

      store, headers = store_headers_factory(store_options, 'http://google.com')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('/index.html', lang_code, headers)

      assert_equal('/fr/index.html', res)
    end

    def test_add_lang_code_relative_path_without_leading_slash_different_pathname
      lang_code = 'fr'

      store_options = { 'url_pattern' => 'path' }

      store, headers = store_headers_factory(store_options, 'http://google.com/hello/tab.html')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('index.html', lang_code, headers)

      assert_equal('/fr/hello/index.html', res)
    end

    def test_add_lang_code_relative_path_without_leading_slash_and_dot_dot
      lang_code = 'fr'

      store_options = { 'url_pattern' => 'path' }

      store, headers = store_headers_factory(store_options, 'https://pre.avex.jp/wovn_aaa/news/')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('../news/', lang_code, headers)

      assert_equal("/#{lang_code}/wovn_aaa/news/", res)
    end

    def test_add_lang_code_relative_path_without_leading_slash_different_pathname2
      lang_code = 'fr'

      store_options = { 'url_pattern' => 'path' }

      store, headers = store_headers_factory(store_options, 'http://google.com/hello/tab.html')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('hey/index.html', lang_code, headers)

      assert_equal('/fr/hello/hey/index.html', res)
    end

    def test_add_lang_code_relative_path_at_root
      lang_code = 'fr'

      store_options = { 'url_pattern' => 'path' }

      store, headers = store_headers_factory(store_options, 'http://google.com/')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('index.html', lang_code, headers)

      assert_equal('/fr/index.html', res)
    end

    def test_add_lang_code__jp_domain__path_pattern__absolute_path
      lang_code = 'ja'

      store_options = { 'url_pattern' => 'path' }

      store, headers = store_headers_factory(store_options, 'http://favy.co.jp')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('/page', lang_code, headers)

      assert_equal('/ja/page', res)
    end

    def test_add_lang_code__jp_domain__path_pattern__absolute_path_with_query
      lang_code = 'ja'

      store_options = { 'url_pattern' => 'path' }

      store, headers = store_headers_factory(store_options, 'http://favy.co.jp')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('/page?user=tom', lang_code, headers)

      assert_equal('/ja/page?user=tom', res)
    end

    def test_add_lang_code__jp_domain__path_pattern__absolute_path_with_query__top_page
      lang_code = 'ja'

      store_options = { 'url_pattern' => 'path' }

      store, headers = store_headers_factory(store_options, 'http://favy.co.jp')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('/?user=tom', lang_code, headers)

      assert_equal('/ja/?user=tom', res)
    end

    def test_add_lang_code__jp_domain__path_pattern__absolute_path_with_hash__top_page
      lang_code = 'ja'

      store_options = { 'url_pattern' => 'path' }

      store, headers = store_headers_factory(store_options, 'http://favy.co.jp')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('/#top', lang_code, headers)

      assert_equal('/ja/#top', res)
    end

    def test_add_lang_code__jp_domain__path_pattern__absolute_url
      lang_code = 'ja'

      store_options = { 'url_pattern' => 'path' }

      store, headers = store_headers_factory(store_options, 'http://favy.co.jp')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('http://favy.co.jp/page', lang_code, headers)

      assert_equal('http://favy.co.jp/ja/page', res)
    end

    def test_add_lang_code__jp_domain__path_pattern__absolute_url_with_query
      lang_code = 'ja'

      store_options = { 'url_pattern' => 'path' }

      store, headers = store_headers_factory(store_options, 'http://favy.co.jp')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('http://favy.co.jp?user=tom', lang_code, headers)

      assert_equal('http://favy.co.jp/ja?user=tom', res)
    end

    def test_add_lang_code__jp_domain__path_pattern__absolute_url_with_trailing_slash_and_query
      lang_code = 'ja'

      store_options = { 'url_pattern' => 'path' }

      store, headers = store_headers_factory(store_options, 'http://favy.co.jp')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('http://favy.co.jp/?user=tom', lang_code, headers)

      assert_equal('http://favy.co.jp/ja/?user=tom', res)
    end

    def test_add_lang_code__jp_domain__path_pattern__absolute_url_with_hash
      lang_code = 'ja'

      store_options = { 'url_pattern' => 'path' }

      store, headers = store_headers_factory(store_options, 'http://favy.co.jp')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('http://favy.co.jp#top', lang_code, headers)

      assert_equal('http://favy.co.jp/ja#top', res)
    end

    def test_add_lang_code__absolute_url_with_default_lang_alias__replaces_lang_code
      lang_aliases = {
        'en' => 'en'
      }

      store_options = { 'url_pattern' => 'path', 'custom_lang_aliases' => lang_aliases }

      store, headers = store_headers_factory(store_options, 'http://www.example.com/th/')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      href_no_trailing_slash = 'http://www.example.com/en'
      href_trailing_slash = 'http://www.example.com/en/'

      assert_equal('http://www.example.com/th', url_lang_switcher.add_lang_code(href_no_trailing_slash, 'th', headers))
      assert_equal('http://www.example.com/th/', url_lang_switcher.add_lang_code(href_trailing_slash, 'th', headers))
    end

    def test_add_lang_code__absolute_path_with_default_lang_alias__replaces_lang_code
      lang_aliases = {
        'en' => 'en'
      }

      store_options = { 'url_pattern' => 'path', 'custom_lang_aliases' => lang_aliases }

      store, headers = store_headers_factory(store_options, 'http://www.example.com/th/')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      href_no_trailing_slash = '/en'
      href_trailing_slash = '/en/'

      assert_equal('/th', url_lang_switcher.add_lang_code(href_no_trailing_slash, 'th', headers))
      assert_equal('/th/', url_lang_switcher.add_lang_code(href_trailing_slash, 'th', headers))
    end

    def test_add_lang_code_with_custom_domain_langs
      custom_domain_langs = {
        'en' => { 'url' => 'my-site.com' },
        'en-US' => { 'url' => 'en-us.my-site.com' },
        'ja' => { 'url' => 'my-site.com/ja' },
        'zh-CHS' => { 'url' => 'my-site.com/zh/chs' },
        'zh-Hant-HK' => { 'url' => 'zh-hant-hk.com/zh' }
      }
      test_cases = [
        # no_lang_url, lang_code, expected_url
        # absolute URL
        ['https://my-site.com', 'en', 'https://my-site.com'],
        ['https://my-site.com', 'ja', 'https://my-site.com/ja'],
        ['https://my-site.com/index.php', 'ja', 'https://my-site.com/ja/index.php'],
        ['https://my-site.com/a/b/', 'ja', 'https://my-site.com/ja/a/b/'],
        ['https://my-site.com/a/b/index.php', 'ja', 'https://my-site.com/ja/a/b/index.php'],
        ['https://my-site.com/index.php', 'en-US', 'https://en-us.my-site.com/index.php'],
        ['https://my-site.com/index.php', 'zh-CHS', 'https://my-site.com/zh/chs/index.php'],
        ['https://my-site.com/index.php', 'zh-Hant-HK', 'https://zh-hant-hk.com/zh/index.php'],
        ['https://my-site.com/index.php?a=1&b=2', 'zh-Hant-HK', 'https://zh-hant-hk.com/zh/index.php?a=1&b=2'],
        ['https://my-site.com/index.php#hash', 'zh-Hant-HK', 'https://zh-hant-hk.com/zh/index.php#hash'],
        ['https://my-site.com/index.php?a=1&b=2#hash', 'zh-Hant-HK', 'https://zh-hant-hk.com/zh/index.php?a=1&b=2#hash'],

        # absolute path
        ['/', 'en', 'http://my-site.com/'],
        ['/', 'ja', 'http://my-site.com/ja/'],
        ['/index.php', 'ja', 'http://my-site.com/ja/index.php'],
        ['/a/b/', 'ja', 'http://my-site.com/ja/a/b/'],
        ['/a/b/index.php', 'ja', 'http://my-site.com/ja/a/b/index.php'],
        ['/index.php', 'en-US', 'http://en-us.my-site.com/index.php'],
        ['/index.php', 'zh-CHS', 'http://my-site.com/zh/chs/index.php'],
        ['/index.php', 'zh-Hant-HK', 'http://zh-hant-hk.com/zh/index.php'],
        ['/index.php?a=1&b=2', 'zh-Hant-HK', 'http://zh-hant-hk.com/zh/index.php?a=1&b=2'],
        ['/index.php#hash', 'zh-Hant-HK', 'http://zh-hant-hk.com/zh/index.php#hash'],
        ['/index.php?a=1&b=2#hash', 'zh-Hant-HK', 'http://zh-hant-hk.com/zh/index.php?a=1&b=2#hash'],

        # relative path
        ['index.php', 'ja', 'http://my-site.com/ja/req_uri/index.php'],
        ['a/b/', 'ja', 'http://my-site.com/ja/req_uri/a/b/'],
        ['a/b/index.php', 'ja', 'http://my-site.com/ja/req_uri/a/b/index.php'],
        ['index.php', 'en-US', 'http://en-us.my-site.com/req_uri/index.php'],
        ['index.php', 'zh-CHS', 'http://my-site.com/zh/chs/req_uri/index.php'],
        ['index.php', 'zh-Hant-HK', 'http://zh-hant-hk.com/zh/req_uri/index.php'],
        ['index.php?a=1&b=2', 'zh-Hant-HK', 'http://zh-hant-hk.com/zh/req_uri/index.php?a=1&b=2'],
        ['index.php#hash', 'zh-Hant-HK', 'http://zh-hant-hk.com/zh/req_uri/index.php#hash'],
        ['index.php?a=1&b=2#hash', 'zh-Hant-HK', 'http://zh-hant-hk.com/zh/req_uri/index.php?a=1&b=2#hash'],
        ['?a=1&b=2', 'zh-Hant-HK', 'http://zh-hant-hk.com/zh/req_uri/?a=1&b=2'],

        # anchor links should not be changed
        ['#hash', 'zh-Hant-HK', '#hash']
      ]

      settings = {
        'project_token' => 'T0k3N',
        'default_lang' => 'en',
        'supported_langs' => ['en'],
        'url_pattern' => 'custom_domain',
        'custom_domain_langs' => custom_domain_langs
      }
      additional_env = {
        'HTTP_HOST' => 'my-site.com',
        'REQUEST_URI' => '/req_uri/'
      }

      test_cases.each do |test_case|
        target_uri, lang, expected_uri = test_case
        store = Wovnrb::Store.instance
        store.update_settings(settings)
        url_lang_switcher = UrlLanguageSwitcher.new(store)
        headers = Wovnrb::Headers.new(
          Wovnrb.get_env(additional_env),
          store.settings,
          url_lang_switcher
        )

        assert_equal(expected_uri, url_lang_switcher.add_lang_code(target_uri, lang, headers))
      end
    end

    def test_remove_lang_query_with_lang_param_name
      settings = Wovnrb.get_settings('url_pattern' => 'query', 'lang_param_name' => 'lang')
      store = Wovnrb.get_store(settings)
      url_lang_switcher = UrlLanguageSwitcher.new(store)

      keys = Wovnrb::Lang::LANG.keys
      assert(!keys.empty?)

      keys.each do |key|
        uri_without_custom_lang_param = "wovn.io/?wovn=#{key}"
        unchanged_uri = url_lang_switcher.remove_lang_from_uri_component(uri_without_custom_lang_param, key)
        assert_equal(uri_without_custom_lang_param, unchanged_uri)

        uri_without_scheme = url_lang_switcher.remove_lang_from_uri_component("wovn.io/?lang=#{key}", key)
        assert_equal('wovn.io/', uri_without_scheme)

        uri_with_scheme = url_lang_switcher.remove_lang_from_uri_component("https://wovn.io?lang=#{key}", key)
        assert_equal('https://wovn.io', uri_with_scheme)
      end
    end

    def test_remove_lang_query_with_nil_lang
      settings = Wovnrb.get_settings('url_pattern' => 'query')
      store = Wovnrb.get_store(settings)
      url_lang_switcher = UrlLanguageSwitcher.new(store)

      keys = Wovnrb::Lang::LANG.keys
      assert(!keys.empty?)

      uri_without_scheme = url_lang_switcher.remove_lang_from_uri_component('wovn.io', nil)
      assert_equal('wovn.io', uri_without_scheme)

      uri_with_scheme = url_lang_switcher.remove_lang_from_uri_component('https://wovn.io/', nil)
      assert_equal('https://wovn.io/', uri_with_scheme)
    end

    def test_remove_lang_query_with_empty_lang
      settings = Wovnrb.get_settings('url_pattern' => 'query')
      store = Wovnrb.get_store(settings)
      url_lang_switcher = UrlLanguageSwitcher.new(store)

      uri_without_scheme = url_lang_switcher.remove_lang_from_uri_component('wovn.io', '')
      assert_equal('wovn.io', uri_without_scheme)

      uri_with_scheme = url_lang_switcher.remove_lang_from_uri_component('https://wovn.io/', '')
      assert_equal('https://wovn.io/', uri_with_scheme)
    end

    def test_remove_lang_subdomain
      settings = Wovnrb.get_settings('url_pattern' => 'subdomain')
      store = Wovnrb.get_store(settings)
      url_lang_switcher = UrlLanguageSwitcher.new(store)

      keys = Wovnrb::Lang::LANG.keys
      assert(!keys.empty?)

      keys.each do |key|
        uri_without_scheme = url_lang_switcher.remove_lang_from_uri_component("#{key.downcase}.wovn.io/", key)
        assert_equal('wovn.io/', uri_without_scheme)

        uri_with_scheme = url_lang_switcher.remove_lang_from_uri_component("https://#{key.downcase}.wovn.io", key)
        assert_equal('https://wovn.io', uri_with_scheme)
      end
    end

    def test_remove_lang_subdomain_with_nil_lang
      settings = Wovnrb.get_settings('url_pattern' => 'subdomain')
      store = Wovnrb.get_store(settings)
      url_lang_switcher = UrlLanguageSwitcher.new(store)
      keys = Wovnrb::Lang::LANG.keys
      assert(!keys.empty?)

      uri_without_scheme = url_lang_switcher.remove_lang_from_uri_component('wovn.io', nil)
      assert_equal('wovn.io', uri_without_scheme)

      uri_with_scheme = url_lang_switcher.remove_lang_from_uri_component('https://wovn.io/', nil)
      assert_equal('https://wovn.io/', uri_with_scheme)
    end

    def test_remove_lang_subdomain_with_empty_lang
      settings = Wovnrb.get_settings('url_pattern' => 'subdomain')
      store = Wovnrb.get_store(settings)
      url_lang_switcher = UrlLanguageSwitcher.new(store)

      uri_without_scheme = url_lang_switcher.remove_lang_from_uri_component('wovn.io', '')
      assert_equal('wovn.io', uri_without_scheme)

      uri_with_scheme = url_lang_switcher.remove_lang_from_uri_component('https://wovn.io/', '')
      assert_equal('https://wovn.io/', uri_with_scheme)
    end

    def test_remove_lang_subdomain_with_custom_lang_alias
      Store.instance.update_settings('custom_lang_aliases' => { 'fr' => 'staging-fr' }, 'url_pattern' => 'subdomain')
      url_lang_switcher = UrlLanguageSwitcher.new(Store.instance)

      uri_without_scheme = url_lang_switcher.remove_lang_from_uri_component('staging-fr.wovn.io/', 'fr')
      assert_equal('wovn.io/', uri_without_scheme)

      uri_with_scheme = url_lang_switcher.remove_lang_from_uri_component('https://staging-fr.wovn.io', 'fr')
      assert_equal('https://wovn.io', uri_with_scheme)
    end

    def test_remove_lang_path
      settings = Wovnrb.get_settings
      store = Wovnrb.get_store(settings)
      sut = UrlLanguageSwitcher.new(store)

      keys = Wovnrb::Lang::LANG.keys
      assert(!keys.empty?)

      keys.each do |key|
        assert_equal('/', sut.remove_lang_from_uri_component("/#{key}", key))
        assert_equal("/dir/#{key}/page.html", sut.remove_lang_from_uri_component("/#{key}/dir/#{key}/page.html", key))
        assert_equal('?query', sut.remove_lang_from_uri_component('?query', key))
        assert_equal('wovn.io/', sut.remove_lang_from_uri_component("wovn.io/#{key}", key))
        assert_equal("wovn.io/dir/#{key}/page.html", sut.remove_lang_from_uri_component("wovn.io/#{key}/dir/#{key}/page.html", key))
        assert_equal("wovn.io:5000/dir/#{key}/page.html", sut.remove_lang_from_uri_component("wovn.io:5000/#{key}/dir/#{key}/page.html", key))
        assert_equal('https://wovn.io/', sut.remove_lang_from_uri_component("https://wovn.io/#{key}/", key))
        assert_equal("https://wovn.io/dir/#{key}/page.html", sut.remove_lang_from_uri_component("https://wovn.io/#{key}/dir/#{key}/page.html", key))
      end
    end

    def test_remove_lang_path_with_nil_lang
      settings = Wovnrb.get_settings
      store = Wovnrb.get_store(settings)
      url_lang_switcher = UrlLanguageSwitcher.new(store)

      keys = Wovnrb::Lang::LANG.keys
      assert(!keys.empty?)

      uri_without_scheme = url_lang_switcher.remove_lang_from_uri_component('wovn.io', nil)
      assert_equal('wovn.io', uri_without_scheme)

      uri_with_scheme = url_lang_switcher.remove_lang_from_uri_component('https://wovn.io/', nil)
      assert_equal('https://wovn.io/', uri_with_scheme)
    end

    def test_remove_lang_path_with_empty_lang
      settings = Wovnrb.get_settings
      store = Wovnrb.get_store(settings)
      url_lang_switcher = UrlLanguageSwitcher.new(store)

      uri_without_scheme = url_lang_switcher.remove_lang_from_uri_component('wovn.io', '')
      assert_equal('wovn.io', uri_without_scheme)

      uri_with_scheme = url_lang_switcher.remove_lang_from_uri_component('https://wovn.io/', '')
      assert_equal('https://wovn.io/', uri_with_scheme)
    end

    def test_remove_lang_custom_domain
      custom_domain_langs = {
        'en' => { 'url' => 'my-site.com' },
        'en-US' => { 'url' => 'en-us.my-site.com' },
        'ja' => { 'url' => 'my-site.com/ja' },
        'zh-CHS' => { 'url' => 'my-site.com/zh/chs' },
        'zh-Hant-HK' => { 'url' => 'zh-hant-hk.com/zh' }
      }
      test_cases = [
        # target_uri, lang, expected_uri, env
        # absolute URL
        ['https://my-site.com', 'en', 'https://my-site.com', {}],
        ['https://my-site.com/ja', 'ja', 'https://my-site.com', { 'REQUEST_URI' => '/ja' }],
        ['https://my-site.com/ja/index.php', 'ja', 'https://my-site.com/index.php', { 'REQUEST_URI' => '/ja/index.php' }],
        ['https://my-site.com/ja/a/b/', 'ja', 'https://my-site.com/a/b/', { 'REQUEST_URI' => '/ja/a/b/' }],
        ['https://my-site.com/ja/a/b/index.php', 'ja', 'https://my-site.com/a/b/index.php', { 'REQUEST_URI' => '/ja/a/b/index.php' }],
        ['https://en-us.my-site.com/index.php', 'en-US', 'https://my-site.com/index.php', { 'HTTP_HOST' => 'en-us.my-site.com', 'SERVER_NAME' => 'en-us.my-site.com', 'REQUEST_URI' => '/index.php' }],
        ['https://my-site.com/zh/chs/index.php', 'zh-CHS', 'https://my-site.com/index.php', { 'REQUEST_URI' => '/zh/chs/index.php' }],
        ['https://zh-hant-hk.com/zh/index.php', 'zh-Hant-HK', 'https://my-site.com/index.php', { 'HTTP_HOST' => 'zh-hant-hk.com', 'SERVER_NAME' => 'zh-hant-hk.com', 'REQUEST_URI' => '/zh/index.php' }],
        ['https://zh-hant-hk.com/zh/index.php?a=1&b=2', 'zh-Hant-HK', 'https://my-site.com/index.php?a=1&b=2', { 'HTTP_HOST' => 'zh-hant-hk.com', 'SERVER_NAME' => 'zh-hant-hk.com', 'REQUEST_URI' => '/zh/index.php' }],
        ['https://zh-hant-hk.com/zh/index.php#hash', 'zh-Hant-HK', 'https://my-site.com/index.php#hash', { 'HTTP_HOST' => 'zh-hant-hk.com', 'SERVER_NAME' => 'zh-hant-hk.com', 'REQUEST_URI' => '/zh/index.php' }],
        ['https://zh-hant-hk.com/zh/index.php?a=1&b=2#hash', 'zh-Hant-HK', 'https://my-site.com/index.php?a=1&b=2#hash', { 'HTTP_HOST' => 'zh-hant-hk.com', 'SERVER_NAME' => 'zh-hant-hk.com', 'REQUEST_URI' => '/zh/index.php' }],

        # absolute path
        ['/', 'en', '/', {}],
        ['/ja/', 'ja', '/', { 'REQUEST_URI' => '/ja' }],
        ['/ja/index.php', 'ja', '/index.php', { 'REQUEST_URI' => '/ja/index.php' }],
        ['/ja/a/b/', 'ja', '/a/b/', { 'REQUEST_URI' => '/ja/a/b/' }],
        ['/ja/a/b/index.php', 'ja', '/a/b/index.php', { 'REQUEST_URI' => '/ja/a/b/index.php' }],
        ['/index.php', 'en-US', '/index.php', { 'HTTP_HOST' => 'en-us.my-site.com', 'SERVER_NAME' => 'en-us.my-site.com', 'REQUEST_URI' => '/index.php' }],
        ['/zh/chs/index.php', 'zh-CHS', '/index.php', { 'REQUEST_URI' => '/zh/chs/index.php' }],
        ['/zh/index.php', 'zh-Hant-HK', '/index.php', { 'HTTP_HOST' => 'zh-hant-hk.com', 'SERVER_NAME' => 'zh-hant-hk.com', 'REQUEST_URI' => '/zh/index.php' }],
        ['/zh/index.php?a=1&b=2', 'zh-Hant-HK', '/index.php?a=1&b=2', { 'HTTP_HOST' => 'zh-hant-hk.com', 'SERVER_NAME' => 'zh-hant-hk.com', 'REQUEST_URI' => '/zh/index.php' }],
        ['/zh/index.php#hash', 'zh-Hant-HK', '/index.php#hash', { 'HTTP_HOST' => 'zh-hant-hk.com', 'SERVER_NAME' => 'zh-hant-hk.com', 'REQUEST_URI' => '/zh/index.php' }],
        ['/zh/index.php?a=1&b=2#hash', 'zh-Hant-HK', '/index.php?a=1&b=2#hash', { 'HTTP_HOST' => 'zh-hant-hk.com', 'SERVER_NAME' => 'zh-hant-hk.com', 'REQUEST_URI' => '/zh/index.php' }],

        # other patterns should not be changed
        ['?a=1&b=2', 'en-US', '?a=1&b=2', { 'HTTP_HOST' => 'en-us.my-site.com', 'SERVER_NAME' => 'en-us.my-site.com', 'REQUEST_URI' => '/' }],
        ['#hash', 'en-US', '#hash', { 'HTTP_HOST' => 'en-us.my-site.com', 'SERVER_NAME' => 'en-us.my-site.com', 'REQUEST_URI' => '/' }]
      ]

      settings = {
        'project_token' => 'T0k3N',
        'default_lang' => 'en',
        'supported_langs' => %w[en en-US ja zh-CHS zh-Hant-HK],
        'url_pattern' => 'custom_domain',
        'custom_domain_langs' => custom_domain_langs
      }
      base_env = {
        'HTTP_HOST' => 'my-site.com',
        'REQUEST_URI' => '/req_uri/'
      }

      test_cases.each do |test_case|
        target_uri, lang, expected_uri, env = test_case
        additional_env = base_env.merge(env)
        store = Wovnrb::Store.instance
        store.update_settings(settings)
        url_lang_switcher = UrlLanguageSwitcher.new(store)
        headers = Wovnrb::Headers.new(
          Wovnrb.get_env(additional_env),
          store.settings,
          url_lang_switcher
        )

        assert_equal(expected_uri, url_lang_switcher.remove_lang_from_uri_component(target_uri, lang, headers))
      end
    end

    def store_headers_factory(setting_opts = {}, url = 'http://my-site.com')
      settings = default_store_settings.merge(setting_opts)
      store = Wovnrb::Store.instance
      store.update_settings(settings)
      url_lang_switcher = UrlLanguageSwitcher.new(store)

      headers = Wovnrb::Headers.new(
        Wovnrb.get_env('url' => url),
        store.settings,
        url_lang_switcher
      )

      [store, headers]
    end

    def default_store_settings
      {
        'project_token' => '123456',
        'custom_lang_aliases' => {},
        'default_lang' => 'en',
        'url_pattern' => 'query',
        'url_pattern_reg' => '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|)',
        'supported_langs' => %w[en fr ja vi]
      }
    end
  end
end
