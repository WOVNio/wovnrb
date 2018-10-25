require 'test_helper'

module Wovnrb
  class ApiTranslatorTest < WovnMiniTest
    # TODO: test extra custom_lang_aliases inserted too

    # def test_translate
      # assert_translation('test.html', 'test_translated.html', true, true)
    # end

    def test_translate_falls_back_to_original_body_if_exception
      Net::HTTP.any_instance.expects(:request).raises
      assert_translation('test.html', 'test_translated.html', false, false)
    end

    # def test_translate_falls_back_to_original_body_if_api_error
      # # TODO: create fake api error
      # assert_translation('test.html', 'test_translated.html', true, false)
    # end

    # def test_translate_falls_back_to_original_body_if_api_response_is_not_compressed
      # # TODO: create non compressed response
      # assert_translation('test.html', 'test_translated.html', true, false)
    # end

    private

    def assert_translation(original_html_fixture, translated_html_fixture, fake_request, success_expected)
      original_html = File.read("test/fixtures/html/#{original_html_fixture}")
      translated_html = File.read("test/fixtures/html/#{translated_html_fixture}")
      actual_translated_html = translate(original_html, translated_html, fake_request)

      if success_expected
        assert_equal(actual_translated_html, translated_html)
      else
        assert_equal(actual_translated_html, original_html)
      end
    end

    def translate(original_html, translated_html, fake_request)
      store = Wovnrb::Store.instance
      headers = Wovnrb::Headers.new(
        Wovnrb.get_env('url' => "http://fr.wovn.io/test"),
        Wovnrb.get_settings(
          'token' => '123456',
          'default_lang' => 'en',
          'url_pattern' => 'subdomain',
          'url_pattern_reg' => '^(?<lang>[^.]+).'
        )
      )
      api_translator = ApiTranslator.new(store, headers)
      translation_request_stub = stub_translation_api_request(store, headers, original_html, translated_html) if fake_request
      actual_translated_html = api_translator.translate(original_html)

      assert_requested(translation_request_stub, times: 1) if fake_request
      actual_translated_html
    end

    def stub_translation_api_request(store, headers, original_html, translated_html)
      cache_key = generate_cache_key(store, original_html)
      api_url = "https://wovn.global.ssl.fastly.net/v0/translation?cache_key=#{cache_key}"
      compressed_response = compress("{\"body\": #{translated_html}}")
      # TODO: stub based on data sent too
      stub = stub_request(:post, api_url).to_return(body: compressed_response)

      stub
    end

    def generate_cache_key(store, original_html)
      settings_hash = Digest::MD5.hexdigest(JSON.dump(store.settings))
      body_hash = Digest::MD5.hexdigest(original_html)

      CGI.escape("(token=123456&settings_hash=#{settings_hash}&body_hash=#{body_hash}&path=/test&lang=fr)")
    end

    def compress(string)
      gzip = Zlib::GzipWriter.new(StringIO.new)
      gzip << string
      gzip.close.string
    end
  end
end
