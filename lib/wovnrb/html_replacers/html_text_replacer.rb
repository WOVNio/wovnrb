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
      replace_node(dom, lang)
    end

    private
    def replace_node(node, lang)
      if @scraper.is_text_value?(node)
        data = @scraper.get_complex_data(node)
        return unless data

        p data
        new_value = get_complex_value(data, lang)
        return unless new_value

        replace_complex_data(n, new_value)
      else
        if node.children
          node.children.each do |child|
            replace_node(child, lang)
          end
        end
      end
    end

    def get_complex_value(original_data, lang)

    end

    def replace_complex_data(node, value)

    end
  end
end
