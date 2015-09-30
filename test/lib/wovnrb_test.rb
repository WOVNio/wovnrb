require 'wovnrb'
require 'wovnrb/headers'
require 'minitest/autorun'
require 'pry'
require 'mocha/mini_test'

class WovnrbTest < Minitest::Test

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

  def get_app()
  end

  def test_add_lang_code_nil_href
    i = Wovnrb::Interceptor.new(get_app)
    assert_equal(nil, i.add_lang_code(nil,'path', 'en', nil))
  end
  def test_add_lang_code_absolute_different_host
    i = Wovnrb::Interceptor.new(get_app)
    headers = stub
    headers.expects(:host).returns('google.com')
    assert_equal('http://yahoo.co.jp', i.add_lang_code('http://yahoo.co.jp', 'path', 'fr', headers))
  end

  def test_add_lang_code_absolute_subdomain_no_subdomain
    i = Wovnrb::Interceptor.new(get_app)
    headers = stub
    headers.expects(:host).returns('google.com')
    assert_equal('http://fr.google.com', i.add_lang_code('http://google.com', 'subdomain', 'fr', headers))
  end

  def test_add_lang_code_absolute_subdomain_with_subdomain
    i = Wovnrb::Interceptor.new(get_app)
    headers = stub
    headers.expects(:host).returns('home.google.com')
    assert_equal('http://fr.home.google.com', i.add_lang_code('http://home.google.com', 'subdomain', 'fr', headers))
  end

  def test_add_lang_code_absolute_query_no_query
    i = Wovnrb::Interceptor.new(get_app)
    headers = stub
    headers.expects(:host).returns('google.com')
    assert_equal('http://google.com?wovn=fr', i.add_lang_code('http://google.com', 'query', 'fr', headers))
  end

  def test_add_lang_code_absolute_query_with_query
    i = Wovnrb::Interceptor.new(get_app)
    headers = stub
    headers.expects(:host).returns('google.com')
    assert_equal('http://google.com?hey=yo&wovn=fr', i.add_lang_code('http://google.com?hey=yo', 'query', 'fr', headers))
  end

  def test_add_lang_code_absolute_path_no_pathname
    i = Wovnrb::Interceptor.new(get_app)
    headers = stub
    headers.expects(:host).returns('google.com')
    assert_equal('http://google.com/fr/', i.add_lang_code('http://google.com', 'path', 'fr', headers))
  end

  def test_add_lang_code_absolute_path_with_pathname
    i = Wovnrb::Interceptor.new(get_app)
    headers = stub
    headers.expects(:host).returns('google.com')
    assert_equal('http://google.com/fr/index.html', i.add_lang_code('http://google.com/index.html', 'path', 'fr', headers))
  end

  def test_add_lang_code_absolute_path_with_long_pathname
    i = Wovnrb::Interceptor.new(get_app)
    headers = stub
    headers.expects(:host).returns('google.com')
    assert_equal('http://google.com/fr/hello/long/path/index.html', i.add_lang_code('http://google.com/hello/long/path/index.html', 'path', 'fr', headers))
  end

  def test_add_lang_code_relative_subdomain_leading_slash
    i = Wovnrb::Interceptor.new(get_app)
    headers = stub
    headers.expects(:protocol).returns('http')
    headers.expects(:host).returns('google.com')
    assert_equal('http://fr.google.com/', i.add_lang_code('/', 'subdomain', 'fr', headers))
  end

  def test_add_lang_code_relative_subdomain_leading_slash_filename
    i = Wovnrb::Interceptor.new(get_app)
    headers = stub
    headers.expects(:protocol).returns('http')
    headers.expects(:host).returns('google.com')
    assert_equal('http://fr.google.com/index.html', i.add_lang_code('/index.html', 'subdomain', 'fr', headers))
  end

  def test_add_lang_code_relative_subdomain_no_leading_slash_filename
    i = Wovnrb::Interceptor.new(get_app)
    headers = stub
    headers.expects(:protocol).returns('http')
    headers.expects(:host).returns('google.com')
    headers.expects(:pathname).returns('/')
    assert_equal('http://fr.google.com/index.html', i.add_lang_code('index.html', 'subdomain', 'fr', headers))
  end

  def test_add_lang_code_relative_subdomain_dot_filename
    i = Wovnrb::Interceptor.new(get_app)
    headers = stub
    headers.expects(:protocol).returns('http')
    headers.expects(:host).returns('google.com')
    headers.expects(:pathname).returns('/')
    assert_equal('http://fr.google.com/./index.html', i.add_lang_code('./index.html', 'subdomain', 'fr', headers))
  end

  def test_add_lang_code_relative_subdomain_two_dots_filename_long_pathname
    i = Wovnrb::Interceptor.new(get_app)
    headers = stub
    headers.expects(:protocol).returns('http')
    headers.expects(:host).returns('google.com')
    headers.expects(:pathname).returns('/home/hey/index.html')
    assert_equal('http://fr.google.com/home/hey/../index.html', i.add_lang_code('../index.html', 'subdomain', 'fr', headers))
  end

  def test_add_lang_code_relative_query_with_no_query
    i = Wovnrb::Interceptor.new(get_app)
    headers = stub
    assert_equal('/index.html?wovn=fr', i.add_lang_code('/index.html', 'query', 'fr', headers))
  end

  def test_add_lang_code_relative_query_with_query
    i = Wovnrb::Interceptor.new(get_app)
    headers = stub
    assert_equal('/index.html?hey=yo&wovn=fr', i.add_lang_code('/index.html?hey=yo', 'query', 'fr', headers))
  end

  def test_add_lang_code_relative_path_with_leading_slash
    i = Wovnrb::Interceptor.new(get_app)
    headers = stub
    assert_equal('/fr/index.html', i.add_lang_code('/index.html', 'path', 'fr', headers))
  end

  def test_add_lang_code_relative_path_without_leading_slash_different_pathname
    i = Wovnrb::Interceptor.new(get_app)
    headers = stub
    headers.expects(:pathname).returns('/hello/tab.html')
    assert_equal('/fr/hello/index.html', i.add_lang_code('index.html', 'path', 'fr', headers))
  end

  def test_add_lang_code_relative_path_without_leading_slash_different_pathname2
    i = Wovnrb::Interceptor.new(get_app)
    headers = stub
    headers.expects(:pathname).returns('/hello/tab.html')
    assert_equal('/fr/hello/hey/index.html', i.add_lang_code('hey/index.html', 'path', 'fr', headers))
  end
end
