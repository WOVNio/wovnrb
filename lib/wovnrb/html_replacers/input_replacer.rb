module Wovnrb
  class InputReplacer < ReplacerBase
    def initialize(text_index)
      @text_index = text_index
    end

    def replace(dom, lang)
      dom.xpath('//input').select { |node|
        next if wovn_ignore?(node)
        (node.get_attribute('value') &&
        node.get_attribute('value') != '' &&
        node.get_attribute('type') &&
        node.get_attribute('type') != 'text' &&
        node.get_attribute('type') != 'hidden' &&
        node.get_attribute('type') != 'password' &&
        node.get_attribute('type') != 'url' &&
        node.get_attribute('type') != 'search')
      }.each do |node|
        node_value = node.get_attribute('value').strip
        # shouldn't need size check, but for now...
        if @text_index[node_value] && @text_index[node_value][lang.lang_code] && @text_index[node_value][lang.lang_code].size > 0
          node.set_attribute('value', replace_text(node.get_attribute('value'), @text_index[node_value][lang.lang_code][0]['data']))
        end
      end
    end
  end
end
