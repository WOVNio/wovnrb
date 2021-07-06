require 'rack'
require 'wovnrb/api_translator'
require 'wovnrb/headers'
require 'wovnrb/store'
require 'wovnrb/lang'
require 'wovnrb/services/html_converter'
require 'wovnrb/services/html_replace_marker'
require 'nokogumbo'
require 'active_support'
require 'json'
require 'wovnrb/helpers/nokogumbo_helper'
require 'wovnrb/text_caches/cache_base'
require 'wovnrb/railtie' if defined?(Rails)
require 'wovnrb/version'

module Wovnrb
  class Interceptor
    def initialize(app, opts = {})
      @app = app
      @store = Store.instance
      opts = opts.transform_keys(&:to_s)
      @store.update_settings(opts)
      CacheBase.set_single(@store.settings)
    end

    def call(env)
      # disabled by previous Rack middleware
      return @app.call(env) if Rack::Request.new(env).params['wovn_disable'] == true

      @store.settings.clear_dynamic_settings!
      return @app.call(env) unless Store.instance.valid_settings?

      @env = env
      headers = Headers.new(env, @store.settings)
      default_lang = @store.settings['default_lang']
      return @app.call(env) if @store.settings['test_mode'] && @store.settings['test_url'] != headers.url

      # redirect if the path is set to the default language (for SEO purposes)
      if headers.path_lang == default_lang
        redirect_headers = headers.redirect(default_lang)
        return [307, redirect_headers, ['']]
      end

      # if path containing language code is ignored, do nothing
      if headers.lang_code != default_lang && ignore_path?(headers.unmasked_pathname_without_trailing_slash)
        status, res_headers, body = @app.call(env)

        return output(headers, status, res_headers, body)
      end
      # pass to application
      status, res_headers, body = @app.call(headers.request_out)

      # disabled by next Rack middleware
      return output(headers, status, res_headers, body) unless res_headers['Content-Type'] =~ /html/

      request = Rack::Request.new(env)

      return output(headers, status, res_headers, body) if request.params['wovn_disable'] == true

      @store.settings.update_dynamic_settings!(request.params)
      return output(headers, status, res_headers, body) if ignore_path?(headers.pathname)

      body = switch_lang(headers, body) unless status.to_s =~ /^1|302/

      content_length = 0
      body.each { |b| content_length += b.respond_to?(:bytesize) ? b.bytesize : 0 }
      res_headers['Content-Length'] = content_length.to_s

      output(headers, status, res_headers, body)
    end

    def switch_lang(headers, body)
      translated_body = []

      # Must use `.each` for to support multiple-chunks in Sinatra
      string_body = ''
      body.each { |chunk| string_body += chunk }
      html_body = Helpers::NokogumboHelper.parse_html(string_body)

      if !wovn_ignored?(html_body) && !amp_page?(html_body)
        html_converter = HtmlConverter.new(html_body, @store, headers)

        if needs_api?(html_body, headers)
          converted_html, marker = html_converter.build_api_compatible_html
          translated_content = ApiTranslator.new(@store, headers).translate(converted_html)
          translated_body.push(marker.revert(translated_content))
        else
          string_body = html_converter.build if html_body.html?
          translated_body.push(string_body)
        end
      else
        translated_body.push(string_body)
      end

      body.close if body.respond_to?(:close)
      translated_body
    end

    private

    def output(headers, status, res_headers, body)
      headers.out(res_headers)
      [status, res_headers, body]
    end

    def needs_api?(html_body, headers)
      headers.lang_code != @store.settings['default_lang'] &&
        (html_body.html? || @store.settings['translate_fragment'])
    end

    def wovn_ignored?(html_body)
      !html_body.xpath('//html[@wovn-ignore or @data-wovn-ignore]').empty?
    end

    def ignore_path?(path)
      @store.settings['ignore_globs'].ignore?(path)
    end

    # Checks if a given HTML body is an Accelerated Mobile Page (AMP).
    # To do so, it looks at the required attributes for the HTML tag:
    # https://www.ampproject.org/docs/tutorials/create/basic_markup.
    #
    # @param {Nokogiri::HTML5::Document} body The HTML body to check.
    #
    # @returns {Boolean} True is the HTML body is an AMP, false otherwise.
    def amp_page?(html_body)
      html_attributes = html_body.xpath('//html')[0].try(:attributes) || {}

      !!(html_attributes['amp'] || html_attributes["\u26A1"])
    end
  end
end
