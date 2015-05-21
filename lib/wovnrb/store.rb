require 'redis'
require 'net/http'

module Wovnrb

  class Store
    attr_reader :settings


    def initialize
      @settings = 
        {
          'user_token' => '',
          # 'url_pattern_name' => 'query'
          # 'url_pattern' => "?.*wovn=(?<lang>[^&]+)(&|$)",
          'url_pattern_name' => 'path',
          'url_pattern' => "/(?<lang>[^/.?]+)",
          #'url_pattern_name' => 'subdomain',
          #'url_pattern_reg' => "^(?<lang>[^.]+)\.",
          'query' => [],
          'backend_host' => 'rs1.wovn.io',
          'backend_port' => '6379',
          'default_lang' => 'en',
          'supported_langs' => ['en'],
        }
      if Rails.configuration.respond_to? :wovnrb
        @settings.merge!(Rails.configuration.wovnrb.stringify_keys)
      end
      refresh_settings
    end

    def refresh_settings
# add timer so this only accesses redis once every 5 minutes etc
      user_token = @settings['user_token']
      #user_token = 'lYWQ9'
      redis_key = 'WOVN:BACKEND:SETTING::' + user_token
      cli = Redis.new(host: @settings['backend_host'], port: @settings['backend_port'])
      begin
        vals = cli.hgetall(redis_key) || {}
      rescue
        vals = {}
      end
      if vals.has_key?('query')
        vals['query'] = JSON.parse(vals['query'])
      end
      @settings.merge!(vals)
      @settings['backend_port'] = @settings['backend_port'].to_s
      @settings['default_lang'] = Lang.get_code(@settings['default_lang'])
      if !vals.has_key?('supported_langs')
        @settings['supported_langs'] = [@settings['default_lang']]
      end
      if @settings['url_pattern_name'] == 'path'
        @settings['url_pattern_reg'] = "/(?<lang>[^/.?]+)"
      elsif @settings['url_pattern_name'] == 'query'
        @settings['url_pattern_reg'] = '((\?.*&)|\?)wovn=(?<lang>[^&]+)(&|$)'
      end
      # JUST FOR TESTING!!!!
      @settings['supported_langs'] = ['ja', 'en', 'fr']
      # ^^^^^^^^^ TESTING ^^^^^^^^^
      @settings
    end

    def get_values(url)
      #url = 'http://wovn.io'
      user_token = @settings['user_token']
      #user_token = 'lYWQ9'
      redis_key = 'WOVN:BACKEND:STORAGE:' + url.gsub(/\/$/, '') + ':' + user_token
      vals = request_values(redis_key)
      if vals.empty?
        #uri = URI.parse('http://wovn.io/[USER_ID]/[PAGE_ID]')
        #Net::HTTP.get(uri)
      end
      vals
      #f = File.open('./values/values', 'r')
      #return JSON.parse(f.read)
      #f.close
    end

    def request_values(key)
    Rails.logger.info("*******************************************************")
    Rails.logger.info(key)
      cli = Redis.new(host: @settings['backend_host'], port: @settings['backend_port'])
    Rails.logger.info(@settings['backend_host'])
    Rails.logger.info(@settings['backend_port'])
      begin
        vals = cli.get(key) || '{}'
        vals = JSON.parse(vals)
      rescue
        vals = {}
      end
    end

  end

end
