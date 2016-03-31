module Wovnrb
  class TextReplacer < ReplacerBase
    def initialize(text_index)
      @text_index = text_index
    end

    def replace(dom, lang)
      dom.xpath('//text()').each do |node|
        next if wovn_ignore?(node)

        node_text = node.content.strip
        # shouldn't need size check, but for now...
        if @text_index[node_text] && @text_index[node_text][lang.lang_code] && @text_index[node_text][lang.lang_code].size > 0
          node.content = node.content.gsub(/^(\s*)[\S\s]*?(\s*)$/, '\1' + @text_index[node_text][lang.lang_code][0]['data'] + '\2')
        end
      end
    end
  end
end
