require 'wovnrb/store'
require 'wovnrb/headers'
require 'wovnrb/lang'
require 'nokogumbo'
#require 'dom'
require 'json'
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

      if res_headers["Content-Type"] =~ /html/
        unless @store.settings['ignore_globs'].any?{|g| g.match?(headers.pathname)}
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
        end
      end

      headers.out(res_headers)
      [status, res_headers, body]
      #[status, res_headers, d.transform()]
    end

    def switch_lang(body, values, url, lang=@store.settings['default_lang'], headers)
      lang = Lang.new(lang)
      ignore_all = false
      new_body = []
      body.each do |b|
        # temporarily remove noscripts
        noscripts = []
        b_without_noscripts = b
        b.scan /<noscript.*?>.*?<\/noscript>/m do |match|
          noscript_identifier = "<noscript wovn-id=\"#{noscripts.count}\"></noscript>"
          noscripts << match
          b_without_noscripts = b_without_noscripts.sub(match, noscript_identifier)
        end
        d = Nokogiri::HTML5(b_without_noscripts)
        d.encoding = "UTF-8"

        # If this page has wovn-ignore in the html tag, don't do anything
        if ignore_all || !d.xpath('//html[@wovn-ignore]').empty?
          ignore_all = true
          output = d.to_html.gsub(/href="([^"]*)"/) { |m| "href=\"#{URI.decode($1)}\"" }
          new_body.push(output)
          next
        end

        output = lang.switch_dom_lang(d, @store, values, url, headers)
        # put back noscripts
        noscripts.each_with_index do |noscript, index|
          noscript_identifier = "<noscript wovn-id=\"#{index}\"></noscript>"
          output.sub!(noscript_identifier, noscript)
        end
        new_body.push(output)
      end
      body.close if body.respond_to?(:close)
      new_body
    end
  end

end

