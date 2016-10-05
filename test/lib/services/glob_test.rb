require 'test_helper'
require 'wovnrb/services/glob'

module Wovnrb
  class GlobTest < WovnMiniTest
    def test_match
      assert_equal(false, Glob.new('api/*').match?('api'))
      assert_equal(true, Glob.new('api/*').match?('api/'))
      assert_equal(true, Glob.new('api/*').match?('api/a'))
      assert_equal(false, Glob.new('api/*').match?('api/a/b'))
      assert_equal(true, Glob.new('api/*.html').match?('api/a.html'))
      assert_equal(false, Glob.new('api/*.html').match?('api/a/b.html'))
    end

    def test_match_2_star
      assert_equal(false, Glob.new('api/**/*').match?('api'))
      assert_equal(true, Glob.new('api/**/*').match?('api/'))
      assert_equal(true, Glob.new('api/**/*').match?('api/a'))
      assert_equal(true, Glob.new('api/**/*').match?('api/a/b'))
      assert_equal(true, Glob.new('api/**/*.html').match?('api/a.html'))
      assert_equal(true, Glob.new('api/**/*.html').match?('api/a/b.html'))
      assert_equal(false, Glob.new('api/**/*.html').match?('api/a/b'))
      assert_equal(true, Glob.new('api/**').match?('api/a'))
      assert_equal(true, Glob.new('api/**').match?('api/a/b.html'))
    end

    def test_match_regex_injection
      assert_equal(false, Glob.new('api/a?*').match?('api/a'))
      assert_equal(true, Glob.new('api/a?*').match?('api/a?'))
      assert_equal(true, Glob.new('api/a?*').match?('api/a?b'))
      assert_equal(false, Glob.new('api/**?').match?('api/a'))
      assert_equal(true, Glob.new('api/**?').match?('api/?'))
    end
  end
end