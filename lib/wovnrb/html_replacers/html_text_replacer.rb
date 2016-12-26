module Wovnrb
  class HTMLTextReplacer < ReplacerBase
    def initialize(text_index, html_text_index)
      @text_index = text_index
      @html_text_index = html_text_index
    end

    def replace(dom, lang)
      # TODO detect text values (complex or not) and call swap_val on them
      # TODO remove
      dom.xpath('//text()').each do |node|
        next if wovn_ignore?(node)

        src = node.content.strip
        if @text_index[src] && @text_index[src][lang.lang_code] && @text_index[src][lang.lang_code].size > 0
          dst = @text_index[src][lang.lang_code][0]['data']
          swap_val(node, dst)
        end
      end
      dom.xpath('//p').each do |node|
        next if wovn_ignore?(node)

        src = node.inner_html.strip
        if @html_text_index[src] && @html_text_index[src][lang.lang_code] && @html_text_index[src][lang.lang_code].size > 0
          dst = @html_text_index[src][lang.lang_code][0]['data']
          swap_val(node, dst)
        end
      end
    end

    private
    def swap_val(node, dst)
      if node.name.downcase != 'text'
        swap_complex_val(node, dst)
      else
        node.content = replace_text(node.content, dst)
      end
    end

    def swap_complex_val(node, dst)
      dst_node = (dst.is_a? String) ? data_to_node(dst) : dst
      node_children = node.children
      dst_node_children = dst_node.children

      node_children.each_with_index do |child, i|
        dst_child = dst_node_children[i]

        if child.name.downcase == 'text'
          child.content = replace_text(child.content.strip, dst_child.content.strip)
        else
          swap_complex_val(child, dst_child)
        end
      end

    end

    def data_to_node(str)
      dom = Nokogiri::HTML5("<html><body><div id=\"dst-node\">#{str}</div></body></html>")
      return dom.xpath("//div[@id='dst-node']").first
    end
  end
end
