require 'test_helper'

module Wovnrb
  class URLTest < WovnMiniTest
    def test_normalize_url
      assert_equal('http://domain.com', Wovnrb::URL.normalize_url('http://domain.com'))
      assert_equal('http://domain.com', Wovnrb::URL.normalize_url('http://domain.com '))
      assert_equal('http://domain.com', Wovnrb::URL.normalize_url(' http://domain.com'))
      assert_equal('http://domain.com', Wovnrb::URL.normalize_url("\u200b http://domain.com"))
      assert_equal('http://domain.com', Wovnrb::URL.normalize_url("  http:\u200b//domain.com\u200b"))
    end

    def test_resolve_absolute_uri
      assert_equal('http://domain.com', Wovnrb::URL.resolve_absolute_uri('http://domain.com', '').to_s)
      assert_equal('http://domain.com/', Wovnrb::URL.resolve_absolute_uri('http://domain.com', '/').to_s)
      assert_equal('http://domain.com/some/path', Wovnrb::URL.resolve_absolute_uri('http://domain.com', '/some/path').to_s)
      assert_equal('http://domain.com/some/path', Wovnrb::URL.resolve_absolute_uri('http://domain.com/', '/some/path').to_s)
      assert_equal('http://domain.com/some/path/', Wovnrb::URL.resolve_absolute_uri('http://domain.com/', '/some/path/').to_s)
      assert_equal('http://domain.com/garbage_relative_path/', Wovnrb::URL.resolve_absolute_uri('http://domain.com/', '/../../garbage_relative_path/').to_s)
      assert_equal('http://domain.com/root.html', Wovnrb::URL.resolve_absolute_uri('http://domain.com/dir1/dir2/page.html', '/.././../root.html').to_s)
      assert_equal('http://domain.com/root.html?baz=123', Wovnrb::URL.resolve_absolute_uri('http://domain.com/dir1/dir2/page.html?foo=bar', '/.././../root.html?baz=123').to_s)
      assert_equal('http://domain.com/some/path', Wovnrb::URL.resolve_absolute_uri('http://domain.com?foo=bar', '/some/path').to_s)
      assert_equal('http://another_absolute_url.com/dir/', Wovnrb::URL.resolve_absolute_uri('http://domain.com?foo=bar', 'http://another_absolute_url.com/dir/').to_s)
      assert_equal('http://another_absolute_url.com/dir/page', Wovnrb::URL.resolve_absolute_uri('http://domain.com?foo=bar', 'http://another_absolute_url.com/dir/../dir/page').to_s)
    end

    def test_resolve_absolute_path
      assert_equal('', Wovnrb::URL.resolve_absolute_path('http://domain.com', ''))
      assert_equal('/', Wovnrb::URL.resolve_absolute_path('http://domain.com/', ''))
      assert_equal('/', Wovnrb::URL.resolve_absolute_path('http://domain.com', '/'))
      assert_equal('/foo/bar', Wovnrb::URL.resolve_absolute_path('http://domain.com', '/foo/bar'))
      assert_equal('/foo/bar', Wovnrb::URL.resolve_absolute_path('http://domain.com', 'foo/bar'))
      assert_equal('/dir/foo/bar', Wovnrb::URL.resolve_absolute_path('http://domain.com/dir/', 'foo/bar'))
      assert_equal('/dir/bar', Wovnrb::URL.resolve_absolute_path('http://domain.com/dir/', 'foo/../bar'))
      assert_equal('/dir/bar?query=123#hash', Wovnrb::URL.resolve_absolute_path('http://domain.com/dir/', 'foo/../bar?query=123#hash'))
      assert_equal('/fr/wovn_aaa/news/', Wovnrb::URL.resolve_absolute_path('https://pre.avex.jp/wovn_aaa/news/', '/fr/wovn_aaa/news/../news/'))
    end

    def test_absolute_url
      assert(Wovnrb::URL.absolute_url?('//foo.com'))
      assert(Wovnrb::URL.absolute_url?('http://foo.com'))
      assert(Wovnrb::URL.absolute_url?('https://foo.com'))
      assert_not(Wovnrb::URL.absolute_url?('ftp://foo.com'))
      assert_not(Wovnrb::URL.absolute_url?('foo'))
      assert_not(Wovnrb::URL.absolute_url?('/foo'))
      assert_not(Wovnrb::URL.absolute_url?('../foo'))
    end

    def test_join_paths
      assert_equal('', Wovnrb::URL.join_paths('', ''))
      assert_equal('/', Wovnrb::URL.join_paths('', '/'))
      assert_equal('/foo', Wovnrb::URL.join_paths('', '/foo'))
      assert_equal('/foo/', Wovnrb::URL.join_paths('', '/foo/'))

      assert_equal('/', Wovnrb::URL.join_paths('/', ''))
      assert_equal('/foo', Wovnrb::URL.join_paths('/foo', ''))
      assert_equal('/foo/', Wovnrb::URL.join_paths('/foo/', ''))

      assert_equal('/foo/', Wovnrb::URL.join_paths('/foo/', ''))
      assert_equal('/foo/bar', Wovnrb::URL.join_paths('/foo', 'bar'))
      assert_equal('/foo/bar', Wovnrb::URL.join_paths('/foo/', 'bar'))
      assert_equal('/foo/bar', Wovnrb::URL.join_paths('/foo/', '/bar'))
      assert_equal('/foo/bar/', Wovnrb::URL.join_paths('/foo/', 'bar/'))
      assert_equal('/foo/bar/', Wovnrb::URL.join_paths('/foo/', '/bar/'))
      assert_equal('/foo/bar/', Wovnrb::URL.join_paths('/foo', 'bar/'))
    end

    def test_absolute_path
      assert_not(Wovnrb::URL.absolute_path?('http://foo.com'))
      assert_not(Wovnrb::URL.absolute_path?('https://foo.com'))
      assert_not(Wovnrb::URL.absolute_path?('foo'))
      assert_not(Wovnrb::URL.absolute_path?('../foo'))
      assert(Wovnrb::URL.absolute_path?('/foo'))
    end

    def test_relative_path
      assert_not(Wovnrb::URL.relative_path?('http://foo.com'))
      assert_not(Wovnrb::URL.relative_path?('https://foo.com'))
      assert(Wovnrb::URL.relative_path?('foo'))
      assert(Wovnrb::URL.relative_path?('../foo'))
      assert(Wovnrb::URL.relative_path?('./foo'))
      assert_not(Wovnrb::URL.relative_path?('/foo'))
    end

    def test_prepend_path
      assert_equal('http://www.google.com/new_dir/test/', Wovnrb::URL.prepend_path('http://www.google.com/test/', 'new_dir'))
    end

    def test_prepend_path_long_path
      assert_equal('http://www.google.com/new_dir/test/try/again/', Wovnrb::URL.prepend_path('http://www.google.com/test/try/again/', 'new_dir'))
    end

    def test_prepend_path_no_trailing_slash
      assert_equal('http://www.google.com/new_dir/test', Wovnrb::URL.prepend_path('http://www.google.com/test', 'new_dir'))
    end

    def test_prepend_path_long_path_no_trailing_slash
      assert_equal('http://www.google.com/new_dir/test/try/again', Wovnrb::URL.prepend_path('http://www.google.com/test/try/again', 'new_dir'))
    end

    def test_prepend_path_no_path
      assert_equal('http://www.google.com/new_dir/', Wovnrb::URL.prepend_path('http://www.google.com/', 'new_dir'))
    end

    def test_prepend_path_no_path_no_trailing_slash
      assert_equal('http://www.google.com/new_dir', Wovnrb::URL.prepend_path('http://www.google.com', 'new_dir'))
    end

    def test_prepend_path_no_host
      assert_equal('http://google.com/new_dir/test/', Wovnrb::URL.prepend_path('http://google.com/test/', 'new_dir'))
    end

    def test_prepend_path_no_host_long_path
      assert_equal('http://google.com/new_dir/test/try/again/', Wovnrb::URL.prepend_path('http://google.com/test/try/again/', 'new_dir'))
    end

    def test_prepend_path_no_host_no_trailing_slash
      assert_equal('http://google.com/new_dir/test', Wovnrb::URL.prepend_path('http://google.com/test', 'new_dir'))
    end

    def test_prepend_path_no_host_long_path_no_trailing_slash
      assert_equal('http://google.com/new_dir/test/try/again', Wovnrb::URL.prepend_path('http://google.com/test/try/again', 'new_dir'))
    end

    def test_prepend_path_no_host_no_path
      assert_equal('http://google.com/new_dir/', Wovnrb::URL.prepend_path('http://google.com/', 'new_dir'))
    end

    def test_prepend_path_no_host_no_path_no_trailing_slash
      assert_equal('http://google.com/new_dir', Wovnrb::URL.prepend_path('http://google.com', 'new_dir'))
    end

    def test_prepend_path_no_protocol
      assert_equal('www.facebook.com/dir/test/', Wovnrb::URL.prepend_path('www.facebook.com/test/', 'dir'))
    end

    def test_prepend_path_no_protocol_long_path
      assert_equal('www.facebook.com/dir/test/try/again/', Wovnrb::URL.prepend_path('www.facebook.com/test/try/again/', 'dir'))
    end

    def test_prepend_path_no_protocol_no_trailing_slash
      assert_equal('www.facebook.com/dir/test', Wovnrb::URL.prepend_path('www.facebook.com/test', 'dir'))
    end

    def test_prepend_path_no_protocol_long_path_no_trailing_slash
      assert_equal('www.facebook.com/dir/test/try/again', Wovnrb::URL.prepend_path('www.facebook.com/test/try/again', 'dir'))
    end

    def test_prepend_path_no_protocol_no_path
      assert_equal('www.facebook.com/dir/', Wovnrb::URL.prepend_path('www.facebook.com/', 'dir'))
    end

    def test_prepend_path_no_protocol_no_path_no_trailing_slash
      assert_equal('www.facebook.com/dir', Wovnrb::URL.prepend_path('www.facebook.com', 'dir'))
    end

    def test_prepend_path_no_protocoli_no_host
      assert_equal('facebook.com/dir/test/', Wovnrb::URL.prepend_path('facebook.com/test/', 'dir'))
    end

    def test_prepend_path_no_protocol_no_host_long_path
      assert_equal('facebook.com/dir/test/try/again/', Wovnrb::URL.prepend_path('facebook.com/test/try/again/', 'dir'))
    end

    def test_prepend_path_no_protocol_no_host_no_trailing_slash
      assert_equal('facebook.com/dir/test', Wovnrb::URL.prepend_path('facebook.com/test', 'dir'))
    end

    def test_prepend_path_no_protocol_no_host_long_path_no_trailing_slash
      assert_equal('facebook.com/dir/test/try/again', Wovnrb::URL.prepend_path('facebook.com/test/try/again', 'dir'))
    end

    def test_prepend_path_no_protocol_no_host_no_path
      assert_equal('facebook.com/dir/', Wovnrb::URL.prepend_path('facebook.com/', 'dir'))
    end

    def test_prepend_path_no_protocol_no_host_no_path_no_trailing_slash
      assert_equal('facebook.com/dir', Wovnrb::URL.prepend_path('facebook.com', 'dir'))
    end

    def test_prepend_path_no_protocol_with_double_slash
      assert_equal('//www.yahoo.com/dir/test/', Wovnrb::URL.prepend_path('//www.yahoo.com/test/', 'dir'))
    end

    def test_prepend_path_no_protocol_long_path_with_double_slash
      assert_equal('//www.yahoo.com/dir/test/try/again/', Wovnrb::URL.prepend_path('//www.yahoo.com/test/try/again/', 'dir'))
    end

    def test_prepend_path_no_protocol_no_trailing_slash_with_double_slash
      assert_equal('//www.yahoo.com/dir/test', Wovnrb::URL.prepend_path('//www.yahoo.com/test', 'dir'))
    end

    def test_prepend_path_no_protocol_long_path_no_trailing_slash_with_double_slash
      assert_equal('//www.yahoo.com/dir/test/try/again', Wovnrb::URL.prepend_path('//www.yahoo.com/test/try/again', 'dir'))
    end

    def test_prepend_path_no_protocol_no_path_with_double_slash
      assert_equal('//www.yahoo.com/dir/', Wovnrb::URL.prepend_path('//www.yahoo.com/', 'dir'))
    end

    def test_prepend_path_no_protocol_no_path_no_trailing_slash_with_double_slash
      assert_equal('//www.yahoo.com/dir', Wovnrb::URL.prepend_path('//www.yahoo.com', 'dir'))
    end

    def test_prepend_path_no_protocol_no_host_with_double_slash
      assert_equal('//yahoo.com/dir/test/', Wovnrb::URL.prepend_path('//yahoo.com/test/', 'dir'))
    end

    def test_prepend_path_no_protocol_no_host_long_path_with_double_slash
      assert_equal('//yahoo.com/dir/test/try/again/', Wovnrb::URL.prepend_path('//yahoo.com/test/try/again/', 'dir'))
    end

    def test_prepend_path_no_protocol_no_host_no_trailing_slash_with_double_slash
      assert_equal('//yahoo.com/dir/test', Wovnrb::URL.prepend_path('//yahoo.com/test', 'dir'))
    end

    def test_prepend_path_no_protocol_no_host_long_path_no_trailing_slash_with_double_slash
      assert_equal('//yahoo.com/dir/test/try/again', Wovnrb::URL.prepend_path('//yahoo.com/test/try/again', 'dir'))
    end

    def test_prepend_path_no_protocol_no_host_no_path_with_double_slash
      assert_equal('//yahoo.com/dir/', Wovnrb::URL.prepend_path('//yahoo.com/', 'dir'))
    end

    def test_prepend_path_no_protocol_no_host_no_path_no_trailing_slash_with_double_slash
      assert_equal('//yahoo.com/dir', Wovnrb::URL.prepend_path('//yahoo.com', 'dir'))
    end

    def test_valid_protocol?
      assert_equal(true, Wovnrb::URL.valid_protocol?('http://foo.com'))
      assert_equal(true, Wovnrb::URL.valid_protocol?('https://foo.com/index.html'))
      assert_equal(false, Wovnrb::URL.valid_protocol?('data:;base64,iVBORw0KGgo='))
      assert_equal(false, Wovnrb::URL.valid_protocol?('tel:+817044446666'))
      assert_equal(false, Wovnrb::URL.valid_protocol?('ftp://site.com:8000/cat.png'))

      assert_equal(true, Wovnrb::URL.valid_protocol?('site.com:8000/index.html'))
      assert_equal(true, Wovnrb::URL.valid_protocol?('/page/index.html?user=tom'))
      assert_equal(true, Wovnrb::URL.valid_protocol?('../index.html'))
    end

    def test_file?
      assert_equal(false, Wovnrb::URL.file?(''))
      assert_equal(false, Wovnrb::URL.file?('example.com'))
      assert_equal(false, Wovnrb::URL.file?('Download rain.mp3 for background noise'))
      assert_equal(false, Wovnrb::URL.file?('http://example.com?q=dog.png'))
      assert_equal(false, Wovnrb::URL.file?('https://site.jp'))
      assert_equal(false, Wovnrb::URL.file?('https://site.jp/'))
      assert_equal(false, Wovnrb::URL.file?('https://site.jp?user=tom'))
      assert_equal(false, Wovnrb::URL.file?('https://site.jp/?user=tom'))
      assert_equal(false, Wovnrb::URL.file?('https://site.jp#top'))
      assert_equal(false, Wovnrb::URL.file?('https://site.jp/#top'))
      assert_equal(false, Wovnrb::URL.file?('https://site.jp/index.html'))

      assert_equal(true, Wovnrb::URL.file?('https://example.com/images/baloon.png'))
      assert_equal(true, Wovnrb::URL.file?('/new/stan.mp3'))
      assert_equal(true, Wovnrb::URL.file?('https://box.com/user/chad/beef_stew.zip'))
      assert_equal(true, Wovnrb::URL.file?('https://site.jp/beef_stew.zip'))
      assert_equal(true, Wovnrb::URL.file?('/dir/some.pdf'))
      assert_equal(true, Wovnrb::URL.file?('/dir/some.doc'))
      assert_equal(true, Wovnrb::URL.file?('/dir/some.docx'))
      assert_equal(true, Wovnrb::URL.file?('/dir/some.xls'))
      assert_equal(true, Wovnrb::URL.file?('/dir/some.xlsx'))
      assert_equal(true, Wovnrb::URL.file?('/dir/some.xlsm'))
    end

    def test_path_and_query
      assert_equal('', Wovnrb::URL.path_and_query(Addressable::URI.parse('http://domain.com')))
      assert_equal('?foo=bar', Wovnrb::URL.path_and_query(Addressable::URI.parse('http://domain.com?foo=bar')))
      assert_equal('?', Wovnrb::URL.path_and_query(Addressable::URI.parse('http://domain.com?')))

      assert_equal('/', Wovnrb::URL.path_and_query(Addressable::URI.parse('http://domain.com/')))
      assert_equal('/?foo=bar', Wovnrb::URL.path_and_query(Addressable::URI.parse('http://domain.com/?foo=bar')))

      assert_equal('/dir/path', Wovnrb::URL.path_and_query(Addressable::URI.parse('http://domain.com/dir/path')))
      assert_equal('/dir/path?foo=bar', Wovnrb::URL.path_and_query(Addressable::URI.parse('http://domain.com/dir/path?foo=bar')))
    end

    def test_path_and_query_and_hash
      assert_equal('', Wovnrb::URL.path_and_query_and_hash(Addressable::URI.parse('http://domain.com')))
      assert_equal('?', Wovnrb::URL.path_and_query_and_hash(Addressable::URI.parse('http://domain.com?')))
      assert_equal('?foo=bar', Wovnrb::URL.path_and_query_and_hash(Addressable::URI.parse('http://domain.com?foo=bar')))
      assert_equal('#fragment', Wovnrb::URL.path_and_query_and_hash(Addressable::URI.parse('http://domain.com#fragment')))
      assert_equal('/', Wovnrb::URL.path_and_query_and_hash(Addressable::URI.parse('http://domain.com/')))
      assert_equal('/#fragment', Wovnrb::URL.path_and_query_and_hash(Addressable::URI.parse('http://domain.com/#fragment')))
      assert_equal('/?foo=bar', Wovnrb::URL.path_and_query_and_hash(Addressable::URI.parse('http://domain.com/?foo=bar')))
      assert_equal('/?foo=bar#fragment', Wovnrb::URL.path_and_query_and_hash(Addressable::URI.parse('http://domain.com/?foo=bar#fragment')))
      assert_equal('/dir/path', Wovnrb::URL.path_and_query_and_hash(Addressable::URI.parse('http://domain.com/dir/path')))
      assert_equal('/dir/path#fragment', Wovnrb::URL.path_and_query_and_hash(Addressable::URI.parse('http://domain.com/dir/path#fragment')))
      assert_equal('/dir/path?foo=bar', Wovnrb::URL.path_and_query_and_hash(Addressable::URI.parse('http://domain.com/dir/path?foo=bar')))
      assert_equal('/dir/path?foo=bar#fragment', Wovnrb::URL.path_and_query_and_hash(Addressable::URI.parse('http://domain.com/dir/path?foo=bar#fragment')))
    end

    def test_change_protocol
      assert_equal('https://domain.com', Wovnrb::URL.change_protocol(Addressable::URI.parse('http://domain.com'), 'https').to_s)
      assert_equal('http://domain.com', Wovnrb::URL.change_protocol(Addressable::URI.parse('https://domain.com'), 'http').to_s)
      assert_equal('//domain.com', Wovnrb::URL.change_protocol(Addressable::URI.parse('https://domain.com'), nil).to_s)
      assert_equal('http://domain.com', Wovnrb::URL.change_protocol(Addressable::URI.parse('//domain.com'), 'http').to_s)
    end

    def test_normalize_path_slash
      assert_equal('/en/dir1/dir2/', Wovnrb::URL.normalize_path_slash('/dir1/dir2/', '/en/dir1/dir2/'))
      assert_equal('/en/dir1/dir2', Wovnrb::URL.normalize_path_slash('/dir1/dir2', '/en/dir1/dir2/'))
      assert_equal('/en/dir1/dir2/', Wovnrb::URL.normalize_path_slash('/dir1/dir2/', '/en/dir1/dir2'))
      assert_equal('/', Wovnrb::URL.normalize_path_slash('/', '/'))
      assert_equal('', Wovnrb::URL.normalize_path_slash('', '/'))
    end
  end
end
