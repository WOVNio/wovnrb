require 'wovnrb'
require 'wovnrb/headers'
require 'minitest/autorun'
require 'pry'

class WovnrbTest < Minitest::Test

  def get_app
  end


  def test_initialize
    i = Wovnrb::Interceptor.new(get_app)
    refute_nil(i)
  end


  # def test_call(env)
  # end


  # def test_switch_lang(body, values, url, lang=STORE.settings['default_lang'], headers)
  # end


  # def test_get_langs(values)
  # end

  def test_add_lang_code
    i = Wovnrb::Interceptor.new(get_app)
    h = Wovnrb::Headers.new(get_env('url' => 'http://favy.tips'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal("http://www.facebook.com", i.add_lang_code("http://www.facebook.com", 'subdomain', 'zh-cht', h))
  end

  def test_add_lang_code_relative_slash_href_url_with_path
    i = Wovnrb::Interceptor.new(get_app)
    h = Wovnrb::Headers.new(get_env('url' => 'http://fr.favy.tips/topics/44'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal("http://fr.favy.tips/topics/50", i.add_lang_code("/topics/50", 'subdomain', 'fr', h))
  end

  def test_add_lang_code_relative_dot_href_url_with_path
    i = Wovnrb::Interceptor.new(get_app)
    h = Wovnrb::Headers.new(get_env('url' => 'http://fr.favy.tips/topics/44'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal("http://fr.favy.tips/topics/44/topics/50", i.add_lang_code("./topics/50", 'subdomain', 'fr', h))
  end

  def test_add_lang_code_relative_two_dots_href_url_with_path
    i = Wovnrb::Interceptor.new(get_app)
    h = Wovnrb::Headers.new(get_env('url' => 'http://fr.favy.tips/topics/44'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal("http://fr.favy.tips/topics/50", i.add_lang_code("../topics/50", 'subdomain', 'fr', h))
  end

  def test_add_lang_code_trad_chinese
    i = Wovnrb::Interceptor.new(get_app)
    h = Wovnrb::Headers.new(get_env('url' => 'http://favy.tips'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal("http://zh-cht.favy.tips/topics/31", i.add_lang_code("http://favy.tips/topics/31", 'subdomain', 'zh-cht', h))
  end

  def test_add_lang_code_trad_chinese_2
    i = Wovnrb::Interceptor.new(get_app)
    h = Wovnrb::Headers.new(get_env('url' => 'http://zh-cht.favy.tips'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal("http://zh-cht.favy.tips/topics/31", i.add_lang_code("/topics/31", 'subdomain', 'zh-cht', h))
  end

  def test_add_lang_code_trad_chinese_lang_in_link_already
    i = Wovnrb::Interceptor.new(get_app)
    h = Wovnrb::Headers.new(get_env('url' => 'http://zh-cht.favy.tips'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal("http://zh-cht.favy.tips/topics/31", i.add_lang_code("http://zh-cht.favy.tips/topics/31", 'subdomain', 'zh-cht', h))
  end

  def test_add_lang_code_no_protocol
    i = Wovnrb::Interceptor.new(get_app)
    h = Wovnrb::Headers.new(get_env('url' => 'https://zh-cht.google.com'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal("//zh-cht.google.com", i.add_lang_code("//google.com", 'subdomain', 'zh-cht', h))
  end

  def test_add_lang_code_no_protocol_2
    i = Wovnrb::Interceptor.new(get_app)
    h = Wovnrb::Headers.new(get_env('url' => 'https://zh-cht.favy.tips'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal("//google.com", i.add_lang_code("//google.com", 'subdomain', 'zh-cht', h))
  end

  def test_add_lang_code_invalid_url
    i = Wovnrb::Interceptor.new(get_app)
    h = Wovnrb::Headers.new(get_env('url' => 'http://favy.tips'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal("http://www.facebook.com/sharer.php?u=http://favy.tips/topics/50&amp;amp;t=Gourmet Tofu World: Vegetarian-Friendly Japanese Food is Here!", i.add_lang_code("http://www.facebook.com/sharer.php?u=http://favy.tips/topics/50&amp;amp;t=Gourmet Tofu World: Vegetarian-Friendly Japanese Food is Here!", 'subdomain', 'zh-cht', h))
  end

  def test_add_lang_code_path_only_with_slash
    i = Wovnrb::Interceptor.new(get_app)
    h = Wovnrb::Headers.new(get_env('url' => 'http://favy.tips'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal("http://zh-cht.favy.tips/topics/31", i.add_lang_code("/topics/31", 'subdomain', 'zh-cht', h))
  end

  def test_add_lang_code_path_only_no_slash
    i = Wovnrb::Interceptor.new(get_app)
    h = Wovnrb::Headers.new(get_env('url' => 'http://favy.tips'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal("http://zh-cht.favy.tips/topics/31", i.add_lang_code("topics/31", 'subdomain', 'zh-cht', h))
  end

  def test_add_lang_code_path_explicit_page_no_slash
    i = Wovnrb::Interceptor.new(get_app)
    h = Wovnrb::Headers.new(get_env('url' => 'http://favy.tips'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal("http://zh-cht.favy.tips/topics/31.html", i.add_lang_code("topics/31.html", 'subdomain', 'zh-cht', h))
  end

  def test_add_lang_code_path_explicit_page_with_slash
    i = Wovnrb::Interceptor.new(get_app)
    h = Wovnrb::Headers.new(get_env('url' => 'http://favy.tips'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal("http://zh-cht.favy.tips/topics/31.html", i.add_lang_code("/topics/31.html", 'subdomain', 'zh-cht', h))
  end

  def test_add_lang_code_no_protocol_with_path_explicit_page
    i = Wovnrb::Interceptor.new(get_app)
    h = Wovnrb::Headers.new(get_env('url' => 'http://favy.tips'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal("//www.google.com/topics/31.php", i.add_lang_code("//www.google.com/topics/31.php", 'subdomain', 'zh-cht', h))
  end

  def test_add_lang_code_protocol_with_path_explicit_page
    i = Wovnrb::Interceptor.new(get_app)
    h = Wovnrb::Headers.new(get_env('url' => 'http://favy.tips'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal("http://www.google.com/topics/31.php", i.add_lang_code("http://www.google.com/topics/31.php", 'subdomain', 'zh-cht', h))
  end

  def test_add_lang_code_relative_path_double_period
    i = Wovnrb::Interceptor.new(get_app)
    h = Wovnrb::Headers.new(get_env('url' => 'http://favy.tips'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal("http://zh-cht.favy.tips/topics/31", i.add_lang_code("../topics/31", 'subdomain', 'zh-cht', h))
  end

  def test_add_lang_code_relative_path_single_period
    i = Wovnrb::Interceptor.new(get_app)
    h = Wovnrb::Headers.new(get_env('url' => 'http://favy.tips'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal("http://zh-cht.favy.tips/topics/31", i.add_lang_code("./topics/31", 'subdomain', 'zh-cht', h))
  end

  def test_add_lang_code_empty_href
    i = Wovnrb::Interceptor.new(get_app)
    h = Wovnrb::Headers.new(get_env('url' => 'http://favy.tips'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal("", i.add_lang_code("", 'subdomain', 'zh-cht', h))
  end

  def test_add_lang_code_hash_href
    i = Wovnrb::Interceptor.new(get_app)
    h = Wovnrb::Headers.new(get_env('url' => 'http://favy.tips'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    assert_equal("#", i.add_lang_code("#", 'subdomain', 'zh-cht', h))
  end

  #  def test_add_lang_code_nil_href
  #    i = Wovnrb::Interceptor.new(get_app)
  #    assert_equal(nil, i.add_lang_code(nil,'path', 'en', nil))
  #  end
  #  def test_add_lang_code_absolute_different_host
  #    i = Wovnrb::Interceptor.new(get_app)
  #    headers = stub
  #    headers.expects(:host).returns('google.com')
  #    assert_equal('http://yahoo.co.jp', i.add_lang_code('http://yahoo.co.jp', 'path', 'fr', headers))
  #  end
  #
  #  def test_add_lang_code_absolute_subdomain_no_subdomain
  #    i = Wovnrb::Interceptor.new(get_app)
  #    headers = stub
  #    headers.expects(:host).returns('google.com')
  #    assert_equal('http://fr.google.com', i.add_lang_code('http://google.com', 'subdomain', 'fr', headers))
  #  end
  #
  #  def test_add_lang_code_absolute_subdomain_with_subdomain
  #    i = Wovnrb::Interceptor.new(get_app)
  #    headers = stub
  #    headers.expects(:host).returns('home.google.com')
  #    assert_equal('http://fr.home.google.com', i.add_lang_code('http://home.google.com', 'subdomain', 'fr', headers))
  #  end
  #
  #  def test_add_lang_code_absolute_query_no_query
  #    i = Wovnrb::Interceptor.new(get_app)
  #    headers = stub
  #    headers.expects(:host).returns('google.com')
  #    assert_equal('http://google.com?wovn=fr', i.add_lang_code('http://google.com', 'query', 'fr', headers))
  #  end
  #
  #  def test_add_lang_code_absolute_query_with_query
  #    i = Wovnrb::Interceptor.new(get_app)
  #    headers = stub
  #    headers.expects(:host).returns('google.com')
  #    assert_equal('http://google.com?hey=yo&wovn=fr', i.add_lang_code('http://google.com?hey=yo', 'query', 'fr', headers))
  #  end
  #
  #  def test_add_lang_code_absolute_path_no_pathname
  #    i = Wovnrb::Interceptor.new(get_app)
  #    headers = stub
  #    headers.expects(:host).returns('google.com')
  #    assert_equal('http://google.com/fr/', i.add_lang_code('http://google.com', 'path', 'fr', headers))
  #  end
  #
  #  def test_add_lang_code_absolute_path_with_pathname
  #    i = Wovnrb::Interceptor.new(get_app)
  #    headers = stub
  #    headers.expects(:host).returns('google.com')
  #    assert_equal('http://google.com/fr/index.html', i.add_lang_code('http://google.com/index.html', 'path', 'fr', headers))
  #  end
  #
  #  def test_add_lang_code_absolute_path_with_long_pathname
  #    i = Wovnrb::Interceptor.new(get_app)
  #    headers = stub
  #    headers.expects(:host).returns('google.com')
  #    assert_equal('http://google.com/fr/hello/long/path/index.html', i.add_lang_code('http://google.com/hello/long/path/index.html', 'path', 'fr', headers))
  #  end
  #
  #  def test_add_lang_code_relative_subdomain_leading_slash
  #    i = Wovnrb::Interceptor.new(get_app)
  #    headers = stub
  #    headers.expects(:protocol).returns('http')
  #    headers.expects(:host).returns('google.com')
  #    assert_equal('http://fr.google.com/', i.add_lang_code('/', 'subdomain', 'fr', headers))
  #  end
  #
  #  def test_add_lang_code_relative_subdomain_leading_slash_filename
  #    i = Wovnrb::Interceptor.new(get_app)
  #    headers = stub
  #    headers.expects(:protocol).returns('http')
  #    headers.expects(:host).returns('google.com')
  #    assert_equal('http://fr.google.com/index.html', i.add_lang_code('/index.html', 'subdomain', 'fr', headers))
  #  end
  #
  #  def test_add_lang_code_relative_subdomain_no_leading_slash_filename
  #    i = Wovnrb::Interceptor.new(get_app)
  #    headers = stub
  #    headers.expects(:protocol).returns('http')
  #    headers.expects(:host).returns('google.com')
  #    headers.expects(:pathname).returns('/')
  #    assert_equal('http://fr.google.com/index.html', i.add_lang_code('index.html', 'subdomain', 'fr', headers))
  #  end
  #
  #  def test_add_lang_code_relative_subdomain_dot_filename
  #    i = Wovnrb::Interceptor.new(get_app)
  #    headers = stub
  #    headers.expects(:protocol).returns('http')
  #    headers.expects(:host).returns('google.com')
  #    headers.expects(:pathname).returns('/')
  #    assert_equal('http://fr.google.com/./index.html', i.add_lang_code('./index.html', 'subdomain', 'fr', headers))
  #  end
  #
  #  def test_add_lang_code_relative_subdomain_two_dots_filename_long_pathname
  #    i = Wovnrb::Interceptor.new(get_app)
  #    headers = stub
  #    headers.expects(:protocol).returns('http')
  #    headers.expects(:host).returns('google.com')
  #    headers.expects(:pathname).returns('/home/hey/index.html')
  #    assert_equal('http://fr.google.com/home/hey/../index.html', i.add_lang_code('../index.html', 'subdomain', 'fr', headers))
  #  end
  #
  #  def test_add_lang_code_relative_query_with_no_query
  #    i = Wovnrb::Interceptor.new(get_app)
  #    headers = stub
  #    assert_equal('/index.html?wovn=fr', i.add_lang_code('/index.html', 'query', 'fr', headers))
  #  end
  #
  #  def test_add_lang_code_relative_query_with_query
  #    i = Wovnrb::Interceptor.new(get_app)
  #    headers = stub
  #    assert_equal('/index.html?hey=yo&wovn=fr', i.add_lang_code('/index.html?hey=yo', 'query', 'fr', headers))
  #  end
  #
  #  def test_add_lang_code_relative_path_with_leading_slash
  #    i = Wovnrb::Interceptor.new(get_app)
  #    headers = stub
  #    assert_equal('/fr/index.html', i.add_lang_code('/index.html', 'path', 'fr', headers))
  #  end
  #
  #  def test_add_lang_code_relative_path_without_leading_slash_different_pathname
  #    i = Wovnrb::Interceptor.new(get_app)
  #    headers = stub
  #    headers.expects(:pathname).returns('/hello/tab.html')
  #    assert_equal('/fr/hello/index.html', i.add_lang_code('index.html', 'path', 'fr', headers))
  #  end
  #
  #  def test_add_lang_code_relative_path_without_leading_slash_different_pathname2
  #    i = Wovnrb::Interceptor.new(get_app)
  #    headers = stub
  #    headers.expects(:pathname).returns('/hello/tab.html')
  #    assert_equal('/fr/hello/hey/index.html', i.add_lang_code('hey/index.html', 'path', 'fr', headers))
  #  end
  def generate_body(param = "")
    case param
    when "ignore_parent"
      body = "<html><body><h1>Mr. Belvedere Fan Club</h1>
                <div wovn-ignore><p>Hello</p></div>
              </body></html>"
    when "ignore_everything"
      body = "<html><body wovn-ignore><h1>Mr. Belvedere Fan Club</h1>
                <div><p>Hello</p></div>
              </body></html>"
    when "ignore_parent_translated_in_japanese"
      body = "<html lang=\"ja\">
<head>
<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">
<script src=\"//j.wovn.io/1\" async=\"true\" data-wovnio=\"key=&amp;backend=true&amp;currentLang=ja&amp;defaultLang=en&amp;urlPattern=path&amp;version=#{Wovnrb::VERSION}\"> </script><link rel=\"alternate\" hreflang=\"ja\" href=\"http://ja.ignore-page.com/\">
</head>
<body>
<h1>ベルベデアさんファンクラブ</h1>
                <div wovn-ignore=\"\"><p>Hello</p></div>
              </body>
</html>
"
    when "translated_in_japanese"
      body = "<html lang=\"ja\">
<head>
<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">
<script src=\"//j.wovn.io/1\" async=\"true\" data-wovnio=\"key=&amp;backend=true&amp;currentLang=ja&amp;defaultLang=en&amp;urlPattern=path&amp;version=#{Wovnrb::VERSION}\"> </script><link rel=\"alternate\" hreflang=\"ja\" href=\"http://ja.page.com/\">
</head>
<body>
<h1>ベルベデアさんファンクラブ</h1>
                <div><p>こんにちは</p></div>
              </body>
</html>
"
    when "ignore_everything_translated"
      body = "<html lang=\"ja\">
<head>
<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">
<script src=\"//j.wovn.io/1\" async=\"true\" data-wovnio=\"key=&amp;backend=true&amp;currentLang=ja&amp;defaultLang=en&amp;urlPattern=path&amp;version=#{Wovnrb::VERSION}\"> </script><link rel=\"alternate\" hreflang=\"ja\" href=\"http://ja.ignore-page.com/\">
</head>
<body wovn-ignore=\"\">
<h1>Mr. Belvedere Fan Club</h1>
                <div><p>Hello</p></div>
              </body>
</html>
"
    when "empty"
      body = "<html><body><h1>Mr.BelvedereFanClub</h1><div wovn-ignore><p>Hello</p></div></body></html>"
    when "empty_single_quote"
      body = "<html><body><h1>Mr.BelvedereFanClub</h1><div wovn-ignore=''><p>Hello</p></div></body></html>"
    when "empty_double_quote"
      body = "<html><body><h1>Mr.BelvedereFanClub</h1><div wovn-ignore=""><p>Hello</p></div></body></html>"
    when "value_single_quote"
      body = "<html><body><h1>Mr.BelvedereFanClub</h1><div wovn-ignore='value'><p>Hello</p></div></body></html>"
    when "value_double_quote"
      body = "<html><body><h1>Mr.BelvedereFanClub</h1><div wovn-ignore=\"value\"><p>Hello</p></div></body></html>"
    when "empty_translated"
      body = "<html lang=\"ja\">\n<head>\n<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">\n<script src=\"//j.wovn.io/1\" async=\"true\" data-wovnio=\"key=&amp;backend=true&amp;currentLang=ja&amp;defaultLang=en&amp;urlPattern=path&amp;version=#{Wovnrb::VERSION}\"> </script><link rel=\"alternate\" hreflang=\"ja\" href=\"http://ja.ignore-page.com/\">\n</head>\n<body>\n<h1>Mr.BelvedereFanClub</h1>\n<div wovn-ignore=\"\"><p>Hello</p></div>\n</body>\n</html>\n"
    when "empty_single_quote_translated"
      body = "<html lang=\"ja\">\n<head>\n<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">\n<script src=\"//j.wovn.io/1\" async=\"true\" data-wovnio=\"key=&amp;backend=true&amp;currentLang=ja&amp;defaultLang=en&amp;urlPattern=path&amp;version=#{Wovnrb::VERSION}\"> </script><link rel=\"alternate\" hreflang=\"ja\" href=\"http://ja.ignore-page.com/\">\n</head>\n<body>\n<h1>Mr.BelvedereFanClub</h1>\n<div wovn-ignore=\"\"><p>Hello</p></div>\n</body>\n</html>\n"
    when "empty_double_quote_translated"
      body = "<html lang=\"ja\">\n<head>\n<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">\n<script src=\"//j.wovn.io/1\" async=\"true\" data-wovnio=\"key=&amp;backend=true&amp;currentLang=ja&amp;defaultLang=en&amp;urlPattern=path&amp;version=#{Wovnrb::VERSION}\"> </script><link rel=\"alternate\" hreflang=\"ja\" href=\"http://ja.ignore-page.com/\">\n</head>\n<body>\n<h1>Mr.BelvedereFanClub</h1>\n<div wovn-ignore=\"\"><p>Hello</p></div>\n</body>\n</html>\n"
    when "value_single_quote_translated"
      body = "<html lang=\"ja\">\n<head>\n<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">\n<script src=\"//j.wovn.io/1\" async=\"true\" data-wovnio=\"key=&amp;backend=true&amp;currentLang=ja&amp;defaultLang=en&amp;urlPattern=path&amp;version=#{Wovnrb::VERSION}\"> </script><link rel=\"alternate\" hreflang=\"ja\" href=\"http://ja.ignore-page.com/\">\n</head>\n<body>\n<h1>Mr.BelvedereFanClub</h1>\n<div wovn-ignore=\"value\"><p>Hello</p></div>\n</body>\n</html>\n"
    when "value_double_quote_translated"
      body = "<html lang=\"ja\">\n<head>\n<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">\n<script src=\"//j.wovn.io/1\" async=\"true\" data-wovnio=\"key=&amp;backend=true&amp;currentLang=ja&amp;defaultLang=en&amp;urlPattern=path&amp;version=#{Wovnrb::VERSION}\"> </script><link rel=\"alternate\" hreflang=\"ja\" href=\"http://ja.ignore-page.com/\">\n</head>\n<body>\n<h1>Mr.BelvedereFanClub</h1>\n<div wovn-ignore=\"value\"><p>Hello</p></div>\n</body>\n</html>\n"
    when "meta_img_alt_tags_translated"
      body = "<html lang=\"ja\">\n<head>\n<script src=\"//j.wovn.io/1\" async=\"true\" data-wovnio=\"key=&amp;backend=true&amp;currentLang=ja&amp;defaultLang=en&amp;urlPattern=path&amp;version=#{Wovnrb::VERSION}\"> </script><meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">\n<meta name=\"description\" content=\"こんにちは\">\n<meta name=\"title\" content=\"こんにちは\">\n<meta property=\"og:title\" content=\"こんにちは\">\n<meta property=\"og:description\" content=\"こんにちは\">\n<meta property=\"twitter:title\" content=\"こんにちは\">\n<meta property=\"twitter:description\" content=\"こんにちは\">\n<link rel=\"alternate\" hreflang=\"ja\" href=\"http://ja.page.com/\">\n</head>\n<body>\n<h1>ベルベデアさんファンクラブ</h1>\n<div><p>こんにちは</p></div>\n<img src=\"http://example.com/photo.png\" alt=\"こんにちは\">\n</body>\n</html>\n"
    when  "meta_img_alt_tags"
      body = "<html><head><meta name =\"description\" content=\"Hello\">\n<meta name=\"title\" content=\"Hello\">\n<meta property=\"og:title\" content=\"Hello\">\n<meta property=\"og:description\" content=\"Hello\">\n<meta property=\"twitter:title\" content=\"Hello\">\n<meta property=\"twitter:description\" content=\"Hello\"></head>
<body><h1>Mr. Belvedere Fan Club</h1>
<div><p>Hello</p></div>
<img src=\"http://example.com/photo.png\" alt=\"Hello\">
</body></html>"
    else # "" case
      body = "<html><body><h1>Mr. Belvedere Fan Club</h1>
                <div><p>Hello</p></div>
              </body></html>"
    end
    return [body]
  end

  def generate_values
    values = {}
    values['text_vals'] = {'Hello' => {'ja' => [{'data' => 'こんにちは'}]},
    'Mr. Belvedere Fan Club' => {'ja' => [{'data' => 'ベルベデアさんファンクラブ'}]}}
    return values
  end

  def test_switch_lang
    i = Wovnrb::Interceptor.new(get_app)
    h = Wovnrb::Headers.new(get_env('url' => 'http://page.com'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    body = generate_body()
    values = generate_values
    url = h.url
    swapped_body = i.switch_lang(body, values, url, 'ja', h)
    assert_equal(generate_body('translated_in_japanese'), swapped_body)
  end

  def test_switch_lang_meta_img_alt_tags
    i = Wovnrb::Interceptor.new(get_app)
    h = Wovnrb::Headers.new(get_env('url' => 'http://page.com'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    body = generate_body('meta_img_alt_tags')
    values = generate_values
    url = h.url
    swapped_body = i.switch_lang(body, values, url, 'ja', h)
    assert_equal(generate_body('meta_img_alt_tags_translated'), swapped_body)
  end

  def test_switch_lang_wovn_ignore
    i = Wovnrb::Interceptor.new(get_app)
    h = Wovnrb::Headers.new(get_env('url' => 'http://ignore-page.com'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    body = generate_body('ignore_parent')
    values = generate_values
    url = h.url
    swapped_body = i.switch_lang(body, values, url, 'ja', h)
    assert_equal(generate_body('ignore_parent_translated_in_japanese'), swapped_body)
  end

  def test_switch_lang_wovn_ignore_everything
    i = Wovnrb::Interceptor.new(get_app)
    h = Wovnrb::Headers.new(get_env('url' => 'http://ignore-page.com'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    body = generate_body('ignore_everything')
    values = generate_values
    url = h.url
    swapped_body = i.switch_lang(body, values, url, 'ja', h)
    assert_equal(generate_body('ignore_everything_translated'), swapped_body)
  end

  def test_switch_lang_wovn_ignore_empty
    i = Wovnrb::Interceptor.new(get_app)
    h = Wovnrb::Headers.new(get_env('url' => 'http://ignore-page.com'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    body = generate_body('empty')
    values = generate_values
    url = h.url
    swapped_body = i.switch_lang(body, values, url, 'ja', h)
    assert_equal(generate_body('empty_translated'), swapped_body)
  end

  def test_switch_lang_wovn_ignore_empty_single_quote
    i = Wovnrb::Interceptor.new(get_app)
    h = Wovnrb::Headers.new(get_env('url' => 'http://ignore-page.com'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    body = generate_body('empty_single_quote')
    values = generate_values
    url = h.url
    swapped_body = i.switch_lang(body, values, url, 'ja', h)
    assert_equal(generate_body('empty_single_quote_translated'), swapped_body)
  end

  def test_switch_lang_wovn_ignore_empty_double_quote
    i = Wovnrb::Interceptor.new(get_app)
    h = Wovnrb::Headers.new(get_env('url' => 'http://ignore-page.com'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    body = generate_body('empty_double_quote')
    values = generate_values
    url = h.url
    swapped_body = i.switch_lang(body, values, url, 'ja', h)
    assert_equal(generate_body('empty_double_quote_translated'), swapped_body)
  end

  def test_switch_lang_wovn_ignore_value_single_quote
    i = Wovnrb::Interceptor.new(get_app)
    h = Wovnrb::Headers.new(get_env('url' => 'http://ignore-page.com'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    body = generate_body('value_single_quote')
    values = generate_values
    url = h.url
    swapped_body = i.switch_lang(body, values, url, 'ja', h)
    assert_equal(generate_body('value_single_quote_translated'), swapped_body)
  end

  def test_switch_lang_wovn_ignore_value_double_quote
    i = Wovnrb::Interceptor.new(get_app)
    h = Wovnrb::Headers.new(get_env('url' => 'http://ignore-page.com'), get_settings('url_pattern' => 'subdomain', 'url_pattern_reg' => '^(?<lang>[^.]+).'))
    body = generate_body('value_double_quote')
    values = generate_values
    url = h.url
    swapped_body = i.switch_lang(body, values, url, 'ja', h)
    assert_equal(generate_body('value_double_quote_translated'), swapped_body)
  end

  def get_settings(options={})
    settings = {}
    settings['user_token'] = 'OHYx9'
    settings['url_pattern'] = 'path'
    settings['url_pattern_reg'] = "/(?<lang>[^/.?]+)"
    settings['query'] = []
    settings['backend_host'] = 'localhost'
    settings['backend_port'] = '6379'
    settings['default_lang'] = 'en'
    settings['supported_langs'] = []
    settings['secret_key'] = ''
    return settings.merge(options)
  end

  def get_env(options={})
    env = {}
    env['rack.url_scheme'] = 'http'
    env['HTTP_HOST'] = 'wovn.io'
    env['REQUEST_URI'] = '/dashboard?param=val&hey=you'
    env['SERVER_NAME'] = 'wovn.io'
    env['HTTP_COOKIE'] = "olfsk=olfsk021093478426337242; hblid=KB8AAMzxzu2DSxnB4X7BJ26rBGVeF0yJ; optimizelyEndUserId=oeu1426233718869r0.5398541854228824; __zlcmid=UFeZqrVo6Mv3Yl; wovn_selected_lang=en; optimizelySegments=%7B%7D; optimizelyBuckets=%7B%7D; _equalizer_session=eDFwM3M2QUZJZFhoby9JZlArckcvSUJwNFRINXhUeUxtNnltQXZhV0tqdGhZQjJMZ01URnZTK05ydFVWYmM3U0dtMVN0M0Z0UnNDVG8vdUNDTUtPc21jY0FHREgrZ05CUnBTb0hyUlkvYlBWQVhQR3RZdnhjMWsrRW5rOVp1Z3V3bkgyd3NpSlRZQWU1dlZvNmM1THp6aUZVeE83Y1pWWENRNTBUVFIrV05WeTdDMlFlem1tUzdxaEtndFZBd2dtUjU2ak5EUmJPa3RWWmMyT1pSVWdMTm8zOVZhUWhHdGQ3L1c5bm91RmNSdFRrcC90Tml4N2t3ZWlBaDRya2lLT1I0S0J2TURhUWl6Uk5rOTQ4Y1MwM3VKYnlLMUYraEt5clhRdFd1eGdEWXdZd3pFbWQvdE9vQndhdDVQbXNLcHBURm9CbnZKenU2YnNXRFdqRVl0MVV3bmRyYjhvMDExcGtUVU9tK1lqUGswM3p6M05tbVRnTjE3TUl5cEdpTTZ4a2gray8xK0FvTC9wUDVka1JSeE5GM1prZmRjWDdyVzRhWW5uS2Mxc1BxOEVVTTZFS3N5bTlVN2p5eE5YSjNZWGI2UHd3Vzc0bDM5QjIwL0l5Mm85NmQyWFAwdVQ3ZzJYYk1QOHY2NVJpY2c9LS1KNU96eHVycVJxSDJMbEc4Rm9KVXpBPT0%3D--17e47555d692fb9cde20ef78a09a5eabbf805bb3; mp_a0452663eb7abb7dfa9c94007ebb0090_mixpanel=%7B%22distinct_id%22%3A%20%2253ed9ffa4a65662e37000000%22%2C%22%24initial_referrer%22%3A%20%22http%3A%2F%2Fp.dev-wovn.io%3A8080%2Fhttp%3A%2F%2Fdev-wovn.io%3A3000%22%2C%22%24initial_referring_domain%22%3A%20%22p.dev-wovn.io%3A8080%22%2C%22__mps%22%3A%20%7B%7D%2C%22__mpso%22%3A%20%7B%7D%2C%22__mpa%22%3A%20%7B%7D%2C%22__mpu%22%3A%20%7B%7D%2C%22__mpap%22%3A%20%5B%5D%7D"
    env['HTTP_ACCEPT_LANGUAGE'] = 'ja,en-US;q=0.8,en;q=0.6'
    env['QUERY_STRING'] = 'param=val&hey=you'
    env['ORIGINAL_FULLPATH'] = '/dashboard?param=val&hey=you'
    #env['HTTP_REFERER'] = 
    env['REQUEST_PATH'] = '/dashboard'
    env['PATH_INFO'] = '/dashboard'

    if options['url']
      url = URI.parse(options['url'])
      env['rack.url_scheme'] = url.scheme
      env['HTTP_HOST'] = url.host
      if (url.scheme == 'http' && url.port != 80) || (url.scheme == 'https' && url.port != 443)
        env['HTTP_HOST'] += ":#{url.port}"
      end
      env['SERVER_NAME'] = url.host
      env['REQUEST_URI'] = url.request_uri
      env['ORIGINAL_FULLPATH'] = url.request_uri
      env['QUERY_STRING'] = url.query
      env['REQUEST_PATH'] = url.path
      env['PATH_INFO'] = url.path
    end
    return env.merge(options)
  end
end
