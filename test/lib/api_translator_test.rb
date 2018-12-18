require 'test_helper'

module Wovnrb
  class ApiTranslatorTest < WovnMiniTest
    def test_translate
      assert_translation('test.html', 'test_translated.html', true)
    end

    def test_translate_falls_back_to_original_body_if_exception
      Net::HTTP.any_instance.expects(:request).raises
      assert_translation('test.html', 'test_translated.html', false, nil)
    end

    def test_translate_falls_back_to_original_body_if_api_error
      assert_translation('test.html', 'test_translated.html', false, status_code: 500)
    end

    def test_translate_falls_back_to_original_body_if_api_response_is_not_compressed
      assert_translation('test.html', 'test_translated.html', false, encoding: 'unknown')
    end

    def test_translate_accepts_uncompressed_response_from_api_in_dev_mode
      store = Wovnrb::Store.instance.update_settings({ 'wovn_dev_mode' => true })

      assert_translation('test.html', 'test_translated.html', true, encoding: 'text/json')
    end

    private

    def assert_translation(original_html_fixture, translated_html_fixture, success_expected, response = { encoding: 'gzip', status_code: 200 })
      original_html = File.read("test/fixtures/html/#{original_html_fixture}")
      translated_html = File.read("test/fixtures/html/#{translated_html_fixture}")
      actual_translated_html = translate(original_html, translated_html, response)

      if success_expected
        assert_equal(actual_translated_html, translated_html)
      else
        assert_equal(actual_translated_html, original_html)
      end
    end

    def translate(original_html, translated_html, response)
      settings = {
        'project_token' => '123456',
        'custom_lang_aliases' => { 'ja' => 'Japanese' },
        'default_lang' => 'en',
        'url_pattern' => 'subdomain',
        'url_pattern_reg' => '^(?<lang>[^.]+).'
      }
      store = Wovnrb::Store.instance
      store.update_settings(settings)
      headers = Wovnrb::Headers.new(
        Wovnrb.get_env('url' => 'http://fr.wovn.io/test'),
        Wovnrb.get_settings(settings)
      )
      api_translator = ApiTranslator.new(store, headers)
      translation_request_stub = stub_translation_api_request(store, headers, original_html, translated_html, response)

      actual_translated_html = api_translator.translate(original_html)
      assert_requested(translation_request_stub, times: 1) if translation_request_stub
      actual_translated_html
    end

    def stub_translation_api_request(store, headers, original_html, translated_html, response)
      if response
        cache_key = generate_cache_key(store, original_html)
        api_host = if store.dev_mode?
                     'dev-wovn.io:3001'
                   else
                     'wovn.global.ssl.fastly.net'
                   end
        api_url = "http://#{api_host}/v0/translation?cache_key=#{cache_key}"
        compressed_data = compress(generate_data(original_html))
        headers = {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip',
          'Content-Length' => compressed_data.bytesize,
          'Content-Type' => 'application/octet-stream',
          'User-Agent' => 'Ruby'
        }
        stub_response_json = "{\"body\":\"#{translated_html.gsub("\n", '\n')}\"}"
        stub_response = if store.dev_mode?
                          stub_response_json
                        else
                          compress(stub_response_json)
                        end
        response_headers = { 'Content-Encoding' => response[:encoding] || 'gzip' }
        stub = stub_request(:post, api_url)
               .with(body: compressed_data, headers: headers)
               .to_return(status: response[:status_code] || 200, body: stub_response, headers: response_headers)

        stub
      end
    end

    def generate_cache_key(store, original_html)
      settings_hash = Digest::MD5.hexdigest(JSON.dump(store.settings))
      body_hash = Digest::MD5.hexdigest(original_html)
      escaped_key = CGI.escape("token=123456&settings_hash=#{settings_hash}&body_hash=#{body_hash}&path=/test&lang=fr")

      "(#{escaped_key})"
    end

    def generate_data(original_html)
      data = {
        'url' => 'http://wovn.io/test',
        'token' => '123456',
        'lang_code' => 'fr',
        'url_pattern' => 'subdomain',
        'product' => 'WOVN.rb',
        'version' => VERSION,
        'body' => original_html,
        'custom_lang_aliases' => '{"ja":"Japanese"}'
      }

      data.map { |key, value| "#{key}=#{CGI.escape(value)}" }.join('&')
    end

    def compress(string)
      gzip = Zlib::GzipWriter.new(StringIO.new)
      gzip << string
      gzip.close.string
    end
  end
end
