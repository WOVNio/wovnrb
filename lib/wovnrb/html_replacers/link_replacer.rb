module Wovnrb
  class LinkReplacer < ReplacerBase
    module FileExtension
      IMG_FILES = '(?!jp$)jpe?g?|bmp|gif|png|btif|tiff?|psd|djvu?|xif|wbmp|webp|p(n|b|g|p)m|rgb|tga|x(b|p)m|xwd|pic|ico|fh(c|4|5|7)?|xif|f(bs|px|st)'
      AUDIO_FILES = 'mp(3|2)|m(p?2|3|p?4|pg)a|midi?|kar|rmi|web(m|a)|aif(f?|c)|w(ma|av|ax)|m(ka|3u)|sil|s3m|og(a|g)|uvv?a'
      VIDEO_FILES = 'm(x|4)u|fl(i|v)|3g(p|2)|jp(gv|g?m)|mp(4v?|g4|(?!$)e?g?)|m(1|2)v|ogv|m(ov|ng)|qt|uvv?(h|m|p|s|v)|dvb|mk(v|3d|s)|f4v|as(x|f)|w(m(v|x)|vx)|xvid'
      DOC_FILES = 'zip|tar|ez|aw|atom(cat|svc)?|(cc)?xa?ml|cdmi(a|c|d|o|q)?|epub|g(ml|px|xf)|jar|js|ser|class|json(ml)?|do(c|t)m?|xps|pp(a|tx?|s)m?|potm?|sldm|mp(p|t)|bin|dms|lrf|mar|so|dist|distz|m?pkg|bpk|dump|rtf|tfi|pdf|pgp|apk|o(t|d)(b|c|ft?|g|h|i|p|s|t)'
    end

    def initialize(store, pattern, headers)
      super(store)
      @pattern = pattern
      @headers = headers
    end


    def replace(dom, lang)
      base_url = base_href(dom)

      dom.xpath('//*[match(.)]', MultiTagMatcher.new).each do |node|
        next if wovn_ignore?(node)

        href = node.get_attribute('href')
        next if href =~ /^\s*\{\{.+\}\}\s*$/
        next if href =~ /^\s*javascript:/i
        next if is_file?(href)

        new_href = href
        new_href = adjust_link_by_base(new_href, base_url) if base_url
        new_href = lang.add_lang_code(new_href, @pattern, @headers)

        node.set_attribute('href', new_href)
      end
    end

    private

    def adjust_link_by_base(href, base_url)
      return href if href =~ /^\//            # absolute path
      return href if href =~ /^http(s?):\/\// # full url

      File.join(base_url, href)
    end

    def is_file?(href)
      img_files = /^(https?:\/\/)?.*(\.(#{FileExtension::IMG_FILES}))((\?|#).*)?$/i
      audio_files = /^(https?:\/\/)?.*(\.(#{FileExtension::AUDIO_FILES}))((\?|#).*)?$/i
      video_files = /^(https?:\/\/)?.*(\.(#{FileExtension::VIDEO_FILES}))((\?|#).*)?$/i
      doc_files = /^(https?:\/\/)?.*(\.(#{FileExtension::DOC_FILES}))((\?|#).*)?$/i
      href =~ img_files || href =~ audio_files || href =~ video_files || href =~ doc_files
    end

    def base_href(dom)
      base_tag = dom.xpath('//base').first
      return nil unless base_tag

      href = base_tag.get_attribute('href')
      return href if href =~ /^\//            # absolute path
      return href if href =~ /^http(s?):\/\// # full url

      abs_path = Addressable::URI.join('/', @headers.dirname, href).to_s
      strip_relative_path_jumps(abs_path)
    end

    def strip_relative_path_jumps(path)
      components = path.split('/') - ['.', '']
      while components.index('..')
        if components.index('..').zero?
          components.shift
        else
          components.slice!(components.index('..') - 1, 2)
        end
      end

      Addressable::URI.join('/', components.join('/')).to_s
    end
  end

  class MultiTagMatcher
    def match(node_set)
      node_set.find_all { |node| a_tag?(node) || link_tag_with_canonical?(node) }
    end

    def a_tag?(node)
      node.name == 'a'
    end

    def link_tag_with_canonical?(node)
      node.name == 'link' && node.get_attribute('rel') == 'canonical'
    end
  end
end
