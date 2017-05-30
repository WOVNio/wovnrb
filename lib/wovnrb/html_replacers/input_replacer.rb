module Wovnrb
  class InputReplacer < ReplacerBase
    def initialize(text_index)
      @text_index = text_index
    end

    def replace(dom, lang)
      dom.xpath('//input').each do |node|
        next if wovn_ignore?(node)

        set_attribute('value', node, lang)       if replaceable_value? node
        set_attribute('placeholder', node, lang) if replaceable_placeholder? node
      end
    end

    private

    def set_attribute(name, node, lang)
      node_value = node.get_attribute(name).strip
      if @text_index[node_value] && @text_index[node_value][lang.lang_code] && @text_index[node_value][lang.lang_code].size > 0
        node.set_attribute(name, replace_text(node_value, @text_index[node_value][lang.lang_code][0]['data']))
      end
    end

    def replaceable_value?(node)
      return false unless ['submit', 'reset'].include? node.get_attribute('type')

      attribute_value = node.get_attribute('value')
      attribute_value && !attribute_value.empty?
    end

    def replaceable_placeholder?(node)
      attribute_placeholder = node.get_attribute('placeholder')
      attribute_placeholder && !attribute_placeholder.empty?
    end
  end
end
