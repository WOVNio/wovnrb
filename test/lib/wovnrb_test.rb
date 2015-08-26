require 'wovnrb'
require 'wovnrb/headers'
require 'minitest/autorun'
require 'pry'

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

end
