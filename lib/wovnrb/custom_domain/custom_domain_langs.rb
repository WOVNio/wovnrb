require 'wovnrb/custom_domain/custom_domain_lang'

module Wovnrb
  # Represents a list of custom domains with corresponding languages
  class CustomDomainLangs
    def initialize(setting)
      @custom_domain_langs = setting.map do |lang_code, config|
        parsed_uri = Addressable::URI.parse(add_protocol_if_needed(config['url']))
        CustomDomainLang.new(parsed_uri.host, parsed_uri.path, lang_code)
      end
    end

    def custom_domain_lang_by_lang(lang_code)
      @custom_domain_langs.find { |c| c.lang == lang_code }
    end

    def custom_domain_lang_by_url(uri)
      parsed_uri = Addressable::URI.parse(add_protocol_if_needed(uri))

      # "/" path will naturally match every URL, so by comparing longest paths first we will get the best match
      @custom_domain_langs
        .sort_by { |c| -c.path.length }
        .find { |c| c.match?(parsed_uri) }
    end

    def to_html_swapper_hash
      result = {}
      @custom_domain_langs.each do |custom_domain_lang|
        result[custom_domain_lang.host_and_path_without_trailing_slash] = custom_domain_lang.lang
      end
      result
    end

    private

    def add_protocol_if_needed(url)
      url.match?(%r{https?://}) ? url : "http://#{url}"
    end
  end
end
