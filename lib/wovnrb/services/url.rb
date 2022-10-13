module Wovnrb
  # URL utility ported from html-swapper
  class URL
    module FileExtension
      IMG_FILES = 'jpe|jpe?g|bmp|gif|png|btif|tiff?|psd|djvu?|xif|wbmp|webp|p(n|b|g|p)m|rgb|tga|x(b|p)m|xwd|pic|ico|fh(c|4|5|7)?|xif|f(bs|px|st)'.freeze
      AUDIO_FILES = 'mp(3|2)|m(p?2|3|p?4|pg)a|midi?|kar|rmi|web(m|a)|aif(f?|c)|w(ma|av|ax)|m(ka|3u)|sil|s3m|og(a|g)|uvv?a'.freeze
      VIDEO_FILES = 'm(x|4)u|fl(i|v)|3g(p|2)|jp(gv|g?m)|mp(4v?|g4|(?!$)e?g?)|m(1|2)v|ogv|m(ov|ng)|qt|uvv?(h|m|p|s|v)|dvb|mk(v|3d|s)|f4v|as(x|f)|w(m(v|x)|vx)|xvid'.freeze
      DOC_FILES = '(7|g)?zip|tar|rar|7z|gz|ez|aw|atom(cat|svc)?|(cc)?xa?ml|cdmi(a|c|d|o|q)?|epub|g(ml|px|xf)|jar|js|ser|class|json(ml)?|do(c|t)(m|x)?|xls(m|x)?|xps|pp(a|tx?|s)m?|potm?|sldm|mp(p|t)|bin|dms|lrf|mar|so|dist|distz|m?pkg|bpk|dump|rtf|tfi|pdf|pgp|apk|o(t|d)(b|c|ft?|g|h|i|p|s|t)'.freeze
    end

    # TODO: Maybe this should be applied to all get_attribute calls rather than just href
    def self.normalize_url(href)
      return nil unless href

      href.delete("\u200b").strip
    end

    def self.absolute_url?(href)
      href =~ %r{^(https?:)?//}i
    end

    def self.absolute_path?(href)
      href.match?(%r{^/})
    end

    def self.relative_path?(href)
      !absolute_url?(href) && !absolute_path?(href)
    end

    # @param parsed_uri [Addressable::URI]
    def self.path_and_query(parsed_uri)
      parsed_uri.path + (parsed_uri.query ? "?#{parsed_uri.query}" : '')
    end

    def self.path_and_query_and_hash(parsed_uri)
      uri = parsed_uri.path
      uri += "?#{parsed_uri.query}" if parsed_uri.query
      uri += "##{parsed_uri.fragment}" if parsed_uri.fragment
      uri
    end

    def self.host_with_port(parsed_uri)
      if parsed_uri.port
        "#{parsed_uri.host}:#{parsed_uri.port}"
      else
        parsed_uri.host.to_s
      end
    end

    def self.resolve_absolute_uri(base_url, href)
      # This resolves ./../ and also handles href already being absolute
      Addressable::URI.join(base_url, href)
    rescue Addressable::URI::InvalidURIError, ArgumentError => e
      Rollbar.warning('Failed to resolve absolute URI', original_error: e, base_url: base_url, href: href)
      raise
    end

    def self.resolve_absolute_path(base_url, href)
      normalized_uri = resolve_absolute_uri(base_url, href)
      path = normalized_uri.path
      query = normalized_uri.query ? "?#{normalized_uri.query}" : ''
      fragment = normalized_uri.fragment ? "##{normalized_uri.fragment}" : ''

      path + query + fragment
    end

    # Set the path lang to
    def self.prepend_path(url, dir)
      url.sub(%r{(.+\.[^/]+)(/|$)}, "\\1/#{dir}\\2")
    end

    def self.trim_slashes(path)
      path.gsub(%r{^/|/$}, '')
    end

    def self.prepend_path_slash(path)
      path ||= ''
      return path if path.starts_with?('/')

      "/#{path}"
    end

    def self.join_paths(*paths)
      paths.inject('') do |left, right|
        case [left.end_with?('/'), right.start_with?('/')]
        when [true, true]
          left + right[1..]
        when [false, false]
          left + (right.blank? ? right : "/#{right}")
        else
          left + right
        end
      end
    end

    # @param uri [Addressable::URI]
    # @param new_protocol [String | nil]
    # @return copy of uri [Addressable::URI]
    def self.change_protocol(uri, new_protocol)
      result = uri.dup
      result.scheme = new_protocol
      result
    end

    def self.valid_protocol?(href)
      scheme_matches = /^\s*(?<scheme>[a-zA-Z]+):/.match(href)
      scheme = scheme_matches ? scheme_matches[:scheme] : nil

      scheme.nil? || %w[http https].include?(scheme)
    end

    def self.file?(href_with_query_and_hash)
      href = remove_query_and_hash(href_with_query_and_hash)
      img_files = %r{^(https?://)?.*(\.(#{FileExtension::IMG_FILES}))((\?|#).*)?$}io
      audio_files = %r{^(https?://)?.*(\.(#{FileExtension::AUDIO_FILES}))((\?|#).*)?$}io
      video_files = %r{^(https?://)?.*(\.(#{FileExtension::VIDEO_FILES}))((\?|#).*)?$}io
      doc_files = %r{^(https?://)?.*(\.(#{FileExtension::DOC_FILES}))((\?|#).*)?$}io
      href.match?(img_files) || href.match?(audio_files) || href.match?(video_files) || href.match?(doc_files)
    end

    def self.remove_query_and_hash(href)
      href.gsub(/[#?].*/, '')
    end

    # if original path does not end in slash, remove it from new path
    # if original path ends in slash, add it to new path
    def self.normalize_path_slash(original_path, new_path)
      if !original_path.end_with?('/') && new_path.end_with?('/')
        new_path = new_path.chomp('/')
      elsif original_path.end_with?('/') && !new_path.end_with?('/')
        new_path += '/'
      end
      new_path
    end
  end
end
