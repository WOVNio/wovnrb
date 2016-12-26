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
    # Swaps the content of a node by the content of a given string.
    #
    # @param [Nokogiri::XML::Node] node The node from which content must be
    #                                   swapped.
    # @param [String] The content to put in the node.
    def swap_val(node, dst)
      if node.name.downcase != 'text'
        dst_node = data_to_node(dst)
        swap_complex_val(node, dst_node)
      else
        node.content = replace_text(node.content, dst)
      end
    end

    # Swaps the content of a node by the content of a given node.
    #
    # @param [Nokogiri::XML::Node] src_node The node from which content must be
    #                                       swapped.
    # @param [Nokogiri::XML::Node] dst_node The node with the content to put in
    #                                       the src_node.
    def swap_complex_val(src_node, dst_node)
      align_node_to_src(src_node, dst_node)
      src_node_children = src_node.children
      dst_node_children = dst_node.children

      src_node_children.each_with_index do |src_child, i|
        dst_child = dst_node_children[i]

        if src_child.name.downcase == 'text'
          src_child.content = replace_text(src_child.content.strip, dst_child.content)
        else
          swap_complex_val(src_child, dst_child)
        end
      end

    end

    # Creates a node from a HTML string.
    #
    # @param [String] str The string to act as inner HTML.
    #
    # @return [Nokogiri::XML::Node] The node represented be str.
    def data_to_node(str)
      dom = Nokogiri::HTML5("<html><body><div id=\"dst-node\">#{str}</div></body></html>")
      return dom.xpath("//div[@id='dst-node']").first
    end

    # Aligns two nodes for swaping.
    # If one node has more children, then it should be a text node a the
    # begginning or the end. If so, an empty text node is added to the node with
    # less children.
    #
    # @param [Nokogiri::XML::Node] node_1 The first node to align.
    # @param [Nokogiri::XML::Node] node_2 The second node to align.
    def align_node_to_src(node_1, node_2)
      base_node = (node_1.children.count > node_2.children.count) ? node_1 : node_2
      node_to_adjust = (base_node == node_1) ? node_2 : node_1

      if base_node.children.first.name.downcase == 'text' && node_to_adjust.children.first.name.downcase != 'text'
        node_to_adjust.inner_html = "\u200b" + node_to_adjust.inner_html
      elsif base_node.children.last.name.downcase == 'text' && node_to_adjust.children.last.name.downcase != 'text'
        node_to_adjust.inner_html += "\u200b"
      end
    end
  end
end
