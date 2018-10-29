module Wovnrb
  class HtmlConverter
    def initialize(html, store, headers)
      @html = html
      @headers = headers
      @store = store
    end

    def build
      transform_html
      @html
    end

    def build_api_compatible_html
      marker = HtmlReplaceMarker.new
      dom = Helpers::NokogumboHelper::parse_html(@html)
      converted_html = replace_dom(dom, marker)
      converted_html = remove_backend_wovn_ignore_comment(converted_html, marker)

      [converted_html, marker]
    end

    private

    def transform_html
      insert_snippet
      insert_hreflangs
      inject_lang_html_tag
    end

    def traverse(node, marker)
      transform_node(node, marker)
      node.children.each do |child|
        traverse(child, marker)
      end
    end

    def replace_dom(dom, marker)
      traverse(dom, marker)
      dom.to_html
    end

    # Remove user specified content from <!--backend-wovn-ignore--> to <!--/backend-wovn-ignore'-->
    def remove_backend_wovn_ignore_comment(html, marker)
      ignore_mark = 'backend-wovn-ignore'
      html.scan(/(<!--\s*#{Regexp.quote(ignore_mark)}\s*-->)(.+?)(<!--\s*\/#{Regexp.quote(ignore_mark)}\s*-->)/s) do |matches|
        comment = matches[2]
        key = marker.add_comment_value(comment)
        matches[1] + key + matches[3]
      end
    end

    def transform_node(node, marker)
      strip_snippet_code(node)
      strip_hreflang(node) if add_hreflang
      strip_wovn_ignore(node, marker)
      strip_custom_ignore(node, marker)
      strip_form(node, marker)
      strip_script(node, marker)
    end

    def strip_script(node, marker)
      if node.name.downcase == 'script'
        put_replace_marker(node, marker)
      end
    end

    def strip_form(node, marker)
      if node.name.downcase == 'form'
        put_replace_marker(node, marker)
        return
      end

      if node.name.downcase == 'input' && node.get_attribute('type') == 'hidden'
        original_text = node.get_attribute('value')
        return if original_text.include?(HtmlReplaceMarker::KEY_PREFIX)

        node.set_attribute('value', marker.add_value(original_text))
      end
    end

    def strip_custom_ignore(node, marker)
      classes = node.get_attribute('class')
      return unless classes.present?

      ignored_classes = @store.settings['ignore_class']
      should_be_ignored = (ignored_classes.split(' ') & classes).present?
      put_replace_marker(node, marker) if should_be_ignored
    end

    def strip_wovn_ignore(node, marker)
      if node && node.get_attribute('wovn-ignore')
        put_replace_marker(node, marker)
      end
    end

    def put_replace_marker(node, marker)
      original_text = node.inner_text
      return if original_text.include?(HtmlReplaceMarker::KEY_PREFIX)

      node.inner_html = marker.add_comment_value(original_text)
    end

    def strip_snippet_code(node)
      return unless node.name && node.name.downcase == 'script'
      if node['src'] && node['src'] =~ %r{^//j.(dev-)?wovn.io(:3000)?/}
        node.remove
      end
    end

    def strip_hreflang(node)
      supported_langs = @store.settings['supported_langs']
      if node['hreflang'] && supported_langs.include?(Lang::iso_639_1_normalization(node['hreflang']))
        node.remove
      end
    end

    def add_hreflang
      !!(@store && @headers)
    end

    def inject_lang_html_tag
      lang = @headers.lang_code
      unless lang == @store.settings['default_lang']
        @html = @html.sub(/<html\s?([^>]*)?>/i) do |_|
          if $1.present?
            "<html lang=\"#{lang}\"" + ' \1' + '>'
          else
            "<html lang=\"#{lang}\">"
          end
        end
      end
    end

    def insert_hreflangs
      langs = @store.settings['supported_langs'] || []

      # Strip all existing hreflang tags
      strip_tags_by_regex(hreflang_regex(langs))

      # Insert hreflang tag for each supported language
      insert_after_tag(parent_tags, hreflang_tags(langs).join)
    end

    def hreflang_tags(langs)
      langs.map do |lang|
        "<link rel=\"alternate\" hreflang=\"#{Lang::iso_639_1_normalization(lang)}\" href=\"#{hreflang(lang)}\">"
      end
    end

    def hreflang_regex(langs)
      /<link [^>]*hreflang=[\"']?#{Regexp.quote(langs.join('|'))}[\"']?(\s[^>]*)?\>/i
    end

    def parent_tags
      [
        /(<head\s?.*?>)/i,
        /(<body\s?.*?>)/i,
        /(<html\s?.*?>)/i
      ]
    end

    def hreflang(lang_code)
      # TODO: Refactor to put redirect_location logic to Url class
      @headers.redirect_location(lang_code)
    end

    def strip_tags_by_regex(rx)
      @html = @html.gsub(rx, '')
    end

    def insert_snippet
      strip_tags_by_regex(snippet_regex)
      insert_after_tag(parent_tags, snippet_code)
    end

    def snippet_regex
      /<script[^>]*src=[^>]*j\.[^ '\">]*wovn\.io[^>]*><\/script>/i
    end

    def snippet_code(adds_backend_error_mark = false)
      snippet_url = 
        if @store.settings['wovn_dev_mode'].present?
          '//j.dev-wovn.io:3000/1'
        else
          '//j.wovn.io/1'
        end
      if adds_backend_error_mark
        "<script src=\"#{snippet_url}\" data-wovnio=\"#{data_wovnio}\" data-wovnio-type=\"fallback_snippet\" async></script>"
      else
        "<script src=\"#{snippet_url}\" data-wovnio=\"#{data_wovnio}\" async></script>"
      end
    end

    def data_wovnio
      token = @store.settings['project_token']
      current_lang = @headers.lang_code
      default_lang = @store.settings['default_lang']
      url_pattern = @store.settings['url_pattern']
      lang_code_aliases_json = JSON.generate(@store.settings['custom_lang_aliases'])

      CGI.escapeHTML(
        [
          "key=#{token}",
          "backend=true",
          "currentLang=#{current_lang}",
          "defaultLang=#{default_lang}",
          "urlPattern=#{url_pattern}",
          "langCodeAliases=#{lang_code_aliases_json}",
          "version=WOVN.rb"
        ].join('&')
      )
    end

    def insert_after_tag(parent_tags, snippet)
      parent_tags.each do |parent|
        parent.match(@html) do |match|
          if match
            @html = @html.sub(match[0], match[0] + snippet)
            return
          end
        end
      end
    end
  end
end
