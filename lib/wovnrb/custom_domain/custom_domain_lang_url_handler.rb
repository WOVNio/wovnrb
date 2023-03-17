require 'wovnrb/custom_domain/custom_domain_lang'

module Wovnrb
  # Helper class for transforming actual domains to user-defined custom domains
  class CustomDomainLangUrlHandler
    class << self
      def add_custom_domain_lang_to_absolute_url(absolute_url, target_lang, custom_domain_langs)
        current_custom_domain = custom_domain_langs.custom_domain_lang_by_url(absolute_url)
        new_lang_custom_domain = custom_domain_langs.custom_domain_lang_by_lang(target_lang)
        change_to_new_custom_domain_lang(absolute_url, current_custom_domain, new_lang_custom_domain)
      end

      def change_to_new_custom_domain_lang(absolute_url, current_custom_domain, new_lang_custom_domain)
        return absolute_url unless current_custom_domain.present? && new_lang_custom_domain.present?

        current_host_and_path = current_custom_domain.host_and_path_without_trailing_slash
        new_host_and_path = new_lang_custom_domain.host_and_path_without_trailing_slash

        # ^(.*://|//)?               1: schema, e.g. https://
        # (#{current_host_and_path}) 2: host and path, e.g. wovn.io/foo
        # ((?:/|\?|#).*)?$           3: other / query params, e.g. ?hello=world
        regex = %r{^(.*://|//)?(#{current_host_and_path})((?:/|\?|#).*)?$}
        absolute_url.gsub(regex) { "#{Regexp.last_match(1)}#{new_host_and_path}#{Regexp.last_match(3)}" }
      end
    end
  end
end
