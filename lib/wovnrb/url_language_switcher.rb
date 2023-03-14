require 'wovnrb/custom_domain/custom_domain_lang_url_handler'
require 'wovnrb/services/url'

module Wovnrb
  # URL Language switching helper, ported from html-swapper
  class UrlLanguageSwitcher
    def initialize(store)
      @store = store
    end

    # Adds language code to URL in "href" variable by "pattern" variable and own lang_code.
    #  When lang_code is 'ja', add_lang_code('https://wovn.io', 'path', url) returns 'https://wovn.io/ja/'.
    # @param  [String] href original URL. (This condition is not validated against)
    # @param  [String] to_lang_code language code.
    def add_lang_code(href, to_lang_code, headers)
      return nil if href.nil?
      return href if href.match?(/^(#.*)?$/)

      href_scheme = href[/^[A-Za-z][A-Za-z0-9+\-.]*(?=:)/]
      return href if !href_scheme.nil? && href_scheme != 'http' && href_scheme != 'https'

      code_to_add = @store.custom_lang_aliases[to_lang_code] || to_lang_code
      if Wovnrb::URL.absolute_url?(href)
        add_lang_code_absolute_url(href, code_to_add, headers)
      else
        add_lang_code_relative_url(href, code_to_add, headers)
      end
    end

    # Removes language code from a URI component (path, hostname, query etc), and returns it.
    #
    # @param uri     [String] original URI component
    # @param lang    [String] language code
    # @param headers [Header] headers
    # @return        [String] removed URI
    def remove_lang_from_uri_component(uri, lang, headers = nil)
      lang_code = @store.settings['custom_lang_aliases'][lang] || lang

      return uri if lang_code.blank?

      case @store.settings['url_pattern']
      when 'query'
        lang_param_name = @store.settings['lang_param_name']
        uri.sub(/(^|\?|&)#{lang_param_name}=#{lang_code}(&|$)/, '\1').gsub(/(\?|&)$/, '')
      when 'subdomain'
        rp = Regexp.new("(^|(//))#{lang_code}\\.", 'i')
        uri.sub(rp, '\1')
      when 'path'
        # ^(.*://|//)?  1: schema (optional) like https://
        # ([^/]*/)?     2: host (optional) like wovn.io, with trailing '/' (mandatory)
        # (/|$)         3: path or end-of-string
        lang_code_pattern = %r{^(.*://|//)?([^/]*/)?#{lang_code}(/|$)}
        uri.sub(lang_code_pattern, '\1\2')
      when 'custom_domain'
        custom_domain_langs = @store.custom_domain_langs
        custom_domain_lang_to_remove = custom_domain_langs.custom_domain_lang_by_lang(lang_code)
        default_custom_domain_lang = custom_domain_langs.custom_domain_lang_by_lang(@store.default_lang)
        new_uri = uri
        if Wovnrb::URL.absolute_url?(uri)
          new_uri = CustomDomainLangUrlHandler.change_to_new_custom_domain_lang(uri, custom_domain_lang_to_remove, default_custom_domain_lang)
        elsif Wovnrb::URL.absolute_path?(uri)
          absolute_url = "#{headers.protocol}://#{headers.unmasked_host}#{uri}"
          absolute_url_with_lang = CustomDomainLangUrlHandler.change_to_new_custom_domain_lang(absolute_url, custom_domain_lang_to_remove, default_custom_domain_lang)
          segments = make_segments_from_absolute_url(absolute_url_with_lang)
          new_uri = segments['others']
        elsif uri == custom_domain_lang_to_remove.host
          absolute_url = "#{headers.protocol}://#{uri}#{headers.unmasked_pathname}"
          absolute_url_with_lang = CustomDomainLangUrlHandler.change_to_new_custom_domain_lang(absolute_url, custom_domain_lang_to_remove, default_custom_domain_lang)
          segments = make_segments_from_absolute_url(absolute_url_with_lang)
          new_uri = segments['host']
        end
        new_uri
      else
        raise RuntimeError("Invalid URL pattern: #{@store.settings['url_pattern']}")
      end
    end

    private

    delegate :default_lang_alias, to: :@store

    def add_lang_code_absolute_url(href, code_to_add, headers)
      # in the future, perhaps validate url rather than using begin rescue
      # "#{url =~ /\// ? 'http:' : ''}#{url}" =~ URI::regexp
      begin
        href_uri = Addressable::URI.parse(href)
      rescue Addressable::URI::InvalidURIError, ArgumentError => e
        Rollbar.warning('Failed to parse URI', original_error: e, href: href)
        return href
      end

      if internal_link?(href_uri, headers.host)
        return case @store.settings['url_pattern']
               when 'subdomain'
                 sub_d = href.match(%r{//([^.]*)\.})[1]
                 sub_code = Lang.get_code(sub_d)
                 if sub_code&.casecmp(code_to_add.downcase)&.zero?
                   href.sub(Regexp.new(code_to_add, 'i'), code_to_add.downcase)
                 else
                   href.sub(%r{(//)([^.]*)}, "\\1#{code_to_add.downcase}.\\2")
                 end
               when 'query'
                 add_query_lang_code(href, code_to_add)
               when 'custom_domain'
                 CustomDomainLangUrlHandler.add_custom_domain_lang_to_absolute_url(href, code_to_add, @store.custom_domain_langs)
               else # path
                 href_uri.path = add_lang_code_for_path(href_uri.path, code_to_add, headers)
                 href_uri.to_s
               end
      end

      href
    end

    def internal_link?(absolute_uri, host_name)
      absolute_uri.host == host_name.split(':')[0]
    end

    def add_lang_code_relative_url(href, code_to_add, headers)
      begin
        abs_path = normalize_absolute_path(headers.to_absolute_path(href), headers)
      rescue Addressable::URI::InvalidURIError, ArgumentError
        return href
      end

      case @store.url_pattern
      when 'subdomain'
        "#{headers.protocol}://#{code_to_add.downcase}.#{headers.host}#{abs_path}"
      when 'query'
        add_query_lang_code(href, code_to_add)
      when 'custom_domain'
        if Wovnrb::URL.absolute_path?(href)
          absolute_url = "#{headers.protocol}://#{headers.unmasked_host}#{href}"
          absolute_url_with_lang = CustomDomainLangUrlHandler.add_custom_domain_lang_to_absolute_url(absolute_url, code_to_add, @store.custom_domain_langs)
          segments = make_segments_from_absolute_url(absolute_url_with_lang)
          segments['others']
        else
          href
        end
      else # path
        add_lang_code_for_path(href, code_to_add, headers)
      end
    end

    def add_lang_code_for_path(href, code_to_add, headers)
      new_href = href

      if code_to_add != @store.default_lang || code_to_add == @store.default_lang_alias
        new_href = headers.to_absolute_path(href)
        lang_prefix_path = build_lang_path(code_to_add)
        prefix_path = build_lang_path('')
        suffix_path = new_href.sub(%r{^#{prefix_path}(/|$)}, '')
                              .sub(%r{^#{@store.default_lang}(/|$)}, '')
        new_href = URL.join_paths(lang_prefix_path, suffix_path)
        new_href = URL.normalize_path_slash(href, new_href)
        new_href
      end

      normalize_absolute_path(new_href, headers)
    end

    def normalize_absolute_path(input_path, headers)
      URL.resolve_absolute_path(headers.url_with_scheme, input_path)
    end

    def sub_repeat!(string, pattern, replacement)
      loop do
        break unless string.sub!(pattern, replacement)
      end
    end

    def add_query_lang_code(href, lang_code)
      lang_param = @store.settings['lang_param_name']
      return href if href.match?(/(&|&amp;|\?)?#{lang_param}=[a-zA-Z_-]+/)

      query_separator = href.include?('?') ? '&' : '?'
      href.sub(/(#|$)/, "#{query_separator}#{lang_param}=#{lang_code}\\1")
    end

    def build_lang_path(lang_code)
      lang_code.blank? ? '' : URL.prepend_path_slash(lang_code)
    end

    def make_segments_from_absolute_url(absolute_uri)
      # 1: schema (optional) like https://
      # 2: host (optional) like wovn.io
      # 3: path with query or hash
      regex = %r{^(.*://|//)?([^/?]*)?((?:/|\?|#).*)?$}
      matches = regex.match(absolute_uri)

      {
        'schema' => matches[1],
        'host' => matches[2],
        'others' => matches[3]
      }
    end
  end
end
