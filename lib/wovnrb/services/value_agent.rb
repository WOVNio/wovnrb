module Wovnrb
  class ValueAgent
    def self.normalize_text(src)
      src.gsub(/[\ufffd]/, "\b")
          .gsub(/[\n \t\u0020\u0009\u000C\u200B\u000D\u000A]+/, ' ')
          .gsub(/^[\s\u00A0\uFEFF\u1680\u180E\u2000-\u200A\u202F\u205F\u3000]+|[\s\u00A0\uFEFF\u1680\u180E\u2000-\u200A\u202F\u205F\u3000]+$/, '')
    end
  end
end
