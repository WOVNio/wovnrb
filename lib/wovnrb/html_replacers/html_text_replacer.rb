module Wovnrb
  class HTMLTextReplacer < ReplacerBase
    def initialize(text_index, html_text_index)
      @text_index = text_index
      @html_text_index = html_text_index
    end

    def replace(dom, lang)
      # TODO detect text values (complex or not) and call swap_val on them
    end

    private
    def swap_val(node, index, lang)
      if node.name.downcase != 'text'
        swap_complex_val(node, index, lang)
      else
        node_text = node.content.strip

        if @text_index[node_text] && @text_index[node_text][lang.lang_code] && @text_index[node_text][lang.lang_code].size > 0
          node.content = replace_text(node.content, @text_index[node_text][lang.lang_code][0]['data'])
        end
      end
    end

    def swap_complex_val(node, index, lang)
      # TODO
    end
  end
end
