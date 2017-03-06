require 'net/http'
require 'uri'
require 'cgi'
require 'singleton'
require 'wovnrb/services/wovn_logger'
require 'wovnrb/services/glob'

module Wovnrb
  class Store
    include Singleton

    def initialize
      @settings = {}
      @config_loaded = false
      reset
    end

    # Reset @settings and @config_loaded variables to default.
    #
    # @return [nil]
    def reset
      @settings =
        {
          'user_token' => '',
          'log_path' => 'log/wovn_error.log',
          'ignore_paths' => [],
          'ignore_globs' => [],
          'url_pattern' => 'path',
          'url_pattern_reg' => "/(?<lang>[^/.?]+)",
          'query' => [],
          'api_url' => 'https://api.wovn.io/v0/values',
          'api_timeout_seconds' => 0.5,
          'default_lang' => 'en',
          'supported_langs' => ['en'],
          'test_mode' => false,
          'test_url' => '',
          'cache_megabytes' => nil,
          'ttl_seconds' => nil,
          'use_proxy' => false,  # use env['HTTP_X_FORWARDED_HOST'] instead of env['HTTP_HOST'] and env['SERVER_NAME'] when this setting is true.
          'custom_lang_aliases' => {}
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
        errors.push("User token #{settings['user_token']} is not valid.")
      end
      if settings.has_key?('ignore_paths') && !settings['ignore_paths'].kind_of?(Array)
        valid = false
        errors.push("Ignore Paths #{settings['ignore_paths']} should be Array.")
      end
      if !settings.has_key?('url_pattern') || settings['url_pattern'].length == 0
        valid = false
        errors.push("Url pattern #{settings['url_pattern']} is not valid.")
      end
      if !settings.has_key?('query') || !settings['query'].kind_of?(Array)
        valid = false
        errors.push("query config #{settings['query']} is not valid.")
      end
      if !settings.has_key?('api_url') || settings['api_url'].length == 0
        valid = false
        errors.push("API URL is not configured.")
      end
      if !settings.has_key?('default_lang') || settings['default_lang'].length == 0
        valid = false
        errors.push("Default lang #{settings['default_lang']} is not valid.")
      end
      if !settings.has_key?('supported_langs') || !settings['supported_langs'].kind_of?(Array) || settings['supported_langs'].size < 1
        valid = false
        errors.push("Supported langs configuration is not valid.")
      end
      if !settings.has_key?('custom_lang_aliases') || !settings['custom_lang_aliases'].kind_of?(Hash)
        valid = false
        errors.push("Custom lang aliases is not valid.")
      end
      # log errors
      if errors.length > 0
        errors.each do |e|
          WovnLogger.instance.error(e)
        end
      end
      return valid
    end

    # Returns the settings object, pulling from Rails config the first time this is called
    #
    # @return [Hash] The settings which are pulled from the config file given by the user and filled in by defaults
    def settings(*opts)
      if !opts.first.nil?
        @settings.merge!(opts.first)
        @config_loaded = false
      end

      if @config_loaded
        return @settings
      end

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
      cleanSettings

      # fix settings object
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

      if @settings['ignore_paths'].kind_of?(Array)
        @settings['ignore_globs'] = @settings['ignore_paths'].map do |pattern|
          Glob.new(pattern)
        end
      end

      @config_loaded = true
      @settings
    end

    private
    def cleanSettings
      @settings['ignore_globs'] = []
    end
  end

end
