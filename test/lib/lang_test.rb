require 'test_helper'

module Wovnrb
  class LangTest < WovnMiniTest
    def test_langs_exist
      refute_nil(Wovnrb::Lang::LANG)
    end

    def test_keys_exist
      Wovnrb::Lang::LANG.each do |k, l|
        assert(l.key?(:name))
        assert(l.key?(:code))
        assert(l.key?(:en))
        assert_equal(k, l[:code])
      end
    end

    def test_iso_639_1_normalization
      Wovnrb::Lang::LANG.each_value do |l|
        case l[:code]
        when 'zh-CHS'
          assert_equal('zh-Hans',  Lang.iso_639_1_normalization('zh-CHS'))
        when 'zh-CHT'
          assert_equal('zh-Hant',  Lang.iso_639_1_normalization('zh-CHT'))
        else
          assert_equal(l[:code], Lang.iso_639_1_normalization(l[:code]))
        end
      end
    end

    def test_get_code_with_valid_code
      assert_equal('ms', Wovnrb::Lang.get_code('ms'))
    end

    def test_get_code_with_capital_letters
      assert_equal('zh-CHT', Wovnrb::Lang.get_code('zh-cht'))
    end

    def test_get_code_with_valid_english_name
      assert_equal('pt', Wovnrb::Lang.get_code('Portuguese'))
    end

    def test_get_code_with_valid_native_name
      assert_equal('hi', Wovnrb::Lang.get_code('हिन्दी'))
    end

    def test_get_code_with_invalid_name
      assert_nil(Wovnrb::Lang.get_code('WOVN4LYFE'))
    end

    def test_get_code_with_empty_string
      assert_nil(Wovnrb::Lang.get_code(''))
    end

    def test_get_code_with_nil
      assert_nil(Wovnrb::Lang.get_code(nil))
    end
  end
end
