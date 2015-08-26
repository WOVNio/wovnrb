require 'wovnrb/headers'
require 'minitest/autorun'
require 'pry'

class HeadersTest < Minitest::Test

  def test_initialize
    h = Wovnrb::Headers.new(get_env, get_settings)
    refute_nil(h)
  end

  # def test_initialize_env
  #   env = get_env
  #   h = Wovnrb::Headers.new(env, {})
  #   binding.pry
  #   #assert_equal(''
  # end

  def test_initialize_with_simple_url
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io'), get_settings)
    assert_equal('wovn.io/', h.url)
  end

  def test_initialize_with_query_language
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/?wovn=en'), get_settings('url_pattern' => 'query'))
    assert_equal('wovn.io/?', h.url)
  end

  def test_initialize_with_query_language_without_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io?wovn=en'), get_settings('url_pattern' => 'query'))
    assert_equal('wovn.io/?', h.url)
  end

  def test_initialize_with_path_language
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/en'), get_settings)
    assert_equal('wovn.io/', h.url)
  end

  def test_initialize_with_domain_language
    h = Wovnrb::Headers.new(get_env('url' => 'https://en.wovn.io/'), get_settings('url_pattern' => 'subdomain'))
    assert_equal('wovn.io/', h.url)
  end

  def test_initialize_with_path_language_with_query
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/en/?wovn=zh-CHS'), get_settings)
    assert_equal('wovn.io/?wovn=zh-CHS', h.url)
  end

  def test_initialize_with_domain_language_with_query
    h = Wovnrb::Headers.new(get_env('url' => 'https://en.wovn.io/?wovn=zh-CHS'), get_settings('url_pattern' => 'subdomain'))
    assert_equal('wovn.io/?wovn=zh-CHS', h.url)
  end

  def test_initialize_with_path_language_with_query_without_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://wovn.io/en?wovn=zh-CHS'), get_settings)
    assert_equal('wovn.io/?wovn=zh-CHS', h.url)
  end

  def test_initialize_with_domain_language_with_query_without_slash
    h = Wovnrb::Headers.new(get_env('url' => 'https://en.wovn.io?wovn=zh-CHS'), get_settings('url_pattern' => 'subdomain'))
    assert_equal('wovn.io/?wovn=zh-CHS', h.url)
  end

  def test_get_settings_valid
    # TODO: check if get_settings is valid (store.rb, valid_settings)
    # s = Wovnrb::Store.new
    # settings = get_settings
    
    # settings_stub = stub
    # settings_stub.expects(:has_key).with(:user_token).returns(settings["user_token"])
    # s.valid_settings?
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
