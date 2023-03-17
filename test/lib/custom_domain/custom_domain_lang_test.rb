require 'test_helper'
require 'wovnrb/custom_domain/custom_domain_lang'

module Wovnrb
  class CustomDomainLangTest < WovnMiniTest
    def setup
      @custom_domain_root_path = CustomDomainLang.new('foo.com', '/', 'fr')
      @custom_domain_with_path_no_trailing_slash = CustomDomainLang.new('foo.com', '/path', 'fr')
      @custom_domain_with_path_trailing_slash = CustomDomainLang.new('foo.com', '/path/', 'fr')
      @custom_domain_path_encoded_spaces = CustomDomainLang.new('foo.com', '/dir%20path', 'fr')
    end

    def test_custom_domain_lang_params
      assert_equal('foo.com', @custom_domain_root_path.host)
      assert_equal('/', @custom_domain_root_path.path)
      assert_equal('fr', @custom_domain_root_path.lang)
      assert_equal('foo.com', @custom_domain_root_path.host_and_path_without_trailing_slash)

      assert_equal('foo.com', @custom_domain_with_path_no_trailing_slash.host)
      assert_equal('/path/', @custom_domain_with_path_no_trailing_slash.path)
      assert_equal('fr', @custom_domain_with_path_no_trailing_slash.lang)
      assert_equal('foo.com/path', @custom_domain_with_path_no_trailing_slash.host_and_path_without_trailing_slash)

      assert_equal('foo.com', @custom_domain_with_path_trailing_slash.host)
      assert_equal('/path/', @custom_domain_with_path_trailing_slash.path)
      assert_equal('fr', @custom_domain_with_path_trailing_slash.lang)
      assert_equal('foo.com/path', @custom_domain_with_path_trailing_slash.host_and_path_without_trailing_slash)

      assert_equal('foo.com', @custom_domain_path_encoded_spaces.host)
      assert_equal('/dir%20path/', @custom_domain_path_encoded_spaces.path)
      assert_equal('fr', @custom_domain_path_encoded_spaces.lang)
      assert_equal('foo.com/dir%20path', @custom_domain_path_encoded_spaces.host_and_path_without_trailing_slash)
    end

    def test_is_match_with_different_domain
      refute(@custom_domain_root_path.match?(Addressable::URI.parse('http://otherdomain.com/other/test.html')))
    end

    def test_is_match_with_different_port_number_should_be_ignored
      assert(@custom_domain_root_path.match?(Addressable::URI.parse('http://foo.com:3000/other/test.html')))
      assert(@custom_domain_root_path.match?(Addressable::URI.parse('http://foo.com:80/other/test.html')))
      assert(@custom_domain_root_path.match?(Addressable::URI.parse('http://foo.com/other/test.html')))
    end

    def test_is_match_with_domain_containing_substring_should_be_false
      refute(@custom_domain_root_path.match?(Addressable::URI.parse('http://en.foo.com/other/test.html')))
    end

    def test_is_match_with_same_domain_should_be_true
      assert(@custom_domain_root_path.match?(Addressable::URI.parse('http://foo.com/other/test.html')))
    end

    def test_is_match_with_same_domain_different_casing_should_be_true
      assert(@custom_domain_root_path.match?(Addressable::URI.parse('http://foo.com/other/test.html')))
    end

    def test_is_match_with_path_starts_with_custom_path_should_be_true
      assert(@custom_domain_root_path.match?(Addressable::URI.parse('http://foo.com')))
      assert(@custom_domain_root_path.match?(Addressable::URI.parse('http://foo.com/')))
      assert(@custom_domain_root_path.match?(Addressable::URI.parse('http://foo.com/other/test.html?foo=bar')))

      assert(@custom_domain_with_path_no_trailing_slash.match?(Addressable::URI.parse('http://foo.com/path')))
      assert(@custom_domain_with_path_no_trailing_slash.match?(Addressable::URI.parse('http://foo.com/path/')))
      assert(@custom_domain_with_path_no_trailing_slash.match?(Addressable::URI.parse('http://foo.com/path/other/test.html?foo=bar')))

      assert(@custom_domain_with_path_trailing_slash.match?(Addressable::URI.parse('http://foo.com/path')))
      assert(@custom_domain_with_path_trailing_slash.match?(Addressable::URI.parse('http://foo.com/path/')))
      assert(@custom_domain_with_path_trailing_slash.match?(Addressable::URI.parse('http://foo.com/path/other/test.html?foo=bar')))

      assert(@custom_domain_path_encoded_spaces.match?(Addressable::URI.parse('http://foo.com/dir%20path')))
      assert(@custom_domain_path_encoded_spaces.match?(Addressable::URI.parse('http://foo.com/dir%20path?foo=bar')))
    end

    def test_is_match_with_path_matches_substring_should_be_false
      refute(@custom_domain_with_path_no_trailing_slash.match?(Addressable::URI.parse('http://foo.com/pathsuffix/other/test.html')))
      refute(@custom_domain_with_path_trailing_slash.match?(Addressable::URI.parse('http://foo.com/pathsuffix/other/test.html')))
      refute(@custom_domain_path_encoded_spaces.match?(Addressable::URI.parse('http://foo.com/dir%20pathsuffix/other/test.html')))
    end

    def test_is_match_with_path_matches_custom_path_as_suffix_should_be_false
      refute(@custom_domain_with_path_no_trailing_slash.match?(Addressable::URI.parse('http://foo.com/images/path/foo.png')))
      refute(@custom_domain_with_path_trailing_slash.match?(Addressable::URI.parse('http://foo.com/images/path/foo.png')))
    end
  end
end
