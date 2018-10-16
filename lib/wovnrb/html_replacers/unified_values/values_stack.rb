require 'wovnrb/services/value_agent'

module Wovnrb
  module UnifiedValues
    class ValuesStack
      attr_reader :node_stack

      # @param head_path [String]
      # @param index [Number]
      #
      # Be careful xpath's index starts with 1
      def initialize(head_path, index)
        @head_path = head_path
        @index = index
        @node_stack = []
        @src_stack = []
        @src_without_tag_stack = []
      end

      # @param node [Nokogiri::XML::Element]
      # @param src [String]
      def add(node, src)
        @node_stack << node if node.name != 'text' || node.content.present?
        @src_stack << Wovnrb::ValueAgent.normalize_text(src)
      end

      # @param node [Nokogiri::XML::Element]
      # @param dom_content [String]
      def add_text_element(node, dom_content)
        add(node, CGI.escapeHTML(dom_content))
        @src_without_tag_stack << Wovnrb::ValueAgent.normalize_text(dom_content)
      end

      # @return [Bool]
      def blank?
        @src_stack.blank?
      end

      # @return [String]
      def path
        return @head_path if @head_path.end_with?('title')

        # Ends with "text()" because some type checking takes path as a normal text when the path ends with "text()"
        p = "#{@head_path}/text()"

        @index == 1 ? p : "#{p}[#{@index}]"
      end

      # @return [String]
      def src
        @src_stack.inject(:+)
      end

      # @return [String]
      def src_without_tag
        @src_without_tag_stack.inject(:+)
      end

      # @return [ValuesStack]
      def build_next_stack
        ValuesStack.new(@head_path, @index + 1)
      end
    end
  end
end
