require 'addressable'
require 'json'
require 'digest'

module Wovnrb
  class ApiTranslator
    def initialize(store, headers)
      @store = store
      @headers = headers
    end

    def translate(body)
      request_pathname = generate_request_path(body, lang)
      request_data = generate_request_data(body, lang)

      http = Net::HTTP.new(api_uri.host, api_uri.port)
      http.use_ssl = true if uri.scheme == 'https'
      http.open_timeout = @store.settings['api_timeout_seconds']
      http.read_timeout = @store.settings['api_timeout_seconds']

      api_response = http.start do
        headers = {
          'Accept-Encoding' => 'gzip',
          # TODO: 'application/octet-stream'
          'Content-Type' => 'application/x-www-form-urlencoded',
          'Content-Length' => request_data.bytesize
        }
        http.post(request_pathname, request_data, headers)
      end

      unless response.code == '200'
        # TODO: handle error
        return body
      end

      api_response.body
    end

    private

    def generate_request_path(body)
      "/translation?cache_key=#{generate_cache_key(body)}"
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

      # TODO: compress
      hash_to_data_string(data)
    end

    def generate_cache_key(body)
      cache_key_components = hash_to_data_string({
        'token' => token,
        'settings_hash' => settings_hash,
        'body_hash' => Digest::MD5.hexdigest(body),
        'path' => page_pathname,
        'lang' => lang_code
      )}

      Addressable::URI.encode("(#{cache_key_components})")
    end

    def api_uri
      Addressable::URI.parse(@store.settings['api_url'])
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
      @headers.unmasked_url
    end

    def page_pathname
      @headers.unmasked_pathname
    end

    def hash_to_data_string(data_hash)
      data_hash.map { |k, v| "#{k}=#{v}" }.join('&')
    end
  end
end
