require 'cgi'
require 'json'
require 'net/http'
require 'uri'
require 'wovnrb/text_caches/cache_base'
require 'wovnrb/services/wovn_logger'

class Wovnrb
  class ApiData
    def initialize(store)
      @store = store
    end

    # Get data from backend API.
    #
    # @param access_url [String] page URL
    # @return [Hash] Data retrieved from API server
    def get_page_values(access_url)
      @access_url = access_url
      uri = build_page_values_uri
      data = get_data_value(uri)
      JSON.parse(data)
    end

    # Get data from Project Translation Text Search API.
    #
    # @param srcs [Array] search srcs
    # @param host [String] search host
    # @param target_lang [String] target language
    # @return [Hash] Data retrieved from API server
    def get_project_values(srcs, host, target_lang)
      @srcs, @host, @target_lang = srcs, host, target_lang
      uri = build_project_values_uri
      data = get_data_value(uri)
      JSON.parse(data)
    end

    private

    # Get data from API server.
    #
    # @param uri [URI] API server URI object
    # @return [Hash] Data retrieved from API server
    def get_data_value(uri)
      cache_key = to_key(uri.query)
      cache_value = CacheBase.get_single.get(cache_key)
      return cache_value if cache_value

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
    # Generate cache key.
    #
    # @param url [String] unique string of API request
    # @return [String] Cache key
    def to_key(url)
      "#{@@cache_prefix}#{url}"
    end

    # Generate URI object for backend API.
    #
    # @return [URI] URI object of backend API.
    def build_page_values_uri
      api_url = build_api_url('/values')
      t = CGI::escape(@store.settings['user_token'])
      u = CGI::escape(@access_url)
      api_url.query = "token=#{t}&url=#{u}"
      api_url
    end

    # Generate URI object for Project Translation Text Search API.
    #
    # @return [URI] URI object of Project Translation Text Search API.
    def build_project_values_uri
      api_url = build_api_url('/project/values')
      srcs = CGI::escape(@srcs.to_json)
      host = CGI::escape(@host)
      target_lang = CGI::escape(@target_lang)
      token = CGI::escape(@store.settings['user_token'])
      api_url.query = "srcs=#{srcs}&host=#{host}&target_lang=#{target_lang}&token=#{token}"
      api_url
    end

    # Generate base API URL by api_url setting and path.
    #
    # @param path [String] API path
    # @return [URI] URI object of API URL
    def build_api_url(path)
      api_url = URI.parse(@store.settings['api_url'])
      if md = api_url.path.match(/^\/v\d+/)
        api_url.path = md[0] + path  # use API version in api_url setting.
      else
        api_url.path = '/v0' + path
      end
      api_url
    end

    # Get HTTP response from API server.
    #
    # @param uri [URI] API server URI object
    # @return [String] Response body of API server request
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
