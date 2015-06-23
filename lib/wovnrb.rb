require 'wovnrb/store'
require 'wovnrb/headers'
require 'wovnrb/lang'
#require 'dom'
require 'json'

require 'wovnrb/railtie' if defined?(Rails)

module Wovnrb

  STORE = Store.new
  
  class Interceptor
    def initialize(app)
      @app = app
    end

    def call(env)
      @env = env
      STORE.refresh_settings
      headers = Headers.new(env, STORE.settings)
      # redirect if the path is set to the default language (for SEO purposes)
      if (headers.path_lang == STORE.settings['default_lang'])
        redirect_headers = headers.redirect(STORE.settings['default_lang'])
        return [307, redirect_headers, ['']]
      end
      #if ((headers.path_lang != '' && !STORE.settings['supported_langs'].include?(headers.path_lang)) || headers.path_lang == STORE.settings['default_lang'])
      #  redirect_headers = headers.redirect(STORE.settings['default_lang'])
      #  redirect_headers['set-cookie'] = "wovn_selected_lang=#{STORE.settings['default_lang']};"
      #  return [307, redirect_headers, ['']]
      #elsif headers.path_lang == '' && (headers.browser_lang != STORE.settings['default_lang'] && STORE.settings['supported_langs'].include?(headers.browser_lang))
      #  redirect_headers = headers.redirect(headers.browser_lang)
      #  return [307, redirect_headers, ['']]
      #end
      lang = headers.lang

      # pass to application
      status, res_headers, body = @app.call(headers.request_out)

      if res_headers["Content-Type"] =~ /html/ && !body[0].nil?
# Can we make this request beforehand?
        values = STORE.get_values(headers.redis_url)
        url = {
                :protocol => headers.protocol, 
                :host => headers.host, 
                :pathname => headers.pathname
              }
        switch_lang(body, values, url, lang) unless status.to_s =~ /^1|302/
        #d = Dom.new(storage.get_values, body, lang)
      end

      headers.out(res_headers)
#      res_headers['Content-Length'] = body.each {|b| break b.length.to_s }
      [status, res_headers, body]
      #[status, res_headers, d.transform()]
    end


    def switch_lang(body, values, url, lang=STORE.settings['default_lang'])
      def_lang = 'en'
      text_index = values['text_vals'] || {}
      src_index = values['img_vals'] || {}
      img_src_prefix = values['img_src_prefix'] || ''
      string_index = {}
      body.map! do |b|
        d = Nokogiri::HTML5(b)
        d.encoding = "UTF-8"
        d.xpath('//text()').each do |node|
          node_text = node.content.strip
# shouldn't need size check, but for now...
          if text_index[node_text] && text_index[node_text][lang] && text_index[node_text][lang].size > 0
            node.content = node.content.gsub(/^(\s*)[\S\s]*(\s*)$/, '\1' + text_index[node_text][lang][0]['data'] + '\2')
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
          
# shouldn't need size check, but for now...
            if src_index[src] && src_index[src][lang] && src_index[src][lang].size > 0
              node.attribute('src').value = "#{img_src_prefix}#{src_index[src][lang][0]['data']}"
            end
          end
        end
        # INSERTS
        #insert_node = Nokogiri::XML::Node.new('script', d)
        #insert_node['type'] = 'text/javascript'
        #insert_node.content = "window.wovn_backend = function() { return {'currentLang': '#{lang}'}; };"
        #parent_node = d.at_css('head') || d.at_css('body') || d.at_css('html')
        #parent_node.add_child(insert_node)

# If dev can't be used on production gem 
        d.xpath('//script').each do |script_node|
          if script_node['src'] && script_node['src'].include?('//j.wovn.io/')
            script_node.remove
          end
        end
        insert_node = Nokogiri::XML::Node.new('script', d)
        insert_node['src'] = '//j.wovn.io/0'
        insert_node['data-wovnio'] = "key=#{STORE.settings['user_token']}&backend=true&currentLang=#{lang}&urlPattern=#{STORE.settings['url_pattern_name']}"
        # do this so that there will be a closing tag (better compatibility with browsers)
        insert_node.content = ' '
        parent_node = d.at_css('head') || d.at_css('body') || d.at_css('html')
        if parent_node.children.size > 0
          parent_node.children.first.add_previous_sibling(insert_node)
        else
          parent_node.add_child(insert_node)
        end

        output = d.to_html.gsub(/href="([^"]*)"/) {|m| "href=\"#{URI.decode($1)}\""}
        # RAILS
        if Object.const_defined?('ActionView') && ActionView.const_defined?('OutputBuffer')
          output = ActionView::OutputBuffer.new(output)
        end
        output
      end
    end

  end

end

