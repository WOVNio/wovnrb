require 'wovnrb/headers'
require 'wovnrb/lang'
require 'wovnrb/store'
require 'minitest/autorun'


module Wovnrb
  class WovnMiniTest < Minitest::Test
    def before_setup
      super
      Wovnrb::Store.instance.reset
    end
  end

  class LogMock
    attr_accessor :errors

    def self.mock_log
      Store.instance.settings['log_path'] = nil
      mock = self.new
      WovnLogger.instance.set_logger(mock)
      mock
    end

    def initialize
      @errors= []
    end

    def error(message)
      @errors << message
    end
  end

  def get_settings(options={})
    settings = {}
    settings['user_token'] = 'OHYx9'
    settings['url_pattern'] = 'path'
    settings['url_pattern_reg'] = "/(?<lang>[^/.?]+)"
    settings['query'] = []
    settings['api_url'] = 'http://localhost/v0/values'
    settings['default_lang'] = 'en'
    settings['supported_langs'] = ['en', 'ja']
    settings['secret_key'] = 'secret_key'
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
  module_function :get_env, :get_settings
end
