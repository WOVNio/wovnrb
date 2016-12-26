module Wovnrb
  class TextUtil
    def self.empty_text?(text)
      normalized_text = normalize_text(text)

      # assume empty if the src is only contains special characters
      normalized_text = normalized_text.gsub(/^[`~!@#$%\^&*()\-_=+\[\{\]\}|;:'",\/\\?]+$/, '')

      normalized_text.empty?
    end

    def self.normalize_text(text)
      normalized_text = text.gsub(/&nbsp;/i, ' ')
      normalized_text.gsub(/[\n \t\u0020\u0009\u000C\u200B\u000D\u000A]+/, ' ').gsub(/^[\s\u00A0\uFEFF\u1680\u180E\u2000-\u200A\u202F\u205F\u3000]+|[\s\u00A0\uFEFF\u1680\u180E\u2000-\u200A\u202F\u205F\u3000]+$/, '')
    end
  end
end