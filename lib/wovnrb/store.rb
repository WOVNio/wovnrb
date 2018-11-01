require 'net/http'
require 'uri'
require 'cgi'
require 'singleton'
require 'wovnrb/services/wovn_logger'
require 'wovnrb/services/glob'
require 'wovnrb/settings'
require 'active_support'
require 'active_support/core_ext'

module Wovnrb
  class Store
    include Singleton

    def self.default_settings
      Settings.new.merge({
        'project_token' => '',
        'log_path' => 'log/wovn_error.log',
        'ignore_paths' => [],
        'ignore_globs' => [],
        'url_pattern' => 'path',
        'url_pattern_reg' => "/(?<lang>[^/.?]+)",
        'query' => [],
        'ignore_class' => [],
        'api_url' => 'https://wovn.global.ssl.fastly.net/v0/',
        'api_timeout_seconds' => 0.5,
        'default_lang' => 'en',
        'supported_langs' => ['en'],
        'test_mode' => false,
        'test_url' => '',
        'cache_megabytes' => nil,
        'ttl_seconds' => nil,
        'use_proxy' => false,  # use env['HTTP_X_FORWARDED_HOST'] instead of env['HTTP_HOST'] and env['SERVER_NAME'] when this setting is true.
        'custom_lang_aliases' => {},
        'translate_fragment' => true
      })
    end

    def initialize
      reset
    end

    # Reset @settings and @config_loaded variables to default.
    #
    # @return [nil]
    def reset
      @settings = Store.default_settings
      # When Store is initialized, the Rails.configuration object is not yet initialized
      @config_loaded = false
    end

    # Returns true or false based on whether the token is valid or not
    #
    # @return [Boolean] Returns true if the token is valid, and false if it is not
    def valid_token?(token)
      return !token.nil? && (token.length == 5 || token.length == 6)
    end

    # Returns true or false based on whether the settings are valid or not, logs any invalid settings to ../error.log
    #
    # @return [Boolean] Returns true if the settings are valid, and false if they are not
    def valid_settings?
      valid = true
      errors = [];
      #if valid_token?(!settings.has_key?('project_token') || settings['project_token'].length < 5 || settings['project_token'].length > 6
      if !valid_token?(settings['project_token'])
        errors.push("Project token #{settings['project_token']} is not valid.")
      end
      if settings.has_key?('ignore_paths') && !settings['ignore_paths'].kind_of?(Array)
        errors.push("Ignore Paths #{settings['ignore_paths']} should be Array.")
      end
      if !settings.has_key?('url_pattern') || settings['url_pattern'].length == 0
        errors.push("Url pattern #{settings['url_pattern']} is not valid.")
      end
      if !settings.has_key?('query') || !settings['query'].kind_of?(Array)
        errors.push("query config #{settings['query']} is not valid.")
      end
      if !settings.has_key?('ignore_class') || !settings['ignore_class'].kind_of?(Array)
        errors.push("ignore_class config #{settings['ignore_class']} should be Array.")
      end
      if !settings.has_key?('api_url') || settings['api_url'].length == 0
        errors.push("API URL is not configured.")
      end
      if !settings.has_key?('default_lang') || settings['default_lang'].nil?
        errors.push("Default lang #{settings['default_lang']} is not valid.")
      end
      if !settings.has_key?('supported_langs') || !settings['supported_langs'].kind_of?(Array) || settings['supported_langs'].size < 1
        errors.push("Supported langs configuration is not valid.")
      end
      if !settings.has_key?('custom_lang_aliases') || !settings['custom_lang_aliases'].kind_of?(Hash)
        errors.push("Custom lang aliases is not valid.")
      end
      # log errors
      if errors.length > 0
        valid = false
        errors.each do |e|
          WovnLogger.instance.error(e)
        end
      end
      return valid
    end

    # Returns the settings object, pulling from Rails config the first time this is called
    #
    def settings
      load_settings unless @config_loaded
      @settings
    end

    # Load Rails config.wovnrb
    #
    def load_settings
      if Object.const_defined?('Rails') && Rails.configuration.respond_to?(:wovnrb)
        @config_loaded = true
        update_settings(Rails.configuration.wovnrb)
      end
    end

    def update_settings(new_settings)
      load_settings unless @config_loaded
      if !new_settings.nil?
        @settings.merge!(new_settings.stringify_keys)
        format_settings
      end
    end

    def format_settings
      if @settings.has_key?('custom_lang_aliases')
        stringify_keys! @settings['custom_lang_aliases']
      end

      @settings['default_lang'] = Lang.get_code(@settings['default_lang'])
      if !@settings.has_key?('supported_langs')
        @settings['supported_langs'] = [@settings['default_lang']]
      end

      if @settings.has_key?('user_token') && @settings['project_token'].empty?
        @settings['project_token'] = @settings['user_token']
      end
      @settings.delete('user_token')

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
    end

    def custom_lang_aliases
      @setttings['custom_lang_aliases'] || {}
    end

    def default_lang
      @settings['default_lang']
    end

    def default_lang_alias
      custom_alias = custom_lang_aliases[default_lang]
      custom_alias ? custom_alias : default_lang
    end

    def supported_langs
      @settings['supported_langs'] || []
    end

    def wovn_host
      if @settings['wovn_dev_mode']
        'dev-wovn.io:3000'
      else
        'wovn.io'
      end
    end

    private

    def stringify_keys!(h)
      h.keys.each do |k|
        h[k.to_s] = h.delete(k)
      end
    end
  end
end
