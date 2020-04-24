require 'addressable'

module Wovnrb
  class Lang
    LANG = {
      'ar' => { name: 'العربية',                    code: 'ar',         en: 'Arabic' },
      'eu' => { name: 'Euskara',                  code: 'eu',         en: 'Basque' },
      'bn' => { name: 'বাংলা ভাষা',                code: 'bn',         en: 'Bengali' },
      'bg' => { name: 'Български',                code: 'bg',         en: 'Bulgarian' },
      'ca' => { name: 'Català',                   code: 'ca',         en: 'Catalan' },
      'zh-CN' => { name: '简体中文（中国）',         code: 'zh-CN',      en: 'Simp Chinese (China)' },
      'zh-CHS' => { name: '简体中文',                 code: 'zh-CHS',     en: 'Simp Chinese' },
      'zh-Hant-HK' => { name: '繁體中文（香港）',         code: 'zh-Hant-HK', en: 'Trad Chinese (Hong Kong)' },
      'zh-Hant-TW' => { name: '繁體中文（台湾）',         code: 'zh-Hant-TW', en: 'Trad Chinese (Taiwan)' },
      'zh-CHT' => { name: '繁體中文',                 code: 'zh-CHT',     en: 'Trad Chinese' },
      'da' => { name: 'Dansk',                    code: 'da',         en: 'Danish' },
      'nl' => { name: 'Nederlands',               code: 'nl',         en: 'Dutch' },
      'en' => { name: 'English',                  code: 'en',         en: 'English' },
      'en-AU' => { name: 'English (Australia)',      code: 'en-AU',      en: 'English (Australia)' },
      'en-CA' => { name: 'English (Canada)',         code: 'en-CA',      en: 'English (Canada)' },
      'en-IN' => { name: 'English (India)',          code: 'en-IN',      en: 'English (India)' },
      'en-NZ' => { name: 'English (New Zealand)',    code: 'en-NZ',      en: 'English (New Zealand)' },
      'en-ZA' => { name: 'English (South Africa)',   code: 'en-ZA',      en: 'English (South Africa)' },
      'en-GB' => { name: 'English (United Kingdom)', code: 'en-GB',      en: 'English (United Kingdom)' },
      'en-SG' => { name: 'English (Singapore)',      code: 'en-SG',      en: 'English (Singapore)' },
      'en-US' => { name: 'English (United States)',  code: 'en-US',      en: 'English (United States)' },
      'fi' => { name: 'Suomi',                    code: 'fi',         en: 'Finnish' },
      'fr' => { name: 'Français',                 code: 'fr',         en: 'French' },
      'fr-CA' => { name: 'Français (Canada)',        code: 'fr-CA',      en: 'French (Canada)' },
      'fr-FR' => { name: 'Français (France)',        code: 'fr-FR',      en: 'French (France)' },
      'fr-CH' => { name: 'Français (Suisse)',        code: 'fr-CH',      en: 'French (Switzerland)' },
      'gl' => { name: 'Galego',                   code: 'gl',         en: 'Galician' },
      'de' => { name: 'Deutsch',                  code: 'de',         en: 'German' },
      'de-AT' => { name: 'Deutsch (Österreich)',     code: 'de-AT',      en: 'German (Austria)' },
      'de-DE' => { name: 'Deutsch (Deutschland)',    code: 'de-DE',      en: 'German (Germany)' },
      'de-LI' => { name: 'Deutsch (Liechtenstien)',  code: 'de-LI',      en: 'German (Liechtenstien)' },
      'de-CH' => { name: 'Deutsch (Schweiz)',        code: 'de-CH',      en: 'German (Switzerland)' },
      'el' => { name: 'Ελληνικά',                 code: 'el',         en: 'Greek' },
      'he' => { name: 'עברית',                    code: 'he',         en: 'Hebrew' },
      'hu' => { name: 'Magyar',                   code: 'hu',         en: 'Hungarian' },
      'id' => { name: 'Bahasa Indonesia',         code: 'id',         en: 'Indonesian' },
      'it' => { name: 'Italiano',                 code: 'it',         en: 'Italian' },
      'it-IT' => { name: 'Italiano (Italia)',        code: 'it-IT',      en: 'Italian (Italy)' },
      'it-CH' => { name: 'Italiano (Svizzera)',      code: 'it-CH',      en: 'Italian (Switzerland)' },
      'ja' => { name: '日本語',                   code: 'ja',         en: 'Japanese' },
      'ko' => { name: '한국어',                    code: 'ko',         en: 'Korean' },
      'lv' => { name: 'Latviešu',                 code: 'lv',         en: 'Latvian' },
      'ms' => { name: 'Bahasa Melayu',            code: 'ms',         en: 'Malay' },
      'my' => { name: 'ဗမာစာ',                   code: 'my',         en: 'Burmese' },
      'ne' => { name: 'नेपाली भाषा',                code: 'ne',         en: 'Nepali' },
      'no' => { name: 'Norsk',                    code: 'no',         en: 'Norwegian' },
      'fa' => { name: 'زبان_فارسی',                code: 'fa',         en: 'Persian' },
      'pl' => { name: 'Polski',                   code: 'pl',         en: 'Polish' },
      'pt' => { name: 'Português',                code: 'pt',         en: 'Portuguese' },
      'pt-BR' => { name: 'Português (Brasil)',       code: 'pt-BR',      en: 'Portuguese (Brazil)' },
      'pt-PT' => { name: 'Português (Portugal)',     code: 'pt-PT',      en: 'Portuguese (Portugal)' },
      'ru' => { name: 'Русский',                  code: 'ru',         en: 'Russian' },
      'es' => { name: 'Español',                  code: 'es',         en: 'Spanish' },
      'es-RA' => { name: 'Español (Argentina)',      code: 'es-RA',      en: 'Spanish (Argentina)' },
      'es-CL' => { name: 'Español (Chile)',          code: 'es-CL',      en: 'Spanish (Chile)' },
      'es-CO' => { name: 'Español (Colombia)',       code: 'es-CO',      en: 'Spanish (Colombia)' },
      'es-CR' => { name: 'Español (Costa Rica)',     code: 'es-CR',      en: 'Spanish (Costa Rica)' },
      'es-HN' => { name: 'Español (Honduras)',       code: 'es-HN',      en: 'Spanish (Honduras)' },
      'es-419' => { name: 'Español (Latinoamérica)',  code: 'es-419',     en: 'Spanish (Latin America)' },
      'es-MX' => { name: 'Español (México)',         code: 'es-MX',      en: 'Spanish (Mexico)' },
      'es-PE' => { name: 'Español (Perú)',           code: 'es-PE',      en: 'Spanish (Peru)' },
      'es-ES' => { name: 'Español (España)',         code: 'es-ES',      en: 'Spanish (Spain)' },
      'es-US' => { name: 'Español (Estados Unidos)', code: 'es-US',      en: 'Spanish (United States)' },
      'es-UY' => { name: 'Español (Uruguay)',        code: 'es-UY',      en: 'Spanish (Uruguay)' },
      'es-VE' => { name: 'Español (Venezuela)',      code: 'es-VE',      en: 'Spanish (Venezuela)' },
      'sw' => { name: 'Kiswahili',                code: 'sw',         en: 'Swahili' },
      'sv' => { name: 'Svensk',                   code: 'sv',         en: 'Swedish' },
      'tl' => { name: 'Tagalog',                  code: 'tl',         en: 'Tagalog' },
      'th' => { name: 'ภาษาไทย',                 code: 'th',         en: 'Thai' },
      'hi' => { name: 'हिन्दी',                     code: 'hi',         en: 'Hindi' },
      'tr' => { name: 'Türkçe',                   code: 'tr',         en: 'Turkish' },
      'uk' => { name: 'Українська',               code: 'uk',         en: 'Ukrainian' },
      'ur' => { name: 'اردو',                      code: 'ur',         en: 'Urdu' },
      'vi' => { name: 'Tiếng Việt',               code: 'vi',         en: 'Vietnamese' }
    }.freeze

    # Provides the ISO639-1 code for a given lang code.
    # Source: https://support.google.com/webmasters/answer/189077?hl=en
    #
    # @param lang_code [String] lang_code Code of the language.
    #
    # @return [String] The ISO639-1 code of the language.
    def self.iso_639_1_normalization(lang_code)
      lang_code.sub(/zh-CHT/i, 'zh-Hant').sub(/zh-CHS/i, 'zh-Hans')
    end

    def self.get_code(lang_name)
      return nil if lang_name.nil?
      return lang_name if LANG[lang_name]

      custom_lang_aliases = Store.instance.settings['custom_lang_aliases']
      custom_lang = LANG[custom_lang_aliases.invert[lang_name]]
      return custom_lang[:code] if custom_lang

      LANG.each do |_k, l|
        return l[:code] if lang_name.casecmp(l[:name]).zero? || lang_name.casecmp(l[:en]).zero? || lang_name.casecmp(l[:code]).zero?
      end
      nil
    end

    def self.get_lang(lang)
      lang_code = get_code(lang)
      LANG[lang_code]
    end

    def initialize(lang_name)
      @lang_code = Lang.get_code(lang_name)
    end

    attr_reader :lang_code

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

      settings = Store.instance.settings
      code_to_add = settings['custom_lang_aliases'][@lang_code] || @lang_code
      lang_param_name = settings['lang_param_name']
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
            new_href = if sub_code && sub_code.casecmp(code_to_add).zero?
                         href.sub(Regexp.new(code_to_add, 'i'), code_to_add.downcase)
                       else
                         href.sub(/(\/\/)([^\.]*)/, '\1' + code_to_add.downcase + '.' + '\2')
                       end
          when 'query'
            new_href = add_query_lang_code(href, code_to_add, lang_param_name)
          else # path
            new_href = href.sub(/([^\.]*\.[^\/]*)(\/|$)/, '\1/' + code_to_add + '/')
          end
        end
      elsif href
        case pattern
        when 'subdomain'
          lang_url = headers.protocol + '://' + code_to_add.downcase + '.' + headers.host
          current_dir = headers.pathname.sub(/[^\/]*\.[^\.]{2,6}$/, '')
          new_href = if href =~ /^\.\..*$/
                       # ../path
                       lang_url + '/' + href.gsub(/^\.\.\//, '')
                     elsif href =~ /^\..*$/
                       # ./path
                       lang_url + current_dir + '/' + href.gsub(/^\.\//, '')
                     elsif href =~ /^\/.*$/
                       # /path
                       lang_url + href
                     else
                       # path
                       lang_url + current_dir + '/' + href
                     end
        when 'query'
          new_href = add_query_lang_code(href, code_to_add, lang_param_name)
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
      html_text_index = values['html_text_vals'] || {}
      src_index = values['img_vals'] || {}
      img_src_prefix = values['img_src_prefix'] || ''
      host_aliases = values['host_aliases'] || []

      replacers = []
      # add lang code to anchors href if not default lang
      if @lang_code != store.settings['default_lang']
        pattern = store.settings['url_pattern']
        replacers << LinkReplacer.new(store, pattern, headers)
      end

      replacers << if html_text_index.empty?
                     TextReplacer.new(store, text_index)
                   else
                     UnifiedValues::TextReplacer.new(store, html_text_index)
                   end
      replacers << MetaReplacer.new(store, text_index, pattern, headers)
      replacers << InputReplacer.new(store, text_index)
      replacers << ImageReplacer.new(store, url, text_index, src_index, img_src_prefix, host_aliases)
      replacers << ScriptReplacer.new(store) if dom.html?

      replacers.each do |replacer|
        replacer.replace(dom, self)
      end
    end

    def get_langs(values)
      langs = Set.new
      (values['text_vals'] || {}).merge(values['img_vals'] || {}).each do |_key, index|
        index.each do |l, _val|
          langs.add(l)
        end
      end
      langs
    end

    def add_query_lang_code(href, lang_code, lang_param_name)
      query_separator = href =~ /\?/ ? '&' : '?'

      href.sub(/(#|$)/, "#{query_separator}#{lang_param_name}=#{lang_code}\\1")
    end
  end
end
