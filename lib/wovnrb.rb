require 'wovnrb/store'
require 'wovnrb/headers'
require 'wovnrb/lang'
require 'nokogumbo'
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
      unless STORE.valid_settings?
        return @app.call(env)
      end
      @env = env
      headers = Headers.new(env, STORE.settings)
      if STORE.settings['test_mode'] && STORE.settings['test_url'] != headers.url
        return @app.call(env)
      end
       #redirect if the path is set to the default language (for SEO purposes)
      if (headers.path_lang == STORE.settings['default_lang'])
        redirect_headers = headers.redirect(STORE.settings['default_lang'])
        return [307, redirect_headers, ['']]
      end
      lang = headers.lang_code

      # pass to application
      status, res_headers, body = @app.call(headers.request_out)

      if res_headers["Content-Type"] =~ /html/ # && !body[0].nil?
        values = STORE.get_values(headers.redis_url)
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

      headers.out(res_headers)
      [status, res_headers, body]
      #[status, res_headers, d.transform()]
    end

    def add_lang_code(href, pattern, lang, headers)
      return href if href =~ /^(#.*)?$/
      # absolute links 
      new_href = href
      if href && href =~ /^(https?:)?\/\//i
        # in the future, perhaps validate url rather than using begin rescue
        # "#{url =~ /\// ? 'http:' : ''}#{url}" =~ URI::regexp
        begin
          uri = URI(href)
        rescue
          return new_href
        end
        # only add lang if it's an internal link 
        if uri.host === headers.host
          case pattern
            when 'subdomain'
              sub_d = href.match(/\/\/([^\.]*)\./)[1]
              sub_code = Lang.get_code(sub_d)
              if sub_code && sub_code.downcase == lang.downcase
                new_href = href.sub(Regexp.new(lang, 'i'), lang.downcase)
              else
                new_href = href.sub(/(\/\/)([^\.]*)/, '\1' + lang.downcase + '.' + '\2')
              end
            when 'query'
              new_href = href =~ /\?/ ? href + '&wovn=' + lang : href + '?wovn=' + lang
            else # path
              new_href = href.sub(/([^\.]*\.[^\/]*)(\/|$)/, '\1/' + lang + '/')
          end
        end
      elsif href
        case pattern
          when 'subdomain'
            lang_url = headers.protocol + '://' + lang.downcase + '.' + headers.host
            current_dir = headers.pathname.sub(/[^\/]*\.[^\.]{2,6}$/, '')
            if href =~ /^\.\..*$/
              # ../path
              new_href = lang_url + '/' + href.gsub(/^\.\.\//, '')
            elsif href =~ /^\..*$/
              # ./path
              new_href = lang_url + current_dir + '/' + href.gsub(/^\.\//, '')
            elsif href =~ /^\/.*$/
              # /path
              new_href = lang_url + href
            else
              # path
              new_href = lang_url + current_dir + '/' + href
            end
          when 'query'
            new_href = href =~ /\?/ ? href + '&wovn=' + lang : href + '?wovn=' + lang
          else # path
            if href =~ /^\//
              new_href = '/' + lang + href
            else
              current_dir = headers.pathname.sub(/[^\/]*\.[^\.]{2,6}$/, '')
              new_href = '/' + lang + current_dir + href
            end
        end
      end
      new_href
    end

    # returns true if a wovn_ignore is found in the tree from the node to the body tag
    def check_wovn_ignore(node)
      if !node.get_attribute('wovn-ignore').nil?
        return true
      elsif node.name === 'html'
        return false
      end
      check_wovn_ignore(node.parent)
    end

    def switch_lang(body, values, url, lang=STORE.settings['default_lang'], headers)
      lang = Lang.get_code(lang)
      text_index = values['text_vals'] || {}
      src_index = values['img_vals'] || {}
      img_src_prefix = values['img_src_prefix'] || ''
      string_index = {}
      new_body = []
      body.each do |b|
        d = Nokogiri::HTML5(b)
        d.encoding = "UTF-8"

        # add lang code to anchors href if not default lang 
        if lang != STORE.settings['default_lang']
          d.xpath('//a').each do |a|
            next if check_wovn_ignore(a)
            href = a.get_attribute('href')
            new_href = add_lang_code(href, STORE.settings['url_pattern'], lang, headers)
            a.set_attribute('href', new_href)
          end
        end

        # swap text
        d.xpath('//text()').each do |node|
          next if check_wovn_ignore(node)
          node_text = node.content.strip
# shouldn't need size check, but for now...
          if text_index[node_text] && text_index[node_text][lang] && text_index[node_text][lang].size > 0
            node.content = node.content.gsub(/^(\s*)[\S\s]*(\s*)$/, '\1' + text_index[node_text][lang][0]['data'] + '\2')
          end
        end
        # swap meta tag values
       # d.xpath('//meta').select { |t|
       #   next if check_wovn_ignore(t)
       #   (t.get_attribute('name') || t.get_attribute('property') || '') =~ /^(description|keywords|og:title|og:description)$/
       # }.each do |node|
       #   node_content = node.get_attribute('content').strip
# shoul#dn't need size check, but for now...
       #   if text_index[node_content] && text_index[node_content][lang] && text_index[node_content][lang].size > 0
       #     node.set_attribute('content', node_content.gsub(/^(\s*)[\S\s]*(\s*)$/, '\1' + text_index[node_content][lang][0]['data'] + '\2'))
       #   end
       # end
        # swap img srcs
        d.xpath('//img').each do |node|
          next if check_wovn_ignore(node)
          # use regular expressions to support case insensitivity (right?)
          if node.to_html =~ /src=['"][^'"]*['"]/i
            src = node.to_html.match(/src=['"]([^'"]*)['"]/i)[1]
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

        # REMOVE WIDGET
        d.xpath('//script').each do |script_node|
          if script_node['src'] && script_node['src'].include?('//j.(dev-)?wovn.io(:3000)?/')
            script_node.remove
          end
        end

        # PARENT NODE FOR INSERTS
        parent_node = d.at_css('head') || d.at_css('body') || d.at_css('html')

        # INSERT BACKEND WIDGET
        insert_node = Nokogiri::XML::Node.new('script', d)
        # TODO: CHANGE THIS BACK; Should be '//j.wovn.io/0' in production
        insert_node['src'] = '//j.wovn.io/0'
        #insert_node['src'] = '//j.dev-wovn.io:3000/0'
        version = defined?(VERSION) ? VERSION : ''
        insert_node['data-wovnio'] = "key=#{STORE.settings['user_token']}&backend=true&currentLang=#{lang}&defaultLang=#{STORE.settings['default_lang']}&urlPattern=#{STORE.settings['url_pattern']}&version=#{version}"
        # do this so that there will be a closing tag (better compatibility with browsers)
        insert_node.content = ' '
        if parent_node.children.size > 0
          parent_node.children.first.add_previous_sibling(insert_node)
        else
          parent_node.add_child(insert_node)
        end


        # INSERT LANGUAGE METALINKS
        published_langs = get_langs(values)
        published_langs.each do |l|
          insert_node = Nokogiri::XML::Node.new('link', d)
          insert_node['rel'] = 'alternate'
          insert_node['hreflang'] = l
          insert_node['href'] = headers.redirect_location(l)
          parent_node.add_child(insert_node)
        end

        # set lang property on HTML tag
        if d.at_css('html') || d.at_css('HTML')
          (d.at_css('html') || d.at_css('HTML')).set_attribute('lang', lang)
        end

        output = d.to_html.gsub(/href="([^"]*)"/) { |m| "href=\"#{URI.decode($1)}\"" }
        new_body.push(output)
      end
      body.close if body.respond_to?(:close)
      new_body
      #body
    end

    # this clearly needs to be refactored. I'm thinking maybe a Value service? (STORE.values.get_langs)
    def get_langs(values)
      langs = Set.new
      (values['text_vals'] || {}).merge(values['img_vals'] || {}).each do |key, index|
        index.each do |l, val|
          langs.add(l)
        end
      end
      langs
    end

  end

end

