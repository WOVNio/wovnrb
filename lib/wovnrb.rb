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
      opts = opts.each_with_object({}) { |(k, v), memo| memo[k.to_s] = v }
      @store.update_settings(opts)
      CacheBase.set_single(@store.settings)
    end

    def call(env)
      @store.settings.clear_dynamic_settings!
      return @app.call(env) unless Store.instance.valid_settings?

      @env = env
      headers = Headers.new(env, @store.settings)
      headers.trace('wDM init')
      return @app.call(env) if @store.settings['test_mode'] && @store.settings['test_url'] != headers.url

      # redirect if the path is set to the default language (for SEO purposes)
      if headers.path_lang == @store.settings['default_lang']
        redirect_headers = headers.redirect(@store.settings['default_lang'])
        return [307, redirect_headers, ['']]
      end

      # pass to application
      status, res_headers, body = @app.call(headers.request_out)
      res_headers['X-Wovn-Top'] = 'intercepted' if headers.debug_mode?
      headers.trace('receive from app: status ' + status.to_s)

      return output(headers, status, res_headers, body) unless res_headers['Content-Type'] =~ /html/

      request = Rack::Request.new(env)

      return output(headers, status, res_headers, body) if request.params['wovn_disable'] == true

      headers.trace('original token: ' + @store.settings['project_token'])
      @store.settings.update_dynamic_settings!(request.params)
      headers.trace('dynamic token: ' + @store.settings['project_token'])
      return output(headers, status, res_headers, body) if @store.settings['ignore_globs'].any? { |g| g.match?(headers.pathname) }

      headers.trace('switch lang')
      body = switch_lang(headers, body) unless status.to_s =~ /^1|302/

      res_headers = headers.apply_custom_http_headers(res_headers) if headers.debug_mode?

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
          headers.trace('process using API')
          converted_html, marker = html_converter.build_api_compatible_html
          headers.trace('API compatible html ready')
          investigate_apiready_content(converted_html, headers)
          translated_content = ApiTranslator.new(@store, headers).translate(converted_html)
          investigate_translated_content(translated_content, headers)
          translated_body.push(marker.revert(translated_content))
        else
          headers.trace('process without API')
          string_body = html_converter.build if html_body.html?
          translated_body.push(string_body)
        end
      else
        headers.trace('no html processing')
        translated_body.push(string_body)
      end
      headers.trace('html processing completed')

      body.close if body.respond_to?(:close)

      translated_body.push(headers.read_trace_as_html_comment)

      translated_body
    end

    private

    def investigate_apiready_content(html, headers)
      has_fallback_snippet = html.match?(/data-wovnio-type="fallback_snippet"/)
      headers.trace('API request has fallback snippet? ' + has_fallback_snippet.to_s)
    end

    def investigate_translated_content(html, headers)
      has_fallback_snippet = html.match?(/data-wovnio-type="fallback_snippet"/)
      headers.trace('API response has fallback snippet? ' + has_fallback_snippet.to_s)
    end

    def output(headers, status, res_headers, body)
      headers.out(res_headers)
      [status, res_headers, body]
    end

    def needs_api?(html_body, headers)
      headers.lang_code != @store.settings['default_lang'] &&
        (html_body.html? || @store.settings['translate_fragment'])
    end

    def wovn_ignored?(html_body)
      !html_body.xpath('//html[@wovn-ignore]').empty?
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
