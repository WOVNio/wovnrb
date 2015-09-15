require 'redis'
require 'net/http'
require 'socket'
require 'cgi'
require 'Logger' unless defined?(Logger)
require 'pry'

module Wovnrb

  class Store
    attr_reader :settings

    def initialize
      @settings = 
        {
          'user_token' => '',
          'secret_key' => '',
          # 'url_pattern' => 'query'
          # 'url_pattern_reg' => "?.*wovn=(?<lang>[^&]+)(&|$)",
          'url_pattern' => 'path',
          'url_pattern_reg' => "/(?<lang>[^/.?]+)",
          #'url_pattern' => 'subdomain',
          #'url_pattern_reg' => "^(?<lang>[^.]+)\.",
          'query' => [],
          'backend_host' => 'rs1.wovn.io',
          'backend_port' => '6379',
          'default_lang' => 'en',
          'supported_langs' => ['en'],
          'test_mode' => false,
          'test_url' => '',
        }
      # When Store is initialized, the Rails.configuration object is not yet initialized
      @config_loaded = false
    end

    # Returns true or false based on whether the settings are valid or not, logs any invalid settings to ../error.log
    #
    # @return [Boolean] Returns true if the settings are valid, and false if they are not
    def valid_settings?
      valid = true
      errors = [];
      if !settings.has_key?('user_token') || settings['user_token'].length < 5 || settings['user_token'].length > 6
        valid = false
        errors.push("User token #{settings['user_token']} is not valid.");
      end
      if !settings.has_key?('secret_key') || settings['secret_key'].length == 0 #|| settings['secret_key'].length < 5 || settings['secret_key'].length > 6
        valid = false
        errors.push("Secret key #{settings['secret_key']} is not valid.");
      end
      if !settings.has_key?('url_pattern') || settings['url_pattern'].length == 0
        valid = false
        errors.push("Url pattern #{settings['url_pattern']} is not valid.");
      end
      if !settings.has_key?('query') || !settings['query'].kind_of?(Array)
        valid = false
        errors.push("query config #{settings['query']} is not valid.");
      end
      if !settings.has_key?('backend_host') || settings['backend_host'].length == 0
        valid = false
        errors.push("Backend host is not configured.");
      end
      if !settings.has_key?('backend_port') || settings['backend_port'].length == 0
        valid = false
        errors.push("Backend port is not configured.");
      end
      if !settings.has_key?('default_lang') || settings['default_lang'].length == 0
        valid = false
        errors.push("Default lang #{settings['default_lang']} is not valid.");
      end
      if !settings.has_key?('supported_langs') || !settings['supported_langs'].kind_of?(Array) || settings['supported_langs'].size < 1
        valid = false
        errors.push("Supported langs configuration is not valid.");
      end
      # log errors
      if errors.length > 0
        logger = Logger.new('log/error.log')
        errors.each do |e|
          logger.error(e)
        end
      end
      return valid
    end

    # Returns the settings object, pulling from Rails config the first time this is called
    #
    # @return [Hash] The settings which are pulled from the config file given by the user and filled in by defaults
    def settings
      if !@config_loaded
        # get Rails config.wovnrb
        if Object.const_defined?('Rails') && Rails.configuration.respond_to?(:wovnrb)
          config_settings = Rails.configuration.wovnrb.stringify_keys
          if config_settings.has_key?('url_pattern')
            if config_settings['url_pattern'] == 'query' || config_settings['url_pattern'] == 'subdomain' || config_settings['url_pattern'] == 'path'
              config_settings['url_pattern'] = config_settings['url_pattern']
              config_settings.delete('url_pattern')
            end
          end
          @settings.merge!(Rails.configuration.wovnrb.stringify_keys)
        end

        # fix settings object
        @settings['backend_port'] = @settings['backend_port'].to_s
        @settings['default_lang'] = Lang.get_code(@settings['default_lang'])
        if !@settings.has_key?('supported_langs')
          @settings['supported_langs'] = [@settings['default_lang']]
        end
        if @settings['url_pattern'] == 'path'
          @settings['url_pattern_reg'] = "/(?<lang>[^/.?]+)"
        elsif @settings['url_pattern'] == 'query'
          @settings['url_pattern_reg'] = "((\\?.*&)|\\?)wovn=(?<lang>[^&]+)(&|$)"
        elsif @settings['url_pattern'] == 'subdomain'
          @settings['url_pattern_reg'] = "^(?<lang>[^.]+)\."
        end
        if @settings['test_mode'] != true || @settings['test_mode'] != 'on'
          @settings['test_mode'] = false
        else
          @settings['test_mode'] = true
        end

        @config_loaded = true
      end
      @settings
    end

    # Get the values for the passed in url
    #
    # @param url [String] The url to get the values for
    # @return [Hash] The values Hash for the passed in url
    def get_values(url)
      url = url.gsub(/\/$/, '')
      redis_key = 'WOVN:BACKEND:STORAGE:' + url + ':' + settings['user_token']
      settings['backend_host'] = 'localhost'
      cli = Redis.new(host: settings['backend_host'], port: settings['backend_port'])
      binding.pry
      begin
        vals = cli.get(redis_key) || '{}'
        vals = JSON.parse(vals)
      rescue
        logger = Logger.new('../error.log')
        logger.error("Redis GET request failed with the following parameters:\nhost: #{settings['backend_host']}\nport: #{settings['backend_port']}\nkey: #{redis_key}")
        vals = {}
      end
      if vals['expired'] || vals.empty?
        host = 'j.dev-wovn.io'
        post_data = "{\"user_token\":\"#{settings['user_token']}\", \"url\":\"#{CGI.escape(url)}\"}"
        headers = "Host: #{host}\r\nContent-Type: application/json;charset=UTF-8\r\nContent-Length: #{post_data.bytesize}\r\nConnection: close\r\n\r\n"
        s = TCPSocket.new(host, 3000)
        s.puts "POST /pages/cache_backend HTTP/1.1\r\n#{headers}#{post_data}"
        s.close
      end
      # handle this on the widget
      #if vals.empty?
      #  uri = URI.parse('http://api.wovn.io/v0/page/add')
      #  Net::HTTP.post_form(uri, :user_token => user_token, :secret_key => @settings['secret_key'], :url => url)
      #end
      vals
    end

  end

end
