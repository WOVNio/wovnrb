class Wovnrb
  class ApiData
    def initialize(access_url, store)
      @access_url = access_url.gsub(/\/$/, '')
      @store = store
    end

    def get_data
      cache_key = to_key(@access_url)
      data = get_data_value(cache_key)
      JSON.parse(data)
    end

    private
    def get_data_value(cache_key)
      cache_value = CacheBase.get_single.get(cache_key)
      return cache_value if cache_value

      uri = build_api_uri
      begin
        response = get_from_api_server(uri)
      rescue => e
        response = '{}'
        WovnLogger.instance.error("API server GET request failed :\nurl: #{uri}\n#{e.message}")
      end

      # Always cache response, even when error returns to avoid DDOS
      CacheBase.get_single.put(cache_key, response)
      response
    end

    @@cache_prefix = 'api::cache::'
    def to_key(url)
      "#{@@cache_prefix}#{url}"
    end

    def build_api_uri
      t = CGI::escape(@store.settings['user_token'])
      u = CGI::escape(@access_url)
      URI.parse("#{@store.settings['api_url']}?token=#{t}&url=#{u}")
    end

    def get_from_api_server(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == 'https'
      http.open_timeout = @store.settings['api_timeout_seconds']
      http.read_timeout= @store.settings['api_timeout_seconds']
      response = http.start {
        http.get(uri.request_uri)
      }

      if response.code == '200'
        response.body
      else
        raise "Response Code is not success: #{response.code}"
      end
    end
  end
end
