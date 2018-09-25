# -*- encoding: UTF-8 -*-

require 'addressable'

module Wovnrb
  class Lang
    LANG = {
      #http://msdn.microsoft.com/en-us/library/hh456380.aspx
      'ar' => {name: 'العربية',           code: 'ar',     en: 'Arabic'},
      'eu' => {name: 'Euskara',           code: 'eu',     en: 'Basque'},
      'bn' => {name: 'বাংলা ভাষা',             code: 'bn',     en: 'Bengali'},
      'bg' => {name: 'Български',         code: 'bg',     en: 'Bulgarian'},
      'ca' => {name: 'Català',            code: 'ca',     en: 'Catalan'},
      'zh-CHS' => {name: '简体中文',      code: 'zh-CHS', en: 'Simp Chinese'},
      'zh-CHT' => {name: '繁體中文',      code: 'zh-CHT', en: 'Trad Chinese'},
      'da' => {name: 'Dansk',             code: 'da',     en: 'Danish'},
      'nl' => {name: 'Nederlands',        code: 'nl',     en: 'Dutch'},
      'en' => {name: 'English',           code: 'en',     en: 'English'},
      'fi' => {name: 'Suomi',             code: 'fi',     en: 'Finnish'},
      'fr' => {name: 'Français',          code: 'fr',     en: 'French'},
      'gl' => {name: 'Galego',            code: 'gl',     en: 'Galician'},
      'de' => {name: 'Deutsch',           code: 'de',     en: 'German'},
      'el' => {name: 'Ελληνικά',          code: 'el',     en: 'Greek'},
      'he' => {name: 'עברית',             code: 'he',     en: 'Hebrew'},
      'hu' => {name: 'Magyar',            code: 'hu',     en: 'Hungarian'},
      'id' => {name: 'Bahasa Indonesia',  code: 'id',     en: 'Indonesian'},
      'it' => {name: 'Italiano',          code: 'it',     en: 'Italian'},
      'ja' => {name: '日本語',            code: 'ja',     en: 'Japanese'},
      'ko' => {name: '한국어',            code: 'ko',     en: 'Korean'},
      'lv' =>{name: 'Latviešu',          code: 'lv',     en: 'Latvian'},
      'ms' => {name: 'Bahasa Melayu',     code: 'ms',     en: 'Malay'},
      'my' => { name: 'ဗမာစာ',             code: 'my',     en: 'Burmese' },
      'ne' => {name: 'नेपाली भाषा',            code: 'ne',     en: 'Nepali'},
      'fa' => {name: 'زبان_فارسی',        code: 'fa',     en: 'Persian'},
      'no' => {name: 'Norsk',             code: 'no',     en: 'Norwegian'},
      'pl' => {name: 'Polski',            code: 'pl',     en: 'Polish'},
      'pt' => {name: 'Português',         code: 'pt',     en: 'Portuguese'},
      'ru' => {name: 'Русский',           code: 'ru',     en: 'Russian'},
      'es' => {name: 'Español',           code: 'es',     en: 'Spanish'},
      'sw' => {name: 'Kiswahili',         code: 'sw',     en: 'Swahili'},
      'sv' => {name: 'Svensk',            code: 'sv',     en: 'Swedish'},
      'th' => {name: 'ภาษาไทย',           code: 'th',     en: 'Thai'},
      'hi' => {name: 'हिन्दी',               code: 'hi',     en: 'Hindi'},
      'tr' => {name: 'Türkçe',            code: 'tr',     en: 'Turkish'},
      'uk' => {name: 'Українська',        code: 'uk',     en: 'Ukrainian'},
      'ur' => {name: 'اردو',              code: 'ur',     en: 'Urdu'},
      'vi' => {name: 'Tiếng Việt',        code: 'vi',     en: 'Vietnamese'},
    }

    # Provides the ISO639-1 code for a given lang code.
    # Source: https://support.google.com/webmasters/answer/189077?hl=en
    #
    # @param lang_code [String] lang_code Code of the language.
    #
    # @return [String] The ISO639-1 code of the language.
    def self.iso_639_1_normalization(lang_code)
      return lang_code.sub(/zh-CHT/i, 'zh-Hant').sub(/zh-CHS/i, 'zh-Hans')
    end

    def self.get_code(lang_name)
      return nil if lang_name.nil?
      return lang_name if LANG[lang_name]
      custom_lang_aliases = Store.instance.settings['custom_lang_aliases']
      custom_lang = LANG[custom_lang_aliases.invert[lang_name]]
      return custom_lang[:code] if custom_lang
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

    # Adds language code to URL in "href" variable by "pattern" variable and own @lang_code.
    #  When @lang_code is 'ja', add_lang_code('https://wovn.io', 'path', headers) returns 'https://wovn.io/ja/'.
    # If you want to know more examples, see also test/lib/lang_test.rb.
    #
    # @param  [String] href            original URL.
    # @param  [String] pattern         url_pattern of the settings. ('path', 'subdomain' or 'query')
    # @param  [Wovnrb::Header] headers instance of Wovn::Header. It generates new env variable for original request.
    # @return [String]                 URL added langauge code.
    def add_lang_code(href, pattern, headers)
      return href if href =~ /^(#.*)?$/
      code_to_add = Store.instance.settings['custom_lang_aliases'][@lang_code] || @lang_code
      # absolute links
      new_href = href
      if href && href =~ /^(https?:)?\/\//i
        # in the future, perhaps validate url rather than using begin rescue
        # "#{url =~ /\// ? 'http:' : ''}#{url}" =~ URI::regexp
        begin
          uri = Addressable::URI.parse(href)
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
              if sub_code && sub_code.downcase == code_to_add.downcase
                new_href = href.sub(Regexp.new(code_to_add, 'i'), code_to_add.downcase)
              else
                new_href = href.sub(/(\/\/)([^\.]*)/, '\1' + code_to_add.downcase + '.' + '\2')
              end
            when 'query'
              new_href = add_query_lang_code(href, code_to_add)
            else # path
              new_href = href.sub(/([^\.]*\.[^\/]*)(\/|$)/, '\1/' + code_to_add + '/')
          end
        end
      elsif href
        case pattern
          when 'subdomain'
            lang_url = headers.protocol + '://' + code_to_add.downcase + '.' + headers.host
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
            new_href = add_query_lang_code(href, code_to_add)
          else # path
            if href =~ /^\//
              new_href = '/' + code_to_add + href
            else
              current_dir = headers.pathname.sub(/[^\/]*\.[^\.]{2,6}$/, '')
              current_dir = '/' if current_dir == ''
              new_href = '/' + code_to_add + current_dir + href
            end
        end
      end

      new_href
    end

    def switch_dom_lang(dom, store, values, url, headers)
      replace_dom_values(dom, values, store, url, headers)

      # INSERT LANGUAGE METALINKS
      parent_node = dom.at_css('head') || dom.at_css('body') || dom.at_css('html')
      published_langs = get_langs(values)
      all_langs = published_langs.add(store.settings['default_lang'])
      all_langs.each do |l|
        insert_node = Nokogiri::XML::Node.new('link', dom)
        insert_node['rel'] = 'alternate'
        insert_node['hreflang'] = Lang::iso_639_1_normalization(l)
        insert_node['href'] = headers.redirect_location(l)
        parent_node.add_child(insert_node)
      end

      # set lang property on HTML tag
      if dom.at_css('html') || dom.at_css('HTML')
        (dom.at_css('html') || dom.at_css('HTML')).set_attribute('lang', Lang::iso_639_1_normalization(@lang_code))
      end

      index_href = index_href_for_encoding_and_decoding(dom)
      # NOTE: when we use `#to_html` with nokogiri, nokogiri encode all href.
      #       but we want to keep original href as much as possible.
      #       That's why we replace href with original href which added lang info by wovnrb like this after we used `to_html`
      dom.to_html(save_with: 0).gsub(/href="([^"]*)"/) { |m| "href=\"#{index_href[$1] || $1}\"" }
    end

    private

    def index_href_for_encoding_and_decoding(dom)
      result = {}
      dom.xpath('//*[@href]').each do |a_tag|
        url = a_tag['href']
        begin
          encoded_url = Addressable::URI.parse(url).normalize.to_s
          result[encoded_url] = url if encoded_url != url
        rescue Addressable::URI::InvalidURIError => e
          WovnLogger.instance.error("Failed parse url : #{url}#{e.message}")
        end
      end
      result
    end

    def replace_dom_values(dom, values, store, url, headers)
      text_index = values['text_vals'] || {}
      src_index = values['img_vals'] || {}
      img_src_prefix = values['img_src_prefix'] || ''
      host_aliases = values['host_aliases'] || []

      replacers = []
      # add lang code to anchors href if not default lang
      if @lang_code != store.settings['default_lang']
        pattern = store.settings['url_pattern']
        replacers << LinkReplacer.new(store, pattern, headers)
      end

      replacers << TextReplacer.new(store, text_index)
      replacers << MetaReplacer.new(store, text_index, pattern, headers)
      replacers << InputReplacer.new(store, text_index)
      replacers << ImageReplacer.new(store, url, text_index, src_index, img_src_prefix, host_aliases)
      replacers << ScriptReplacer.new(store)

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

    def add_query_lang_code(href, lang_code)
      query_separator = href =~ /\?/ ? '&' : '?'

      href.sub(/(#|$)/, "#{query_separator}wovn=#{lang_code}\\1")
    end
  end
end
