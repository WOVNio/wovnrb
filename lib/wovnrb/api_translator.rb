require 'addressable'
require 'digest'
require 'json'
require 'zlib'

module Wovnrb
  class ApiTranslator
    def initialize(store, headers)
      @store = store
      @headers = headers
    end

    def translate(body)
      http = prepare_connection
      request = prepare_request(body)

      begin
        response = http.request(request)
      rescue => e
        # TODO: log???
        return body
      end

      case response
      when Net::HTTPSuccess
        if response.header['Content-Encoding'] == 'gzip'
          response_body = Zlib::GzipReader.new(StringIO.new(response.body)).read

          JSON.parse(response_body)['body'] || body
        else
          # TODO: log???
          body
        end
      else
        # TODO: log???
        body
      end
    end

    private

    def prepare_connection
      http = Net::HTTP.new(api_uri.host, api_uri.port)

      http.use_ssl = true if api_uri.scheme == 'https'
      http.open_timeout = api_timeout
      http.read_timeout = api_timeout

      http
    end

    def prepare_request(body)
      data = generate_request_data(body)
      headers = {
        'Accept-Encoding' => 'gzip',
        'Content-Type' => 'application/x-www-form-urlencoded'
      }
      request = Net::HTTP::Post.new(generate_request_path(body), headers)

      # TODO: compress
      request.set_form_data(data)

      request
    end

    def generate_request_path(body)
      "/v0/translation?cache_key=#{generate_cache_key(body)}"
    end

    def generate_request_data(body)
      data = {
        'url' => page_url,
        'token' => token,
        'lang_code' => lang_code,
        'url_pattern' => url_pattern,
        'product' => 'WOVN.rb',
        'version' => VERSION,
        'body' => body
      }

      unless custom_lang_aliases.empty?
        data.merge!('custom_lang_aliases' => JSON.dump(custom_lang_aliases))
      end

      data
    end

    def generate_cache_key(body)
      cache_key_components = {
        'token' => token,
        'settings_hash' => settings_hash,
        'body_hash' => Digest::MD5.hexdigest(body),
        'path' => page_pathname,
        'lang' => lang_code
      }.map { |k, v| "#{k}=#{v}" }.join('&')

      Addressable::URI.encode("(#{cache_key_components})")
    end

    def api_uri
      Addressable::URI.parse(@store.settings['api_url'])
    end

    def api_timeout
      @store.settings['api_timeout_seconds']
    end

    def settings_hash
      Digest::MD5.hexdigest(JSON.dump(@store.settings))
    end

    def token
      @store.settings['project_token']
    end

    def lang_code
      @headers.lang_code
    end

    def url_pattern
      @store.settings['url_pattern']
    end

    def custom_lang_aliases
      @store.settings['custom_lang_aliases']
    end

    def page_url
      @headers.url_with_trailing_slash_if_present
    end

    def page_pathname
      @headers.pathname_with_trailing_slash_if_present
    end
  end
end
