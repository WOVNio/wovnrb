require 'wovnrb/custom_domain/custom_domain_lang'

module Wovnrb
  # Represents a list of custom domains with corresponding languages
  class CustomDomainLangs
    attr_accessor :custom_domain_langs

    def initialize(custom_domain_langs_settings_array)
      @custom_domain_langs = {}
      custom_domain_langs_settings_array.each do |lang_code, config|
        url_with_protocol = config['url'].match?(%r{https?://}) ? config['url'] : "http://#{config['url']}"
        parsed_url = Addressable::URI.parse(url_with_protocol)

        @custom_domain_langs[lang_code] = CustomDomainLang.new(parsed_url.host, parsed_url.path, lang_code)
      end
    end

    def custom_domain_lang_by_lang(lang_code)
      @custom_domain_langs[lang_code]
    end

    def custom_domain_lang_by_url(uri)
      # "/" path will naturally match every URL, so by comparing longest paths first we will get the best match
      sorted_custom_domain_langs = custom_domain_langs.values.sort do |a, b|
        a.path.length <= b.path.length ? 1 : -1
      end
      parsed_url = Addressable::URI.parse(uri)
      parsed_url.path = '/' if parsed_url.path.blank?

      sorted_custom_domain_langs.find do |custom_domain_lang|
        custom_domain_lang.match?(parsed_url)
      end
    end

    def to_html_swapper_hash
      result = {}
      custom_domain_langs.each do |_lang_code, custom_domain_lang|
        result[custom_domain_lang.host_and_path_without_trailing_slash] = custom_domain_lang.lang
      end
      result
    end
  end
end
