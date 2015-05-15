require 'wovnrb/store'
require 'wovnrb/headers'
require 'wovnrb/lang'
require 'dom'
require 'json'

require 'wovnrb/railtie' if defined?(Rails)

module Wovnrb

  DEFAULT_LANG = 'en'
  STORE = Store.new
  
  class Interceptor
    def initialize(app)
      @app = app
    end

    def call(env)
      @env = env
      headers = Headers.new(env, STORE.get_settings)
      if headers.browser_lang == headers.path_lang
        lang = headers.lang
      else
        redirect_headers = headers.redirect
        return [307, redirect_headers, ['']]
      end

      # pass to application
      status, res_headers, body = @app.call(headers.request_out)

      if res_headers["Content-Type"] =~ /html/ && !body[0].nil?
# Can we make this request beforehand?
        values = STORE.get_values(headers.url)
        url = {
                :protocol => headers.protocol, 
                :host => headers.host, 
                :pathname => headers.pathname
              }
        switch_lang(body, values, url, lang) unless status.to_s =~ /^1|302/ || lang === DEFAULT_LANG
        #d = Dom.new(storage.get_values, body, lang)
      end

      headers.out(res_headers)
      [status, res_headers, body]
      #[status, res_headers, d.transform()]
    end


    def switch_lang(body, values, url, lang=DEFAULT_LANG)
      return if values.size == 0
      def_lang = 'en'
      text_index = values['text_vals']
      src_index = values['img_vals'] || {}
      img_src_prefix = values['img_src_prefix'] || ''
      string_index = {}
      body.map! do |b|
        d = Nokogiri::HTML5(b)
        d.xpath('//text()').each do |node|
          if text_index[node.content] && text_index[node.content][lang]
            node.content = text_index[node.content][lang][0]['data']
          end
        end
        d.xpath('//img').each do |node|
          # use regular expressions to support case insensitivity (right?)
          if node.to_html =~ /src=['"][^'"]*['"]/i
            src = node.to_html.match(/src=['"]([^&'"]*)['"]/i)[1]
# THIS SRC CORRECTION DOES NOT HANDLE ONE IMPORTANT CASE
# 1) "../path/with/ellipse"
            # if this is not an absolute src
            if src !~ /:\/\//
              # if this is a path with a leading slash
              if src =~ /^\//
                src = "#{url[:protocol]}://#{url[:host]}#{src}"
              else
                src = "#{url[:protocol]}://#{url[:host]}#{url[:path]}#{src}"
              end
            end
          
            if src_index[src] && src_index[src][lang]
              node.attribute('src').value = "#{img_src_prefix}#{src_index[src][lang][0]['data']}"
            end
          end
        end
        # INSERTS
        insert_node = Nokogiri::XML::Node.new('script', d)
        insert_node['type'] = 'text/javascript'
        insert_node.content = "window.wovn_backend = function() { return {'currentLang': '#{lang}'}; };"
        parent_node = d.at_css('head') || d.at_css('body') || d.at_css('html')
        parent_node.add_child(insert_node)
        d.to_html
      end
    end

  end

end

