require 'wovnrb'
require 'minitest/autorun'

class TestHeaders < Minitest::Test
  def get_settings(options={})
    settings = {}
    settings['user_token'] = 'OHYx9'
    settings['url_pattern_name'] = 'path'
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
    #env['rack.url_scheme'] = 
    #env['HTTP_HOST'] = 
    #env['REQUEST_URI'] = 
    #env['SERVER_NAME'] = 
    #env['HTTP_COOKIE'] = 
    #env['HTTP_ACCEPT_LANGUAGE'] = 
    #env['QUERY_STRING'] = 
    #env['ORIGINAL_FULLPATH'] = 
    #env['HTTP_REFERER'] = 
    #env['REQUEST_PATH'] = 
    #env['PATH_INFO'] = 

    return env.merge(options)
  end

  def test_initialize
    #Wovnrb::Headers.new(, {})
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
