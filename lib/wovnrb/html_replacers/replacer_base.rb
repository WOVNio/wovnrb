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

    def replace_text(from, to)
      from.gsub(/\A(\s*)[\S\s]*?(\s*)\Z/, '\1' + to + '\2')
    end
  end
end
