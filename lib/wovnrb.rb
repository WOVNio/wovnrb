require 'rack'
require 'wovnrb/api_translator'
require 'wovnrb/headers'
require 'wovnrb/store'
require 'wovnrb/lang'
require 'nokogumbo'
require 'active_support'
#require 'dom'
require 'json'
require 'wovnrb/helpers/nokogumbo_helper'
require 'wovnrb/text_caches/cache_base'
require 'wovnrb/railtie' if defined?(Rails)
require 'wovnrb/version'

module Wovnrb
  class Interceptor
    def initialize(app, opts={})
      @app = app
      @store = Store.instance
      opts = opts.each_with_object({}){|(k,v),memo| memo[k.to_s]=v}
      @store.update_settings(opts)
      CacheBase.set_single(@store.settings)
    end

    def call(env)
      @store.settings.clear_dynamic_settings!
      unless Store.instance.valid_settings?
        return @app.call(env)
      end
      @env = env
      headers = Headers.new(env, @store.settings)
      if @store.settings['test_mode'] && @store.settings['test_url'] != headers.url
        return @app.call(env)
      end
      #redirect if the path is set to the default language (for SEO purposes)
      if (headers.path_lang == @store.settings['default_lang'])
        redirect_headers = headers.redirect(@store.settings['default_lang'])
        return [307, redirect_headers, ['']]
      end
      lang = headers.lang_code

      # pass to application
      status, res_headers, body = @app.call(headers.request_out)

      unless res_headers["Content-Type"] =~ /html/
        return output(headers, status, res_headers, body)
      end

      request = Rack::Request.new(env)

      if request.params['wovn_disable'] == true
        return output(headers, status, res_headers, body)
      end

      @store.settings.update_dynamic_settings!(request.params)
      if @store.settings['ignore_globs'].any?{|g| g.match?(headers.pathname)}
        return output(headers, status, res_headers, body)
      end

      url = {
        :protocol => headers.protocol,
        :host => headers.host,
        :pathname => headers.pathname
      }
      body = switch_lang(body, url, lang, headers) unless status.to_s =~ /^1|302/

      content_length = 0
      body.each { |b| content_length += b.respond_to?(:bytesize) ? b.bytesize : 0 }
      res_headers["Content-Length"] = content_length.to_s

      output(headers, status, res_headers, body)
    end

    def switch_lang(body, values, url, lang=@store.settings['default_lang'], headers)
      translated_body = []
      string_body = body.reduce('') { |acc, chunk| acc += chunk }
      html_body = Helpers::NokogumboHelper::parse_html(string_body)

      if !wovn_ignored?(html_body)
        # TODO: insert fallback snippet

        if translatable?(html_body)
          # TODO: remove ignored content
          translated_content = ApiTranslator.new(@store, headers).translate(url, string_body, lang)
          # TODO: put back ignored content
          translated_body.push(translated_content)
        else
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

    def wovn_ignored?(body)
      !body.xpath('//html[@wovn-ignore]').empty?
    end

    def translatable?(body)
      (body.html? || @store.settings['translate_fragment']) && !amp?(body)
    end

    # Checks if a given HTML body is an Accelerated Mobile Page (AMP).
    # To do so, it looks at the required attributes for the HTML tag:
    # https://www.ampproject.org/docs/tutorials/create/basic_markup.
    #
    # @param {Nokogiri::HTML5::Document} body The HTML body to check.
    #
    # @returns {Boolean} True is the HTML body is an AMP, false otherwise.
    def amp?(body)
      html_attributes = body.xpath('//html')[0].try(:attributes) || {}

      html_attributes['amp'] || html_attributes["\u26A1"]
    end
  end
end
