require 'wovnrb'
#require 'test/unit'
#require 'test/unit/notify'
require 'minitest/autorun'

class TestLang < Minitest::Test

  def test_langs_exist
    refute_nil(Wovnrb::Lang::LANG)
  end

  def test_keys_exist
    Wovnrb::Lang::LANG.each do |k, l|
      assert(l.has_key?(:name))
      assert(l.has_key?(:code))
      assert(l.has_key?(:en))
      assert_equal(k, l[:code])
    end
  end

  def test_get_code_with_valid_code
    assert_equal('ms', Wovnrb::Lang.get_code('ms'))
  end

  def test_get_code_with_valid_english_name
    assert_equal('pt', Wovnrb::Lang.get_code('Portuguese'))
  end

  def test_get_code_with_valid_native_name
    assert_equal('hi', Wovnrb::Lang.get_code('हिन्दी'))
  end

  def test_get_code_with_invalid_name
    assert_equal(nil, Wovnrb::Lang.get_code('WOVN4LYFE'))
  end

  def test_get_code_with_empty_string
    assert_equal(nil, Wovnrb::Lang.get_code(''))
  end

  def test_get_code_with_nil
    assert_equal(nil, Wovnrb::Lang.get_code(nil))
  end

end
