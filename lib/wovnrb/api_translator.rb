require 'addressable'
require 'digest'
require 'json'
require 'zlib'

module Wovnrb
  class ApiTranslator
    def initialize(store, headers, uuid)
      @store = store
      @headers = headers
      @uuid = uuid
    end

    def translate(body)
      connection = prepare_connection
      request = prepare_request(body)

      begin
        response = connection.request(request)
      rescue => e
        WovnLogger.error("\"#{e.message}\" error occurred when contacting WOVNio translation API")
        return body
      end

      case response
      when Net::HTTPSuccess
        begin
          raw_response_body = @store.dev_mode? ? response.body : Zlib::GzipReader.new(StringIO.new(response.body)).read
        rescue Zlib::GzipFile::Error
          raw_response_body = response.body
        end

        begin
          JSON.parse(raw_response_body)['body'] || body
        rescue JSON::JSONError
          body
        end
      else
        WovnLogger.error("HTML-swapper call failed. Received \"#{response.message}\" from WOVNio translation API.")
        body
      end
    end

    private

    def prepare_connection
      connection = Net::HTTP.new(api_uri.host, api_uri.port)

      connection.open_timeout = api_timeout
      connection.read_timeout = api_timeout

      connection
    end

    def prepare_request(body)
      if @store.compress_api_requests?
        gzip_request(body)
      else
        json_request(body)
      end
    end

    def gzip_request(html_body)
      api_params = build_api_params(html_body)
      compressed_body = compress_request_data(api_params)
      request = Net::HTTP::Post.new(request_path(html_body), {
                                      'Accept-Encoding' => 'gzip',
                                      'Content-Type' => 'application/octet-stream',
                                      'Content-Encoding' => 'gzip',
                                      'Content-Length' => compressed_body.bytesize.to_s,
                                      'X-Request-Id' => @uuid
                                    })
      request.body = compressed_body

      request
    end

    def json_request(html_body)
      api_params = build_api_params(html_body)
      request = Net::HTTP::Post.new(request_path(html_body), {
                                      'Accept-Encoding' => 'gzip',
                                      'Content-Type' => 'application/json',
                                      'X-Request-Id' => @uuid
                                    })
      request.body = api_params.to_json

      request
    end

    def request_path(body)
      "#{api_uri.path}/translation?cache_key=#{cache_key(body)}"
    end

    def cache_key(body)
      cache_key_components = {
        'token' => token,
        'settings_hash' => settings_hash,
        'body_hash' => Digest::MD5.hexdigest(body),
        'path' => page_pathname,
        'lang' => lang_code,
        'version' => "wovnrb_#{VERSION}"
      }.map { |k, v| "#{k}=#{v}" }.join('&')

      CGI.escape("(#{cache_key_components})")
    end

    def build_api_params(body)
      result = {
        'url' => page_url,
        'token' => token,
        'lang_code' => lang_code,
        'url_pattern' => url_pattern,
        'lang_param_name' => lang_param_name,
        'product' => 'WOVN.rb',
        'version' => VERSION,
        'body' => body
      }

      result['custom_lang_aliases'] = JSON.dump(custom_lang_aliases) unless custom_lang_aliases.empty?

      result
    end

    def compress_request_data(data_hash)
      encoded_data_components = data_hash.map do |key, value|
        "#{key}=#{CGI.escape(value)}"
      end

      gzip = Zlib::GzipWriter.new(StringIO.new)
      gzip << encoded_data_components.join('&')
      gzip.close.string
    end

    def api_uri
      Addressable::URI.parse("#{@store.settings['api_url']}/v0")
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

    def lang_param_name
      @store.settings['lang_param_name']
    end

    def custom_lang_aliases
      @store.settings['custom_lang_aliases']
    end

    def page_url
      "#{@headers.protocol}://#{@headers.url}"
    end

    def page_pathname
      @headers.pathname_with_trailing_slash_if_present
    end
  end
end
