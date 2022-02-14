require 'test_helper'

module Wovnrb
  class UrlLanguageSwitcherTest < WovnMiniTest
    def test_add_lang_code
      lang_code = 'zh-cht'
      store_options = { 'url_pattern' => 'subdomain' }

      store, headers = store_headers_factory(store_options, url = 'http://favy.tips')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('http://www.facebook.com', lang_code, headers)

      assert_equal('http://www.facebook.com', res)
    end

    def test_add_lang_code_relative_slash_href_url_with_path
      lang_code = 'fr'

      store_options = { 'url_pattern' => 'subdomain' }

      store, headers = store_headers_factory(store_options, url = 'http://favy.tips/topics/44')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('/topics/50', lang_code, headers)

      assert_equal('http://fr.favy.tips/topics/50', res)
    end

    def test_add_lang_code_relative_dot_href_url_with_path
      lang_code = 'fr'

      store_options = { 'url_pattern' => 'subdomain' }

      store, headers = store_headers_factory(store_options, url = 'http://favy.tips/topics/44')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('./topics/50', lang_code, headers)

      assert_equal('http://fr.favy.tips/topics/topics/50', res)
    end

    def test_add_lang_code_relative_two_dots_href_url_with_path
      lang_code = 'fr'

      store_options = { 'url_pattern' => 'subdomain' }

      store, headers = store_headers_factory(store_options, url = 'http://favy.tips/topics/44')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('../topics/50', lang_code, headers)

      assert_equal('http://fr.favy.tips/topics/50', res)
    end

    def test_add_lang_code_trad_chinese
      lang_code = 'zh-cht'

      store_options = { 'url_pattern' => 'subdomain' }

      store, headers = store_headers_factory(store_options, url = 'http://favy.tips')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('http://favy.tips/topics/31', lang_code, headers)

      assert_equal('http://zh-cht.favy.tips/topics/31', res)
    end

    def test_add_lang_code_trad_chinese_2
      lang_code = 'zh-cht'

      store_options = { 'url_pattern' => 'subdomain' }

      store, headers = store_headers_factory(store_options, url = 'http://favy.tips')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('/topics/31', lang_code, headers)

      assert_equal('http://zh-cht.favy.tips/topics/31', res)
    end

    def test_add_lang_code_trad_chinese_lang_in_link_already
      lang_code = 'zh-cht'

      store_options = { 'url_pattern' => 'subdomain' }

      store, headers = store_headers_factory(store_options, url = 'http://favy.tips')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('http://zh-cht.favy.tips/topics/31', lang_code, headers)

      assert_equal('http://zh-cht.favy.tips/topics/31', res)
    end

    def test_add_lang_code_no_protocol
      lang_code = 'zh-cht'

      store_options = { 'url_pattern' => 'subdomain' }

      store, headers = store_headers_factory(store_options, url = 'https://google.com')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('//google.com', lang_code, headers)

      assert_equal('//zh-cht.google.com', res)
    end

    def test_add_lang_code_no_protocol_2
      lang_code = 'zh-cht'

      store_options = { 'url_pattern' => 'subdomain' }

      store, headers = store_headers_factory(store_options, url = 'https://favy.tips')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('//google.com', lang_code, headers)

      assert_equal('//google.com', res)
    end

    def test_add_lang_code_invalid_url
      lang_code = 'zh-cht'
      store_options = { 'url_pattern' => 'subdomain' }

      store, headers = store_headers_factory(store_options, url = 'https://favy.tips')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('http://www.facebook.com/sharer.php?u=http://favy.tips/topics/50&amp;amp;t=Gourmet Tofu World: Vegetarian-Friendly Japanese Food is Here!', lang_code, headers)

      assert_equal('http://www.facebook.com/sharer.php?u=http://favy.tips/topics/50&amp;amp;t=Gourmet Tofu World: Vegetarian-Friendly Japanese Food is Here!', res)
    end

    def test_add_lang_code_path_only_with_slash
      lang_code = 'zh-cht'

      store_options = { 'url_pattern' => 'subdomain' }

      store, headers = store_headers_factory(store_options, url = 'http://favy.tips')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('/topics/31', lang_code, headers)

      assert_equal('http://zh-cht.favy.tips/topics/31', res)
    end

    def test_add_lang_code_path_only_no_slash
      lang_code = 'zh-cht'
      store_options = { 'url_pattern' => 'subdomain' }

      store, headers = store_headers_factory(store_options, url = 'http://favy.tips')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('topics/31', lang_code, headers)

      assert_equal('http://zh-cht.favy.tips/topics/31', res)
    end

    def test_add_lang_code_path_explicit_page_no_slash
      lang_code = 'zh-cht'

      store_options = { 'url_pattern' => 'subdomain' }

      store, headers = store_headers_factory(store_options, url = 'http://favy.tips')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('topics/31.html', lang_code, headers)

      assert_equal('http://zh-cht.favy.tips/topics/31.html', res)
    end

    def test_add_lang_code_path_explicit_page_with_slash
      lang_code = 'zh-cht'

      store_options = { 'url_pattern' => 'subdomain' }

      store, headers = store_headers_factory(store_options, url = 'http://favy.tips')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('/topics/31.html', lang_code, headers)

      assert_equal('http://zh-cht.favy.tips/topics/31.html', res)
    end

    def test_add_lang_code_no_protocol_with_path_explicit_page
      lang_code = 'zh-cht'

      store_options = { 'url_pattern' => 'subdomain' }

      store, headers = store_headers_factory(store_options, url = 'http://favy.tips')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('//www.google.com/topics/31.php', lang_code, headers)

      assert_equal('//www.google.com/topics/31.php', res)
    end

    def test_add_lang_code_protocol_with_path_explicit_page
      lang_code = 'zh-cht'

      store_options = { 'url_pattern' => 'subdomain' }

      store, headers = store_headers_factory(store_options, url = 'http://favy.tips')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('http://www.google.com/topics/31.php', lang_code, headers)

      assert_equal('http://www.google.com/topics/31.php', res)
    end

    def test_add_lang_code_relative_path_double_period
      lang_code = 'zh-cht'

      store_options = { 'url_pattern' => 'subdomain' }

      store, headers = store_headers_factory(store_options, url = 'http://favy.tips')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('../topics/31', lang_code, headers)

      assert_equal('http://zh-cht.favy.tips/topics/31', res)
    end

    def test_add_lang_code_relative_path_single_period
      lang_code = 'zh-cht'

      store_options = { 'url_pattern' => 'subdomain' }

      store, headers = store_headers_factory(store_options, url = 'http://favy.tips')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('./topics/31', lang_code, headers)

      assert_equal('http://zh-cht.favy.tips/topics/31', res)
    end

    def test_add_lang_code_empty_href
      lang_code = 'zh-cht'

      store_options = { 'url_pattern' => 'subdomain' }

      store, headers = store_headers_factory(store_options, url = 'http://favy.tips')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('', lang_code, headers)

      assert_equal('', res)
    end

    def test_add_lang_code_hash_href
      lang_code = 'zh-cht'

      store_options = { 'url_pattern' => 'subdomain' }

      store, headers = store_headers_factory(store_options, url = 'http://favy.tips')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('#', lang_code, headers)

      assert_equal('#', res)
    end

    def test_add_lang_code_nil_href
      lang_code = 'en'
      store_options = { 'url_pattern' => 'subdomain' }

      store, headers = store_headers_factory(store_options, url = 'http://favy.tips')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code(nil, lang_code, headers)

      assert_nil(res)
    end

    def test_add_lang_code_absolute_different_host
      lang_code = 'fr'
      store_options = { 'url_pattern' => 'subdomain' }

      store, headers = store_headers_factory(store_options, url = 'http://google.com')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('http://yahoo.co.jp', lang_code, headers)

      assert_equal('http://yahoo.co.jp', res)
    end

    def test_add_lang_code_absolute_subdomain_no_subdomain
      lang_code = 'fr'
      store_options = { 'url_pattern' => 'subdomain' }

      store, headers = store_headers_factory(store_options, url = 'http://google.com')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('http://google.com', lang_code, headers)

      assert_equal('http://fr.google.com', res)
    end

    def test_add_lang_code_absolute_subdomain_with_subdomain
      lang_code = 'fr'

      store_options = { 'url_pattern' => 'subdomain' }

      store, headers = store_headers_factory(store_options, url = 'http://home.google.com')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('http://home.google.com', lang_code, headers)

      assert_equal('http://fr.home.google.com', res)
    end

    def test_add_lang_code_absolute_query_no_query
      lang_code = 'fr'

      store_options = { 'url_pattern' => 'query' }

      store, headers = store_headers_factory(store_options, url = 'http://google.com')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('http://google.com', lang_code, headers)

      assert_equal('http://google.com?wovn=fr', res)
    end

    def test_add_lang_code_absolute_query_with_query
      lang_code = 'fr'

      store_options = { 'url_pattern' => 'query' }

      store, headers = store_headers_factory(store_options, url = 'http://google.com')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('http://google.com?hey=yo', lang_code, headers)

      assert_equal('http://google.com?hey=yo&wovn=fr', res)
    end

    def test_add_lang_code_absolute_query_with_hash
      lang_code = 'fr'

      store_options = { 'url_pattern' => 'query' }

      store, headers = store_headers_factory(store_options, url = 'http://google.com')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('http://google.com#test', lang_code, headers)

      assert_equal('http://google.com?wovn=fr#test', res)
    end

    def test_add_lang_code_absolute_query_and_lang_param_name_with_no_query
      lang_code = 'fr'

      store_options = { 'url_pattern' => 'query', 'lang_param_name' => 'test_param' }

      store, headers = store_headers_factory(store_options, url = 'http://google.com')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('http://google.com', lang_code, headers)

      assert_equal('http://google.com?test_param=fr', res)
    end

    def test_add_lang_code_absolute_query_and_lang_param_name_with_query
      lang_code = 'fr'

      store_options = { 'url_pattern' => 'query', 'lang_param_name' => 'test_param' }

      store, headers = store_headers_factory(store_options, url = 'http://google.com')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('http://google.com?hey=yo', lang_code, headers)

      assert_equal('http://google.com?hey=yo&test_param=fr', res)
    end

    def test_add_lang_code_absolute_query_and_lang_param_name_with_hash
      lang_code = 'fr'

      store_options = { 'url_pattern' => 'query', 'lang_param_name' => 'test_param' }

      store, headers = store_headers_factory(store_options, url = 'http://google.com')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('http://google.com#test', lang_code, headers)

      assert_equal('http://google.com?test_param=fr#test', res)
    end

    def test_add_lang_code_absolute_path_no_pathname
      lang_code = 'fr'

      store_options = { 'url_pattern' => 'path' }

      store, headers = store_headers_factory(store_options, url = 'http://google.com')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('http://google.com', lang_code, headers)

      assert_equal('http://google.com/fr', res)
    end

    def test_add_lang_code__requested_with_deep_path
      lang_code = 'fr'

      store_options = { 'url_pattern' => 'path' }

      store, headers = store_headers_factory(store_options, url = 'http://google.com/dir1/dir2')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      assert_equal('http://google.com/fr', url_lang_switcher.add_lang_code('http://google.com', lang_code, headers))
      assert_equal('/fr/', url_lang_switcher.add_lang_code('/', lang_code, headers))
      assert_equal('', url_lang_switcher.add_lang_code('', lang_code, headers))
    end

    def test_add_lang_code_absolute_path_with_pathname
      lang_code = 'fr'

      store_options = { 'url_pattern' => 'path' }

      store, headers = store_headers_factory(store_options, url = 'http://google.com')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('http://google.com/index.html', lang_code, headers)

      assert_equal('http://google.com/fr/index.html', res)
    end

    def test_add_lang_code_absolute_path_with_pathname_hash_is_preserved
      lang_code = 'fr'

      store_options = { 'url_pattern' => 'path' }

      store, headers = store_headers_factory(store_options, url = 'http://google.com')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('http://google.com/index.html?foo=bar#hash', lang_code, headers)

      assert_equal('http://google.com/fr/index.html?foo=bar#hash', res)
    end

    def test_add_lang_code_absolute_path_with_long_pathname
      lang_code = 'fr'

      store_options = { 'url_pattern' => 'path' }

      store, headers = store_headers_factory(store_options, url = 'http://google.com')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('http://google.com/hello/long/path/index.html', lang_code, headers)

      assert_equal('http://google.com/fr/hello/long/path/index.html', res)
    end

    def test_add_lang_code_relative_subdomain_leading_slash
      lang_code = 'fr'

      store_options = { 'url_pattern' => 'subdomain' }

      store, headers = store_headers_factory(store_options, url = 'http://google.com')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('/', lang_code, headers)

      assert_equal('http://fr.google.com/', res)
    end

    def test_add_lang_code_relative_subdomain_leading_slash_filename
      lang_code = 'fr'

      store_options = { 'url_pattern' => 'subdomain' }

      store, headers = store_headers_factory(store_options, url = 'http://google.com')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('/index.html', lang_code, headers)

      assert_equal('http://fr.google.com/index.html', res)
    end

    def test_add_lang_code_relative_subdomain_no_leading_slash_filename
      lang_code = 'fr'

      store_options = { 'url_pattern' => 'subdomain' }

      store, headers = store_headers_factory(store_options, url = 'http://google.com')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('index.html', lang_code, headers)

      assert_equal('http://fr.google.com/index.html', res)
    end

    def test_add_lang_code_relative_query_with_no_query
      lang_code = 'fr'

      store_options = { 'url_pattern' => 'query' }

      store, headers = store_headers_factory(store_options, url = 'http://google.com')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('/index.html', lang_code, headers)

      assert_equal('/index.html?wovn=fr', res)
    end

    def test_add_lang_code_relative_query_with_query
      lang_code = 'fr'

      store_options = { 'url_pattern' => 'query' }

      store, headers = store_headers_factory(store_options, url = 'http://google.com')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('/index.html?hey=yo', lang_code, headers)

      assert_equal('/index.html?hey=yo&wovn=fr', res)
    end

    def test_add_lang_code_relative_query_with_hash
      lang_code = 'fr'

      store_options = { 'url_pattern' => 'query' }

      store, headers = store_headers_factory(store_options, url = 'http://google.com')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('/index.html?hey=yo', lang_code, headers)

      assert_equal('/index.html?hey=yo&wovn=fr', res)
    end

    def test_add_lang_code_relative_query_and_lang_param_name_with_no_query
      lang_code = 'fr'

      store_options = { 'url_pattern' => 'query', 'lang_param_name' => 'test_param' }

      store, headers = store_headers_factory(store_options, url = 'http://google.com')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('/index.html', lang_code, headers)

      assert_equal('/index.html?test_param=fr', res)
    end

    def test_add_lang_code_relative_query_and_lang_param_name_with_query
      lang_code = 'fr'

      store_options = { 'url_pattern' => 'query', 'lang_param_name' => 'test_param' }

      store, headers = store_headers_factory(store_options, url = 'http://google.com')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('/index.html?hey=yo', lang_code, headers)

      assert_equal('/index.html?hey=yo&test_param=fr', res)
    end

    def test_add_lang_code_relative_query_and_lang_param_name_with_hash
      lang_code = 'fr'

      store_options = { 'url_pattern' => 'query', 'lang_param_name' => 'test_param' }

      store, headers = store_headers_factory(store_options, url = 'http://google.com')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('/index.html?hey=yo#hey', lang_code, headers)

      assert_equal('/index.html?hey=yo&test_param=fr#hey', res)
    end

    def test_add_lang_code_relative_path_with_leading_slash
      lang_code = 'fr'

      store_options = { 'url_pattern' => 'path' }

      store, headers = store_headers_factory(store_options, url = 'http://google.com')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('/index.html', lang_code, headers)

      assert_equal('/fr/index.html', res)
    end

    def test_add_lang_code_relative_path_without_leading_slash_different_pathname
      lang_code = 'fr'

      store_options = { 'url_pattern' => 'path' }

      store, headers = store_headers_factory(store_options, url = 'http://google.com/hello/tab.html')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('index.html', lang_code, headers)

      assert_equal('/fr/hello/index.html', res)
    end

    def test_add_lang_code_relative_path_without_leading_slash_and_dot_dot
      lang_code = 'fr'

      store_options = { 'url_pattern' => 'path' }

      store, headers = store_headers_factory(store_options, url = 'https://pre.avex.jp/wovn_aaa/news/')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('../news/', lang_code, headers)

      assert_equal("/#{lang_code}/wovn_aaa/news/", res)
    end

    def test_add_lang_code_relative_path_without_leading_slash_different_pathname2
      lang_code = 'fr'

      store_options = { 'url_pattern' => 'path' }

      store, headers = store_headers_factory(store_options, url = 'http://google.com/hello/tab.html')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('hey/index.html', lang_code, headers)

      assert_equal('/fr/hello/hey/index.html', res)
    end

    def test_add_lang_code_relative_path_at_root
      lang_code = 'fr'

      store_options = { 'url_pattern' => 'path' }

      store, headers = store_headers_factory(store_options, url = 'http://google.com/')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('index.html', lang_code, headers)

      assert_equal('/fr/index.html', res)
    end

    def test_add_lang_code__jp_domain__path_pattern__absolute_path
      lang_code = 'ja'

      store_options = { 'url_pattern' => 'path' }

      store, headers = store_headers_factory(store_options, url = 'http://favy.co.jp')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('/page', lang_code, headers)

      assert_equal('/ja/page', res)
    end

    def test_add_lang_code__jp_domain__path_pattern__absolute_path_with_query
      lang_code = 'ja'

      store_options = { 'url_pattern' => 'path' }

      store, headers = store_headers_factory(store_options, url = 'http://favy.co.jp')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('/page?user=tom', lang_code, headers)

      assert_equal('/ja/page?user=tom', res)
    end

    def test_add_lang_code__jp_domain__path_pattern__absolute_path_with_query__top_page
      lang_code = 'ja'

      store_options = { 'url_pattern' => 'path' }

      store, headers = store_headers_factory(store_options, url = 'http://favy.co.jp')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('/?user=tom', lang_code, headers)

      assert_equal('/ja/?user=tom', res)
    end

    def test_add_lang_code__jp_domain__path_pattern__absolute_path_with_hash__top_page
      lang_code = 'ja'

      store_options = { 'url_pattern' => 'path' }

      store, headers = store_headers_factory(store_options, url = 'http://favy.co.jp')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('/#top', lang_code, headers)

      assert_equal('/ja/#top', res)
    end

    def test_add_lang_code__jp_domain__path_pattern__absolute_url
      lang_code = 'ja'

      store_options = { 'url_pattern' => 'path' }

      store, headers = store_headers_factory(store_options, url = 'http://favy.co.jp')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('http://favy.co.jp/page', lang_code, headers)

      assert_equal('http://favy.co.jp/ja/page', res)
    end

    def test_add_lang_code__jp_domain__path_pattern__absolute_url_with_query
      lang_code = 'ja'

      store_options = { 'url_pattern' => 'path' }

      store, headers = store_headers_factory(store_options, url = 'http://favy.co.jp')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('http://favy.co.jp?user=tom', lang_code, headers)

      assert_equal('http://favy.co.jp/ja?user=tom', res)
    end

    def test_add_lang_code__jp_domain__path_pattern__absolute_url_with_trailing_slash_and_query
      lang_code = 'ja'

      store_options = { 'url_pattern' => 'path' }

      store, headers = store_headers_factory(store_options, url = 'http://favy.co.jp')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('http://favy.co.jp/?user=tom', lang_code, headers)

      assert_equal('http://favy.co.jp/ja/?user=tom', res)
    end

    def test_add_lang_code__jp_domain__path_pattern__absolute_url_with_hash
      lang_code = 'ja'

      store_options = { 'url_pattern' => 'path' }

      store, headers = store_headers_factory(store_options, url = 'http://favy.co.jp')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      res = url_lang_switcher.add_lang_code('http://favy.co.jp#top', lang_code, headers)

      assert_equal('http://favy.co.jp/ja#top', res)
    end

    def test_add_lang_code__absolute_url_with_default_lang_alias__replaces_lang_code
      lang_aliases = {
        'en' => 'en'
      }

      store_options = { 'url_pattern' => 'path', 'custom_lang_aliases' => lang_aliases }

      store, headers = store_headers_factory(store_options, url = 'http://www.example.com/th/')
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

      store, headers = store_headers_factory(store_options, url = 'http://www.example.com/th/')
      url_lang_switcher = Wovnrb::UrlLanguageSwitcher.new(store)

      href_no_trailing_slash = '/en'
      href_trailing_slash = '/en/'

      assert_equal('/th', url_lang_switcher.add_lang_code(href_no_trailing_slash, 'th', headers))
      assert_equal('/th/', url_lang_switcher.add_lang_code(href_trailing_slash, 'th', headers))
    end

    def store_headers_factory(setting_opts = {}, url = 'http://my-site.com')
      settings = default_store_settings.merge(setting_opts)
      store = Wovnrb::Store.instance
      store.update_settings(settings)

      headers = Wovnrb::Headers.new(
        Wovnrb.get_env('url' => url),
        store.settings
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
