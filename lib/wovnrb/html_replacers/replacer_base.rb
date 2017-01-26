module Wovnrb
  class ReplacerBase
    def replace(dom, lang)
      raise NotImplementedError.new('replace is not defined')
    end

    protected
    def wovn_ignore?(node)
      if !node.get_attribute('wovn-ignore').nil?
        return true
      elsif node.name === 'html'
        return false
      end
      wovn_ignore?(node.parent)
    end

    # Add comment-node node to remember original src
    # <title> may not contain other markup, so add comment-node to node's previous
    # @see https://www.w3.org/TR/html401/struct/global.html#h-7.4.2
    def add_comment_node(node, text)
      comment_node = Nokogiri::XML::Comment.new(node, "wovn-src:#{text}")
      if node.parent.name == 'title'
        node.parent.add_previous_sibling(comment_node)
      else
        node.add_previous_sibling(comment_node)
      end
    end

    def replace_text(from, to)
      from.gsub(/\A(\s*)[\S\s]*?(\s*)\Z/, '\1' + to + '\2')
    end
  end
end
