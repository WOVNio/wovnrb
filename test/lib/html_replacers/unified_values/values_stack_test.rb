require 'test_helper'

module Wovnrb
  module UnifiedValues
    class ValueStackTest < WovnMiniTest
      def setup
        @doc = Nokogiri('<html></html>')
      end

      def test_initialize
        stack = ValuesStack.new('/html/body/path', 10)
        assert_equal('/html/body/path', stack.instance_variable_get(:@head_path))
        assert_equal(10, stack.instance_variable_get(:@index))
        assert_equal([], stack.instance_variable_get(:@node_stack))
        assert_equal([], stack.instance_variable_get(:@src_stack))
        assert_equal([], stack.instance_variable_get(:@src_without_tag_stack))
      end

      def test_add
        stack = ValuesStack.new('/html/body/path', 10)
        assert_equal([], stack.instance_variable_get(:@src_stack))
        assert_equal([], stack.instance_variable_get(:@src_without_tag_stack))

        text_node = Nokogiri::XML::Text.new('hello', @doc)
        stack.add(text_node, 'hello')
        assert_equal([text_node], stack.instance_variable_get(:@node_stack))
        assert_equal(['hello'], stack.instance_variable_get(:@src_stack))
        assert_equal([], stack.instance_variable_get(:@src_without_tag_stack))
      end

      def test_add_with_spaces
        stack = ValuesStack.new('/html/body/path', 10)
        assert_equal([], stack.instance_variable_get(:@src_stack))

        text_node = Nokogiri::XML::Text.new('   hello   ', @doc)
        stack.add(text_node, '   hello   ')
        assert_equal([text_node], stack.instance_variable_get(:@node_stack))
        assert_equal(['hello'], stack.instance_variable_get(:@src_stack))
      end

      def test_add_text_element
        stack = ValuesStack.new('/html/body/path', 10)
        assert_equal([], stack.instance_variable_get(:@src_stack))
        assert_equal([], stack.instance_variable_get(:@src_without_tag_stack))

        text_node = Nokogiri::XML::Text.new('hello', @doc)
        stack.add_text_element(text_node, 'hello')
        assert_equal([text_node], stack.instance_variable_get(:@node_stack))
        assert_equal(['hello'], stack.instance_variable_get(:@src_stack))
        assert_equal(['hello'], stack.instance_variable_get(:@src_without_tag_stack))
      end

      def test_add_text_element_with_special_character
        stack = ValuesStack.new('/html/body/path', 10)
        assert_equal([], stack.instance_variable_get(:@src_stack))
        assert_equal([], stack.instance_variable_get(:@src_without_tag_stack))
        text_node = Nokogiri::XML::Text.new('   <hello>   ', @doc)
        stack.add_text_element(text_node, '   <hello>   ')
        assert_equal([text_node], stack.instance_variable_get(:@node_stack))
        assert_equal(['&lt;hello&gt;'], stack.instance_variable_get(:@src_stack))
        assert_equal(['<hello>'], stack.instance_variable_get(:@src_without_tag_stack))
      end

      def test_blank
        stack = ValuesStack.new('/html/body/path', 10)
        assert_equal(true, stack.blank?)
        text_node = Nokogiri::XML::Text.new('hello', @doc)
        stack.add(text_node, 'hello')
        assert_equal(false, stack.blank?)
      end

      def test_path
        stack = ValuesStack.new('/html/body/path', 10)
        assert_equal('/html/body/path/text()[10]', stack.path)
      end

      def test_path_first_index
        stack = ValuesStack.new('/html/body/path', 1)
        assert_equal('/html/body/path/text()', stack.path)
      end

      def test_path_title
        stack = ValuesStack.new('/html/head/title', 1)
        assert_equal('/html/head/title', stack.path)
      end

      def test_src
        stack = ValuesStack.new('/html/body/path', 10)
        stack.instance_variable_set(:@src_stack, ['hello', '<span>', 'world'])
        assert_equal('hello<span>world', stack.src)
      end

      def test_src_without_tag
        stack = ValuesStack.new('/html/body/path', 10)
        stack.instance_variable_set(:@src_without_tag_stack, ['hello', '<span>', 'world'])
        assert_equal('hello<span>world', stack.src_without_tag)
      end

      def test_build_next_stack
        stack = ValuesStack.new('/html/body/path', 10)
        node1 = Nokogiri::XML::Text.new('hello', @doc)
        node2 = Nokogiri::XML::Node.new('span', @doc)
        node3 = Nokogiri::XML::Text.new('world', @doc)
        stack.instance_variable_set(:@node_stack, [node1, node2, node3])
        stack.instance_variable_set(:@src_stack, ['hello', '<span>', 'world'])
        stack.instance_variable_set(:@src_without_tag_stack, ['hello', '<span>', 'world'])
        assert_equal('/html/body/path', stack.instance_variable_get(:@head_path))
        assert_equal(10, stack.instance_variable_get(:@index))
        assert_equal([node1, node2, node3], stack.instance_variable_get(:@node_stack))
        assert_equal(['hello', '<span>', 'world'], stack.instance_variable_get(:@src_stack))
        assert_equal(['hello', '<span>', 'world'], stack.instance_variable_get(:@src_without_tag_stack))

        next_stack = stack.build_next_stack
        assert_equal('/html/body/path', next_stack.instance_variable_get(:@head_path))
        assert_equal(11, next_stack.instance_variable_get(:@index))
        assert_equal([], next_stack.instance_variable_get(:@node_stack))
        assert_equal([], next_stack.instance_variable_get(:@src_stack))
        assert_equal([], next_stack.instance_variable_get(:@src_without_tag_stack))
      end
    end
  end
end
