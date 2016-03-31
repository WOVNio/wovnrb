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

    def switch_dom_lang(dom, store, values, url, headers)
      replace_dom_values(dom, values, store, url, headers)

      # REMOVE WIDGET
      dom.xpath('//script').each do |script_node|
        if script_node['src'] && script_node['src'].include?('//j.(dev-)?wovn.io(:3000)?/')
          #binding.pry
          script_node.remove
        end
      end

      # PARENT NODE FOR INSERTS
      parent_node = dom.at_css('head') || dom.at_css('body') || dom.at_css('html')

      # INSERT BACKEND WIDGET
      insert_node = Nokogiri::XML::Node.new('script', dom)
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
        insert_node = Nokogiri::XML::Node.new('link', dom)
        insert_node['rel'] = 'alternate'
        insert_node['hreflang'] = l
        insert_node['href'] = headers.redirect_location(l)
        parent_node.add_child(insert_node)
      end

      # set lang property on HTML tag
      if dom.at_css('html') || dom.at_css('HTML')
        (dom.at_css('html') || dom.at_css('HTML')).set_attribute('lang', @lang_code)
      end

      dom.to_html.gsub(/href="([^"]*)"/) { |m| "href=\"#{URI.decode($1)}\"" }
    end

    private
    def replace_dom_values(dom, values, store, url, headers)
      text_index = values['text_vals'] || {}
      src_index = values['img_vals'] || {}
      img_src_prefix = values['img_src_prefix'] || ''

      replacers = []
      # add lang code to anchors href if not default lang
      if @lang_code != store.settings['default_lang']
        pattern = store.settings['url_pattern']
        replacers << LinkReplacer.new(pattern, headers)
      end

      replacers << TextReplacer.new(text_index)
      replacers << MetaReplacer.new(text_index)
      replacers << ImageReplacer.new(url, text_index, src_index, img_src_prefix)

      replacers.each do |replacer|
        replacer.replace(dom, self)
      end
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
