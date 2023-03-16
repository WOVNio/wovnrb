module Wovnrb
  class HtmlReplaceMarker
    KEY_PREFIX = '__wovn-backend-ignored-key-'.freeze

    def initialize
      @current_key_number = 0
      @mapped_values = []
    end

    # Add argument's value to mapping information with comment style key
    def add_comment_value(value)
      key = "<!-- #{generate_key} -->"
      @mapped_values << [key, value]

      key
    end

    def add_value(value)
      key = generate_key
      @mapped_values << [key, value]

      key
    end

    def revert(marked_html)
      i = @mapped_values.size
      while i > 0
        i -= 1
        key, value = @mapped_values[i]
        marked_html = marked_html.sub(key, value)
      end
      marked_html
    end

    def keys
      @mapped_values.map { |v| v[0] }
    end

    private

    def generate_key
      next_key = "#{KEY_PREFIX}#{@current_key_number}"
      @current_key_number += 1

      next_key
    end
  end
end
