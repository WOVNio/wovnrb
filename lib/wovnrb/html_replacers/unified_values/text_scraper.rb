module Wovnrb
  module UnifiedValues
    class TextScraper
      def initialize(ignored_class_set)
        @ignored_class_set = ignored_class_set
        @values = []
        @values_stack = nil
      end

      def run(dom)
        refresh_all!
        @values_stack = ValuesStack.new(dom.path, 1)
        scrape(dom)
      end

      def create_text_value(src, node_stack)
        { dst: ValueAgent.normalize_text(src.gsub(/&nbsp;/i, ' ')), nodes: node_stack }
      end

      private

      def scrape(dom)
        type = stop_recursion_type(dom)
        if type
          case type
          when 'ignore_element', 'skip_element'
            next_stack = @values_stack.build_next_stack
            build_src
            @values_stack = next_stack
          when 'text_element'
            @values_stack.add_text_element(dom, dom.content)
          when 'empty_element'
            @values_stack.add(dom, empty_tag(dom))
          when 'comment_element'
            # do nothing
          else
            raise 'Unsupported type'
          end
        elsif inline_element?(dom)
          @values_stack.add(dom, start_tag(dom))
          scrape_children_of(dom)
          @values_stack.add(dom, end_tag(dom)) unless @values_stack.blank?
        elsif block_element?(dom)
          next_stack = @values_stack.build_next_stack
          build_src
          @values_stack = ValuesStack.new(dom.path, 1)
          scrape_children_of(dom)
          build_src
          @values_stack = next_stack
        else
          next_stack = @values_stack.build_next_stack
          build_src
          @values_stack = ValuesStack.new(dom.path, 1)
          scrape_children_of(dom)
          build_src
          @values_stack = next_stack
        end

        @values
      end

      def scrape_children_of(dom)
        dom.children.each { |c| scrape(c) } unless wovn_ignore_element?(dom)
      end

      def build_src
        return nil if @values_stack.blank?

        src = @values_stack.src
        @values << create_text_value(src, @values_stack.node_stack) if src.present? && !tag_only?(src)
        @values_stack = nil
      end

      def tag_only?(src)
        Nokogiri::HTML5.fragment(src).text.blank?
      end

      def start_tag(dom)
        if wovn_ignore_element?(dom)
          "<#{dom.name} wovn-ignore>"
        else
          "<#{dom.name}>"
        end
      end

      def end_tag(dom)
        "</#{dom.name}>"
      end

      def empty_tag(dom)
        start_tag(dom)
      end

      def block_element?(element)
        ElementCategory::BLOCK_ELEMENTS.include?(element.name)
      end

      def inline_element?(element)
        ElementCategory::INLINE_ELEMENTS.include?(element.name)
      end

      def empty_element?(element)
        ElementCategory::EMPTY_ELEMENTS.include?(element.name)
      end

      def ignore_element?(element)
        ElementCategory::IGNORE_ELEMENTS.include?(element.name)
      end

      def skip_element?(element)
        ElementCategory::SKIP_ELEMENTS.include?(element.name)
      end

      def comment_element?(element)
        element.comment?
      end

      def text_element?(element)
        element.text?
      end

      def wovn_ignore_element?(element)
        return false unless element

        return true if element.attribute('wovn-ignore')

        class_attribute = element.attribute('class')
        return false unless class_attribute
        class_attribute.value.split.any? { |c| @ignored_class_set.include?(c) }
      end

      def stop_recursion_type(element)
        return 'ignore_element'  if ignore_element?(element)
        return 'skip_element'    if skip_element?(element)
        return 'text_element'    if text_element?(element)
        return 'empty_element'   if empty_element?(element)
        return 'comment_element' if comment_element?(element)

        nil
      end

      def refresh_all!
        @values_stack = nil
        refresh_values!
      end

      def refresh_values!
        @values = []
      end
    end
  end
end
