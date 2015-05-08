require 'pry'
module Wovnrb

  class Store

    def initialize
      @settings = 
        {
          :user_token => '',
          #:url_pattern => '/(?<lang>[^/.]+)(/|$)',
          :url_pattern => '^(?<lang>[^.]+)\.'
        }
      @settings_loaded = false
    end

    def get_settings
      if !@settings_loaded
        if Rails.configuration.respond_to? :wovnrb
          @settings.merge!(Rails.configuration.wovnrb)
        end
        @settings_loaded = true
      end
      @settings
    end

    def image_src_prefix(src)
      "http://st.wovn.io/elm_img/USER_ID/PAGE_ID/"
    end

    def get_values(url)
      url = 'http://wovn.io'
      user_token = self.get_settings[:user_token]
      user_token = 'lYWQ9'
      redis_key = 'WOVN:BACKEND:STORAGE:' + url + ':' + user_token
      redis = Redis.new(host: 'rs1.wovn.io', port: '6379')
      vals = redis.get(redis_key) || '{}'
      vals = JSON.parse(vals)
      #f = File.open('./values/values', 'r')
      #return JSON.parse(f.read)
      #f.close
    end

  end

end
