module Wovnrb
  class MetaReplacer < ReplacerBase
    def initialize(store, text_index, pattern = nil, headers = nil)
      super(store)
      @text_index = text_index
      @pattern = pattern
      @headers = headers
    end

    def replace(dom, lang)
      dom.xpath('.//meta').select { |node|
        next if wovn_ignore?(node)
        (node.get_attribute('name') || node.get_attribute('property') || '') =~ /^(description|title|og:title|og:description|og:url|twitter:title|twitter:description)$/
      }.each do |node|
        node_content = node.get_attribute('content').strip
        if @headers && @pattern && node.get_attribute('property') && node.get_attribute('property') === 'og:url'
          new_url = lang.add_lang_code(node_content, @pattern, @headers)
          node.set_attribute('content', new_url)
          next
        end
        # shouldn't need size check, but for now...
        if @text_index[node_content] && @text_index[node_content][lang.lang_code] && @text_index[node_content][lang.lang_code].size > 0
          node.set_attribute('content', replace_text(node.get_attribute('content'), @text_index[node_content][lang.lang_code][0]['data']))
        end
      end
    end
  end
end
