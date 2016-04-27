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
          node.content = replace_text(node.content, @text_index[node_text][lang.lang_code][0]['data'])
        end
      end
    end
  end
end
