module Wovnrb
  class HTMLTextReplacer < ReplacerBase
    NON_RECURSIVE_TEXT_CONTAINERS = ['div', 'p', 'pre', 'blockquote', 'figcaption', 'address', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'li', 'dt', 'dd', 'th', 'td']
    INLINE_TEXT_CONTAINERS = ['span', 'a', 'em', 'strong', 'small', 'tt', 's', 'cite', 'q', 'dfn', 'abbr', 'time', 'code', 'var', 'samp', 'sub', 'sup', 'i', 'b', 'kdd', 'mark', 'u', 'rb', 'rt', 'rtc', 'rp', 'bdi', 'bdo', 'wbr', 'nobr']
    ALLOWED_WITHIN_TEXT_CONTAINERS = ['br', 'img', 'ruby', 'ul', 'ol']

    def initialize(text_index, html_text_index)
      @text_index = text_index
      @html_text_index = html_text_index

      @non_recursive_text_containers = NON_RECURSIVE_TEXT_CONTAINERS
      @inline_text_containers = INLINE_TEXT_CONTAINERS
      @allowed_within_text_containers = ALLOWED_WITHIN_TEXT_CONTAINERS

      @scraper = HTMLTextScraper.new(
        @non_recursive_text_containers,
        @inline_text_containers,
        @allowed_within_text_containers
      )
    end

    def replace(dom, lang)
      replace_node(dom.xpath('/html')[0], lang)
    end

    private
    def replace_node(node, lang)
      return if wovn_ignore?(node)

      if @scraper.is_text_value?(node)
        data = @scraper.get_complex_data(node)
        return unless data

        index = (node.name.downcase == 'text') ? @text_index : @html_text_index
        new_value = get_complex_value(data, lang, index)
        return unless new_value

        swap_val(node, new_value)
      else
        if node.children
          node.children.each do |child|
            replace_node(child, lang)
          end
        end
      end
    end

    def get_complex_value(data, lang, index)
      lang_code = lang.lang_code
      if index[data] && index[data][lang_code] && index[data][lang_code].size > 0
        new_value = index[data][lang.lang_code][0]['data']
      end
    end

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
      align_nodes(src_node, dst_node)
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
      dom = Nokogiri::HTML5("<html><body><div>#{str}</div></body></html>")
      return dom.xpath("/html/body/div").first
    end

    # Aligns two nodes for swaping.
    # If one node has more children, then it should be a text node a the
    # begginning or the end. If so, an empty text node is added to the node with
    # less children.
    #
    # @param [Nokogiri::XML::Node] node_1 The first node to align.
    # @param [Nokogiri::XML::Node] node_2 The second node to align.
    def align_nodes(node_1, node_2)
      ajust_node_alignment(node_1)
      ajust_node_alignment(node_2)
    end

    def ajust_node_alignment(node)
      if node.children.first.name.downcase != 'text'
        if node.children.count > 0
          node.children[0].add_previous_sibling(Nokogiri::XML::Text.new('', node.document))
        else
          node.add_child(Nokogiri::XML::Text.new('', node.document))
        end
      end

      if node.children.last.name.downcase != 'text'
        node.add_child(Nokogiri::XML::Text.new('', node.document))
      end
    end
  end
end
