require 'rack'
require 'wovnrb/store'
require 'wovnrb/headers'
require 'wovnrb/lang'
require 'nokogumbo'
#require 'dom'
require 'json'
require 'wovnrb/helpers/nokogumbo_helper'
require 'wovnrb/api_data'
require 'wovnrb/text_caches/cache_base'
require 'wovnrb/html_replacers/replacer_base'
require 'wovnrb/html_replacers/link_replacer'
require 'wovnrb/html_replacers/text_replacer'
require 'wovnrb/html_replacers/meta_replacer'
require 'wovnrb/html_replacers/input_replacer'
require 'wovnrb/html_replacers/image_replacer'
require 'wovnrb/html_replacers/script_replacer'
require 'wovnrb/railtie' if defined?(Rails)
require 'wovnrb/version'

module Wovnrb
  class Interceptor
    def initialize(app, opts={})
      @app = app
      @store = Store.instance
      opts = opts.each_with_object({}){|(k,v),memo| memo[k.to_s]=v}
      @store.settings(opts)
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

      # ApiData creates request for external server, but cannot use async.
      # Because some server not allow multi thread. (env['async.callback'] is not supported at all Server).
      api_data = ApiData.new(headers.redis_url, @store)
      values = api_data.get_data

      url = {
        :protocol => headers.protocol,
        :host => headers.host,
        :pathname => headers.pathname
      }
      body = switch_lang(body, values, url, lang, headers) unless status.to_s =~ /^1|302/

      content_length = 0
      body.each { |b| content_length += b.respond_to?(:bytesize) ? b.bytesize : 0 }
      res_headers["Content-Length"] = content_length.to_s

      output(headers, status, res_headers, body)
    end

    def switch_lang(body, values, url, lang=@store.settings['default_lang'], headers)
      lang = Lang.new(lang)
      ignore_all = false
      new_body = []

      # generate full_body to intercept
      full_body = ''
      body.each { |b| full_body += b }

      [full_body].each do |b|
        # temporarily remove noscripts
        noscripts = []
        b_without_noscripts = b
        b.scan /<noscript.*?>.*?<\/noscript>/m do |match|
          noscript_identifier = "<noscript wovn-id=\"#{noscripts.count}\"></noscript>"
          noscripts << match
          b_without_noscripts = b_without_noscripts.sub(match, noscript_identifier)
        end

        d = Helpers::NokogumboHelper::parse_html(b_without_noscripts)

        # If this page has wovn-ignore in the html tag, don't do anything
        if ignore_all || !d.xpath('//html[@wovn-ignore]').empty? || is_amp_page?(d)
          ignore_all = true
          output = d.to_html(save_with: 0).gsub(/href="([^"]*)"/) { |m| "href=\"#{URI.decode($1)}\"" }
          put_back_noscripts!(output, noscripts)
          new_body.push(output)
          next
        end

        if have_data?(values)
          output = lang.switch_dom_lang(d, @store, values, url, headers)
        else
          ScriptReplacer.new(@store).replace(d, lang) if d.html?
          output = d.to_html(save_with: 0)
        end
        put_back_noscripts!(output, noscripts)
        new_body.push(output)
      end
      body.close if body.respond_to?(:close)
      new_body
    end

    private

    def output(headers, status, res_headers, body)
      headers.out(res_headers)
      [status, res_headers, body]
    end

    def have_data?(values)
      values.count > 0
    end

    def put_back_noscripts!(output, noscripts)
      noscripts.each_with_index do |noscript, index|
        noscript_identifier = "<noscript wovn-id=\"#{index}\"></noscript>"
        output.sub!(noscript_identifier, noscript)
      end
    end

    # Checks if a given HTML body is an Accelerated Mobile Page (AMP).
    # To do so, it looks at the required attributes for the HTML tag:
    # https://www.ampproject.org/docs/tutorials/create/basic_markup.
    #
    # @param {Nokogiri::HTML5::Document} body The HTML body to check.
    #
    # @returns {Boolean} True is the HTML body is an AMP, false otherwise.
    def is_amp_page?(body)
      html_attributes = body.xpath('//html')[0].try(:attributes) || {}

      html_attributes['amp'] || html_attributes["\u26A1"]
    end
  end
end
