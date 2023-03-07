module Wovnrb
  # Represents a custom domain for a given language
  class CustomDomainLang
    attr_accessor :host, :path, :lang

    def initialize(host, path, lang)
      @host = host
      @path = path[-1] == '/' ? path : "#{path}/"
      @lang = lang
    end

    # @param uri [Addressable::URI]
    def match?(uri)
      host = uri.host
      path = uri.path.presence || '/'
      @host.casecmp(host).zero? && path_is_equal_or_subset_of(@path, path)
    end

    def host_and_path_without_trailing_slash
      host_and_path = @host + @path
      host_and_path[-1] == '/' ? host_and_path[0..-2] : host_and_path
    end

    private

    def path_is_equal_or_subset_of(orig_path, test_path)
      # split by delimiter and remove spaces and empty strings
      orig_segments = orig_path.split('/').map(&:strip).select(&:present?)
      test_segments = test_path.split('/').map(&:strip).select(&:present?)

      length = orig_segments.length
      diff = orig_segments.slice(0, length) <=> test_segments.slice(0, length)

      diff == 0
    end
  end
end
