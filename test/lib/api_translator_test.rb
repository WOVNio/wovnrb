require 'test_helper'

module Wovnrb
  REQUEST_UUID = 'ABCD'.freeze

  class ApiTranslatorTest < WovnMiniTest
    def test_translate
      assert_translation('test.html', 'test_translated.html', true)
    end

    def test_translate_falls_back_to_original_body_if_exception
      Net::HTTP.any_instance.expects(:request).raises
      assert_translation('test.html', 'test_translated.html', false, api_response: nil)
    end

    def test_translate_falls_back_to_original_body_if_api_error
      assert_translation('test.html', 'test_translated.html', false, api_response: { encoding: 'text/json', status: 500 })
    end

    def test_translate_continues_if_api_response_is_not_compressed
      assert_translation('test.html', 'test_translated.html', true, api_response: { encoding: 'unknown', status: 200 }, compress_data: false)
    end

    def test_translate_continues_if_api_response_is_compressed
      assert_translation('test.html', 'test_translated.html', true, api_response: { encoding: 'unknown', status: 200 })
    end

    def test_translate_accepts_uncompressed_response_from_api_in_dev_mode
      Wovnrb::Store.instance.update_settings('wovn_dev_mode' => true)
      assert_translation('test.html', 'test_translated.html', true, api_response: { encoding: 'text/json', status: 200 }, compress_data: false)
    end

    def test_translate_without_api_compression_sends_json
      Wovnrb::Store.instance.update_settings('compress_api_requests' => false)
      original_status_code = 201
      sut, _store, _headers = create_sut(status: original_status_code)
      html_body = 'foo'

      stub_request(:post, %r{http://wovn\.global\.ssl\.fastly\.net/v0/translation\?cache_key=.*})
        .to_return(status: 200, body: { 'body' => 'translated_body' }.to_json)

      sut.translate(html_body)

      assert_requested :post, %r{http://wovn\.global\.ssl\.fastly\.net/v0/translation\?cache_key=.*},
                       headers: {
                         'Accept' => '*/*',
                         'Accept-Encoding' => 'gzip',
                         'Content-Type' => 'application/json',
                         'User-Agent' => 'Ruby',
                         'X-Request-Id' => REQUEST_UUID
                       },
                       body: {
                         'url' => 'http://wovn.io/test',
                         'token' => '123456',
                         'lang_code' => 'fr',
                         'url_pattern' => 'subdomain',
                         'lang_param_name' => 'lang',
                         'translate_canonical_tag' => true,
                         'insert_hreflangs' => true,
                         'hreflang_x_default_lang' => nil,
                         'product' => 'WOVN.rb',
                         'version' => VERSION,
                         'page_status_code' => original_status_code,
                         'body' => 'foo',
                         'custom_lang_aliases' => { 'ja' => 'Japanese' }.to_json
                       }.to_json,
                       times: 1
    end

    def test_api_timeout_is_search_engine_user_higher_default
      settings = {
        'project_token' => '123456',
        'custom_lang_aliases' => { 'ja' => 'Japanese' },
        'default_lang' => 'en',
        'url_pattern' => 'subdomain',
        'url_pattern_reg' => '^(?<lang>[^.]+)\.',
        'lang_param_name' => 'lang'
      }
      store = Wovnrb::Store.instance
      store.update_settings(settings)
      headers = Wovnrb::Headers.new(
        Wovnrb.get_env('url' => 'http://fr.wovn.io/test', 'HTTP_USER_AGENT' => 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'),
        Wovnrb.get_settings(settings),
        UrlLanguageSwitcher.new(store)
      )
      api_translator = ApiTranslator.new(store, headers, REQUEST_UUID, 200)
      assert_equal(5.0, api_translator.send(:api_timeout))
    end

    def test_api_timeout_no_user_agent_use_normal_default
      settings = {
        'project_token' => '123456',
        'custom_lang_aliases' => { 'ja' => 'Japanese' },
        'default_lang' => 'en',
        'url_pattern' => 'subdomain',
        'url_pattern_reg' => '^(?<lang>[^.]+)\.',
        'lang_param_name' => 'lang'
      }
      store = Wovnrb::Store.instance
      store.update_settings(settings)
      env = Wovnrb.get_env('url' => 'http://fr.wovn.io/test')
      env.delete('HTTP_USER_AGENT')
      headers = Wovnrb::Headers.new(
        env,
        Wovnrb.get_settings(settings),
        UrlLanguageSwitcher.new(store)
      )
      api_translator = ApiTranslator.new(store, headers, REQUEST_UUID, 200)
      assert_equal(1.0, api_translator.send(:api_timeout))
    end

    private

    def assert_translation(original_html_fixture, translated_html_fixture, success_expected, original_response: { status: 200 }, api_response: { encoding: 'gzip', status: 200 }, compress_data: true)
      original_html = File.read("test/fixtures/html/#{original_html_fixture}")
      translated_html = File.read("test/fixtures/html/#{translated_html_fixture}")
      actual_translated_html = translate(original_html, translated_html, original_response, api_response, compress_data: compress_data)

      if success_expected
        assert_equal(actual_translated_html, translated_html)
      else
        assert_equal(actual_translated_html, original_html)
      end
    end

    def translate(original_html, translated_html, original_response, api_response, compress_data: true)
      api_translator, store, _headers = create_sut(original_response)
      translation_request_stub = stub_translation_api_request(store, original_html, translated_html, original_response, api_response, compress_data: compress_data)

      expected_api_timeout = store.settings['api_timeout_seconds']
      assert_equal(expected_api_timeout, api_translator.send(:api_timeout))
      actual_translated_html = api_translator.translate(original_html)
      assert_requested(translation_request_stub, times: 1) if translation_request_stub
      actual_translated_html
    end

    def create_sut(response)
      settings = {
        'project_token' => '123456',
        'custom_lang_aliases' => { 'ja' => 'Japanese' },
        'default_lang' => 'en',
        'url_pattern' => 'subdomain',
        'url_pattern_reg' => '^(?<lang>[^.]+)\.',
        'lang_param_name' => 'lang'
      }
      store = Wovnrb::Store.instance
      store.update_settings(settings)
      headers = Wovnrb::Headers.new(
        Wovnrb.get_env('url' => 'http://fr.wovn.io/test'),
        Wovnrb.get_settings(settings),
        UrlLanguageSwitcher.new(store)
      )
      status = if response
                 response[:status]
               else
                 200
               end
      api_translator = ApiTranslator.new(store, headers, REQUEST_UUID, status)

      [api_translator, store, headers]
    end

    def stub_translation_api_request(store, original_html, translated_html, original_response, api_response, compress_data: true)
      if api_response
        cache_key = generate_cache_key(store, original_html)
        api_host = if store.dev_mode?
                     'dev-wovn.io:3001'
                   else
                     'wovn.global.ssl.fastly.net'
                   end
        api_url = "http://#{api_host}/v0/translation?cache_key=#{cache_key}"
        expected_data = generate_data(original_html, original_response[:status])
        compressed_data = compress(expected_data)
        headers = {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip',
          'Content-Length' => compressed_data.bytesize,
          'Content-Type' => 'application/json',
          'Content-Encoding' => 'gzip',
          'User-Agent' => 'Ruby'
        }
        stub_response_json = "{\"body\":\"#{translated_html.gsub("\n", '\n')}\"}"
        stub_response = if compress_data
                          compress(stub_response_json)
                        else
                          stub_response_json
                        end
        response_headers = { 'Content-Encoding' => api_response[:encoding] || 'gzip' }
        stub_request(:post, api_url)
          .with(body: compressed_data, headers: headers)
          .to_return(status: api_response[:status] || 200, body: stub_response, headers: response_headers)

      end
    end

    def generate_cache_key(store, original_html)
      settings_hash = Digest::MD5.hexdigest(JSON.dump(store.settings))
      body_hash = Digest::MD5.hexdigest(original_html)
      escaped_key = CGI.escape("token=123456&settings_hash=#{settings_hash}&body_hash=#{body_hash}&path=/test&lang=fr&version=wovnrb_#{VERSION}")

      "(#{escaped_key})"
    end

    def generate_data(original_html, expected_status)
      data = {
        'url' => 'http://wovn.io/test',
        'token' => '123456',
        'lang_code' => 'fr',
        'url_pattern' => 'subdomain',
        'lang_param_name' => 'lang',
        'translate_canonical_tag' => true,
        'insert_hreflangs' => true,
        'hreflang_x_default_lang' => nil,
        'product' => 'WOVN.rb',
        'version' => VERSION,
        'page_status_code' => expected_status,
        'body' => original_html,
        'custom_lang_aliases' => '{"ja":"Japanese"}'
      }

      data.to_json
    end

    def compress(string)
      ActiveSupport::Gzip.compress(string)
    end
  end
end
