module Wovnrb
  class ImageReplacer < ReplacerBase
    def initialize(url, text_index, src_index, img_src_prefix)
      @url = url
      @text_index = text_index
      @src_index = src_index
      @img_src_prefix = img_src_prefix
    end

    def replace(dom, lang)
      dom.xpath('//img').each do |node|
        next if wovn_ignore?(node)

        # use regular expressions to support case insensitivity (right?)
        if node.to_html =~ /src=['"][^'"]*['"]/i
          src = node.to_html.match(/src=['"]([^'"]*)['"]/i)[1]
          # THIS SRC CORRECTION DOES NOT HANDLE ONE IMPORTANT CASE
          # 1) "../path/with/ellipse"
          # if this is not an absolute src
          if src !~ /:\/\//
            # if this is a path with a leading slash
            if src =~ /^\//
              src = "#{@url[:protocol]}://#{@url[:host]}#{src}"
            else
              src = "#{@url[:protocol]}://#{@url[:host]}#{@url[:path]}#{src}"
            end
          end

          # shouldn't need size check, but for now...
          if @src_index[src] && @src_index[src][lang.lang_code] && @src_index[src][lang.lang_code].size > 0
            node.attribute('src').value = "#{@img_src_prefix}#{@src_index[src][lang.lang_code][0]['data']}"
          end
        end

        if node.get_attribute('alt')
          alt = node.get_attribute('alt').strip
          if @text_index[alt] && @text_index[alt][lang.lang_code] && @text_index[alt][lang.lang_code].size > 0
            node.attribute('alt').value = replace_text(alt, @text_index[alt][lang.lang_code][0]['data'])
          end
        end
      end
    end
  end
end
