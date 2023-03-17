module Wovnrb
  # Represents a custom domain for a given language
  class CustomDomainLang
    attr_accessor :host, :path, :lang

    def initialize(host, path, lang)
      @host = host
      @path = path.end_with?('/') ? path : "#{path}/"
      @lang = lang
    end

    # @param uri [Addressable::URI]
    def match?(parsed_uri)
      @host.casecmp?(parsed_uri.host) && path_is_equal_or_subset_of?(@path, parsed_uri.path)
    end

    def host_and_path_without_trailing_slash
      host_and_path = @host + @path
      host_and_path.end_with?('/') ? host_and_path.delete_suffix('/') : host_and_path
    end

    private

    def path_is_equal_or_subset_of?(path1, path2)
      path1_segments = path1.split('/').reject(&:empty?)
      path2_segments = path2.split('/').reject(&:empty?)

      path1_segments == path2_segments.slice(0, path1_segments.length)
    end
  end
end
