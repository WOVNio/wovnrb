# -*- encoding: UTF-8 -*-
module Wovnrb
  class Lang
    LANG = {
      #http://msdn.microsoft.com/en-us/library/hh456380.aspx
      'ar' => {name: 'العربية',           code: 'ar',     en: 'Arabic'},
      'zh-CHS' => {name: '简体中文',      code: 'zh-CHS', en: 'Simp Chinese'},
      'zh-CHT' => {name: '繁體中文',      code: 'zh-CHT', en: 'Trad Chinese'},
      'da' => {name: 'Dansk',             code: 'da',     en: 'Danish'},
      'nl' => {name: 'Nederlands',        code: 'nl',     en: 'Dutch'},
      'en' => {name: 'English',           code: 'en',     en: 'English'},
      'fi' => {name: 'Suomi',             code: 'fi',     en: 'Finnish'},
      'fr' => {name: 'Français',          code: 'fr',     en: 'French'},
      'de' => {name: 'Deutsch',           code: 'de',     en: 'German'},
      'el' => {name: 'Ελληνικά',          code: 'el',     en: 'Greek'},
      'he' => {name: 'עברית',             code: 'he',     en: 'Hebrew'},
      'id' => {name: 'Bahasa Indonesia',  code: 'id',     en: 'Indonesian'},
      'it' => {name: 'Italiano',          code: 'it',     en: 'Italian'},
      'ja' => {name: '日本語',            code: 'ja',     en: 'Japanese'},
      'ko' => {name: '한국어',            code: 'ko',     en: 'Korean'},
      'ms' => {name: 'Bahasa Melayu',     code: 'ms',     en: 'Malay'},
      'no' => {name: 'Norsk',             code: 'no',     en: 'Norwegian'},
      'pl' => {name: 'Polski',            code: 'pl',     en: 'Polish'},
      'pt' => {name: 'Português',         code: 'pt',     en: 'Portuguese'},
      'ru' => {name: 'Русский',           code: 'ru',     en: 'Russian'},
      'es' => {name: 'Español',           code: 'es',     en: 'Spanish'},
      'sv' => {name: 'Svensk',            code: 'sv',     en: 'Swedish'},
      'th' => {name: 'ภาษาไทย',           code: 'th',     en: 'Thai'},
      'hi' => {name: 'हिन्दी',               code: 'hi',     en: 'Hindi'},
      'tr' => {name: 'Türkçe',            code: 'tr',     en: 'Turkish'},
      'uk' => {name: 'Українська',        code: 'uk',     en: 'Ukrainian'},
      'vi' => {name: 'Tiếng Việt',        code: 'vi',     en: 'Vietnamese'},
    }

    def self.get_code(lang_name)
      return nil if lang_name.nil?
      return lang_name if LANG[lang_name]
      LANG.each do |k, l|
        if lang_name.downcase == l[:name].downcase || lang_name.downcase == l[:en].downcase || lang_name.downcase == l[:code].downcase
          return l[:code]
        end
      end
      return nil
    end

    def self.get_lang(lang)
      lang_code = get_code(lang)
      return LANG[lang_code]
    end

    def initialize(lang_name)
      @lang_code = Lang.get_code(lang_name)
    end

    def lang_code
      @lang_code
    end

    def add_lang_code(href, pattern, headers)
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
        # DNS names are case insensitive
        if uri.host.downcase === headers.host.downcase
          case pattern
            when 'subdomain'
              sub_d = href.match(/\/\/([^\.]*)\./)[1]
              sub_code = Lang.get_code(sub_d)
              if sub_code && sub_code.downcase == @lang_code.downcase
                new_href = href.sub(Regexp.new(@lang_code, 'i'), @lang_code.downcase)
              else
                new_href = href.sub(/(\/\/)([^\.]*)/, '\1' + @lang_code.downcase + '.' + '\2')
              end
            when 'query'
              new_href = href =~ /\?/ ? href + '&wovn=' + @lang_code : href + '?wovn=' + @lang_code
            else # path
              new_href = href.sub(/([^\.]*\.[^\/]*)(\/|$)/, '\1/' + @lang_code + '/')
          end
        end
      elsif href
        case pattern
          when 'subdomain'
            lang_url = headers.protocol + '://' + @lang_code.downcase + '.' + headers.host
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
            new_href = href =~ /\?/ ? href + '&wovn=' + @lang_code : href + '?wovn=' + @lang_code
          else # path
            if href =~ /^\//
              new_href = '/' + @lang_code + href
            else
              current_dir = headers.pathname.sub(/[^\/]*\.[^\.]{2,6}$/, '')
              new_href = '/' + @lang_code + current_dir + href
            end
        end
      end
      new_href
    end

    def switch_dom_lang(d, store, values, url, headers)
      text_index = values['text_vals'] || {}
      src_index = values['img_vals'] || {}
      img_src_prefix = values['img_src_prefix'] || ''
      # add lang code to anchors href if not default lang
      if @lang_code != store.settings['default_lang']
        pattern = store.settings['url_pattern']

        d.xpath('//a').each do |a|
          next if check_wovn_ignore(a)
          href = a.get_attribute('href')
          new_href = add_lang_code(href, pattern, headers)
          a.set_attribute('href', new_href)
        end
      end

      # swap text
      d.xpath('//text()').each do |node|
        next if check_wovn_ignore(node)
        node_text = node.content.strip
# shouldn't need size check, but for now...
        if text_index[node_text] && text_index[node_text][@lang_code] && text_index[node_text][@lang_code].size > 0
          node.content = node.content.gsub(/^(\s*)[\S\s]*(\s*)$/, '\1' + text_index[node_text][@lang_code][0]['data'] + '\2')
        end
      end
      # swap meta tag values
      d.xpath('//meta').select { |t|
        next if check_wovn_ignore(t)
        (t.get_attribute('name') || t.get_attribute('property') || '') =~ /^(description|title|og:title|og:description|twitter:title|twitter:description)$/
      }.each do |node|
        node_content = node.get_attribute('content').strip
# shouldn't need size check, but for now...
        if text_index[node_content] && text_index[node_content][@lang_code] && text_index[node_content][@lang_code].size > 0
          node.set_attribute('content', node_content.gsub(/^(\s*)[\S\s]*(\s*)$/, '\1' + text_index[node_content][@lang_code][0]['data'] + '\2'))
        end
      end
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
          if src_index[src] && src_index[src][@lang_code] && src_index[src][@lang_code].size > 0
            node.attribute('src').value = "#{img_src_prefix}#{src_index[src][@lang_code][0]['data']}"
          end
        end
        if node.get_attribute('alt')
          alt = node.get_attribute('alt').strip
          if text_index[alt] && text_index[alt][@lang_code] && text_index[alt][@lang_code].size > 0
            node.attribute('alt').value = alt.gsub(/^(\s*)[\S\s]*(\s*)$/, '\1' + text_index[alt][@lang_code][0]['data'] + '\2')
          end
        end
      end

      # REMOVE WIDGET
      d.xpath('//script').each do |script_node|
        if script_node['src'] && script_node['src'].include?('//j.(dev-)?wovn.io(:3000)?/')
          #binding.pry
          script_node.remove
        end
      end

      # PARENT NODE FOR INSERTS
      parent_node = d.at_css('head') || d.at_css('body') || d.at_css('html')

      # INSERT BACKEND WIDGET
      insert_node = Nokogiri::XML::Node.new('script', d)
      # TODO: CHANGE THIS BACK; Should be '//j.wovn.io/0' in production
      insert_node['src'] = '//j.wovn.io/1'
      #insert_node['src'] = '//j.dev-wovn.io:3030/1'
      insert_node['async'] = true
      version = defined?(VERSION) ? VERSION : ''
      insert_node['data-wovnio'] = "key=#{store.settings['user_token']}&backend=true&currentLang=#{@lang_code}&defaultLang=#{store.settings['default_lang']}&urlPattern=#{store.settings['url_pattern']}&version=#{version}"
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
        (d.at_css('html') || d.at_css('HTML')).set_attribute('lang', @lang_code)
      end

      d.to_html.gsub(/href="([^"]*)"/) { |m| "href=\"#{URI.decode($1)}\"" }
    end

    private
    # returns true if a wovn_ignore is found in the tree from the node to the body tag
    def check_wovn_ignore(node)
      if !node.get_attribute('wovn-ignore').nil?
        return true
      elsif node.name === 'html'
        return false
      end
      check_wovn_ignore(node.parent)
    end

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
