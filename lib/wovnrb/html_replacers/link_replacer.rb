class Wovnrb
  class LinkReplacer < ReplacerBase
    def initialize(pattern, headers)
      @pattern = pattern
      @headers = headers
    end

    def replace(dom, lang)
      dom.xpath('//a').each do |node|
        next if wovn_ignore?(node)

        href = node.get_attribute('href')
        new_href = lang.add_lang_code(href, @pattern, @headers)
        node.set_attribute('href', new_href)
      end
    end
  end
end
