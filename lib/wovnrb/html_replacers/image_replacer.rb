module Wovnrb
  class ImageReplacer < ReplacerBase
    def initialize(store, url, text_index, src_index, img_src_prefix, host_aliases)
      super(store)
      @url = url
      @text_index = text_index
      @src_index = src_index
      @img_src_prefix = img_src_prefix
      @host_aliases = host_aliases
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
              src = join_path("#{@url[:protocol]}://#{@url[:host]}", src)
            else
              src = join_path("#{@url[:protocol]}://#{@url[:host]}#{@url[:path]}", src)
            end
          end

          unless replace_src_if_match(node, lang, src)
            # host name exclude port number
            host_match = %r!://([^/:]+)!.match(src)
            host_name = host_match ? host_match[1] : ''

            # replace image if match host alias
            if host_match and @host_aliases.include?(host_name)
              @host_aliases.find do |host_alias|
                src_alias = src.gsub(host_name, host_alias)
                replace_src_if_match(node, lang, src_alias)
              end
            end
          end
        end

        if node.get_attribute('alt')
          alt = node.get_attribute('alt').strip
          if @text_index[alt] && @text_index[alt][lang.lang_code] && @text_index[alt][lang.lang_code].size > 0
            add_comment_node(node, alt)
            node.attribute('alt').value = replace_text(alt, @text_index[alt][lang.lang_code][0]['data'])
          end
        end
      end
    end

    private
    def replace_src_if_match(node, lang, src)
      # shouldn't need size check, but for now...
      if @src_index[src] && @src_index[src][lang.lang_code] && @src_index[src][lang.lang_code].size > 0
        node.attribute('src').value = "#{@img_src_prefix}#{@src_index[src][lang.lang_code][0]['data']}"
      end
    end

    def join_path(x, y)
      separator = (x[-1] != '/' and y[0] != '/') ? '/' : ''
      "#{x}#{separator}#{y}"
    end
  end
end
