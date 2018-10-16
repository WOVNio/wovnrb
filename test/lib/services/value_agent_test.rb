require 'test_helper'
require 'wovnrb/services/value_agent'

module Wovnrb
  class ValueAgentTest < WovnMiniTest
    def test_normalize_text_with_spaces
      assert_equal('test string', ValueAgent.normalize_text('  test string  '))
    end

    def test_normalize_text_without_spaces
      assert_equal('foobar', ValueAgent.normalize_text('foobar'))
    end

    def test_normalize_text_with_japanese_sapces
      assert_equal('おはよう　ございます', ValueAgent.normalize_text('　おはよう　ございます　　'))
    end

    def test_normalize_text_with_newlines
      assert_equal('こんにちは さようなら', ValueAgent.normalize_text("\nこんにちは\nさようなら\n"))
    end

    def test_normalize_text_with_replacement_char
      assert_equal("2011年には地下1\b階・地上4\b階の", ValueAgent.normalize_text("\n2011年には地下1�階・地上4�階の\n"))
    end

    def test_normalize_text_with_nbsp
      nbsp = "\u00A0"
      assert_equal("hello,#{nbsp}hello", ValueAgent.normalize_text("#{nbsp}hello,#{nbsp}hello#{nbsp}"))
    end
  end
end

