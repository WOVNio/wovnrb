module Wovnrb
  # inspired from https://github.com/isaacs/node-glob
  #
  # "*" Matches 0 or more characters in a single path portion
  # "**" If a "globstar" is alone in a path portion,
  #   then it matches zero or more directories and subdirectories searching for matches.
  #
  # @note "?" or other pattern is not implemented
  class Glob
    def initialize(pattern)
      sub_directories = pattern.split('/**', -1)
      regexp = sub_directories.map do |sub_dir|
        sub_dir.split('*', -1)
          .map {|p| Regexp.escape(p)}
          .join('[^/]*')
      end.join('(/[^/]*)*')

      @regexp = Regexp.new("^#{regexp}$")
    end

    def match?(url)
      !@regexp.match(url).nil?
    end
  end
end