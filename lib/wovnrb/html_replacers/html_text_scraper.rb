module Wovnrb
  class HTMLTextScraper
    def initialize(non_recursive_containers, inline_containers, allowed_within_text_containers)
      @non_recursive_text_containers = non_recursive_containers
      @inline_text_containers = inline_containers
      @allowed_within_text_containers = allowed_within_text_containers
    end

    def get_complex_data(node)
      is_complex = !is_valid_text_node?(node)
      src = node_to_src(node, is_complex)
      TextUtil.normalize_text(src.gsub(/&nbsp;/i, ' '))
    end

    # Determines if a given HTML node represent a TextValue.
    #
    # @param node [Nokogiri::Node] The node to check.
    #
    # @return [Boolean] True if the node represent a TextValue, false otherwise.
    def is_text_value?(node)
      return true if is_valid_text_node?(node)

      (!is_parent_of_single_text_container?(node) && is_valid_text_container?(node))
    end

    def is_valid_text_node?(node)
      node.name.downcase == 'text' && !TextUtil.empty_text?(node.content)
    end

    # Determines if a given HTML node contains only one text container.
    # In that case we want to continue the scraping further down.
    #
    # @param node [Nokogiri::Node] The node to check.
    #
    # @return [Boolean] True if the node contains a single text container, false
    #                   otherwise.
    def is_parent_of_single_text_container?(node)
      non_empty_child = nil
      if node.children
        node.children.each do |c|
          next if c.name == 'text' && TextUtil.normalize_text(c.text).empty?

          # single_text_container allow only 1 child
          return false if non_empty_child

          non_empty_child = c
        end
      end

      return true unless non_empty_child
      return true if is_valid_text_node?(non_empty_child)
      return true if is_valid_text_container?(non_empty_child)

      false
    end

    # Determines if a given HTML node contains only text.
    #
    # @param node [Nokogiri::Node] The node to check.
    #
    # @return [Boolean] True if the node is a valid text container, false
    #                   otherwise.
    def is_valid_text_container?(node)
      if is_non_recursive_text_container?(node) || is_inline_text_container?(node)
        if node.children
          node.children.each do |child|
            return false unless is_accepted_within_text_container?(child)
          end
        end

        return true
      end

      false
    end

    def is_non_recursive_text_container?(node)
      @non_recursive_text_containers.include?(node.name.downcase)
    end

    def is_inline_text_container?(node)
      @inline_text_containers.include?(node.name.downcase)
    end

    # Tells if a given HTML node is allow to be within a TextValue.
    #
    # @param node [Nokogiri::Node] The node to check.
    #
    # @return [Boolean] True if the node can be within a TextValue, false
    #                   otherwise.
    def is_accepted_within_text_container?(node)
      if !is_non_recursive_text_container?(node) && (@allowed_within_text_containers.include?(node.name.downcase) || is_inline_text_container?(node))
        if node.children
          node.children.each do |child|
            return false unless is_accepted_within_text_container?(child)
          end
        end

        return true
      end

      node.name.downcase == 'text'
    end

    def node_to_src(node, complex, surround=false)
      src = ''
      tag_name = node.name.downcase

      # specific cases
      if tag_name == 'text'
        src = TextUtil.normalize_text(get_node_text(node, complex))
      end

      if /^(br|img)$/ =~ tag_name
        src = format_standalone_tag(tag_name)
      end

      return src unless src.empty?

      content = ''
      node.children.each do |child|
        content += node_to_src(child, complex, true)
      end

      if surround
        format_tag(tag_name, content)
      else
        content
      end
    end

    def get_node_text(node, complex)
      if complex
        CGI::escapeHTML(node.text)
      else
        node.text
      end
    end

    private
    def format_tag(name, content)
      "<#{name}>#{content}</#{name}>"
    end

    def format_standalone_tag(name)
      "<#{name}>"
    end
  end
end
