module Wovnrb
  class HtmlConverter
    def initialize(dom, store, headers)
      @dom = dom
      @headers = headers
      @store = store
    end

    def build
      transform_html
      html
    end

    def build_api_compatible_html
      marker = HtmlReplaceMarker.new
      converted_html = replace_dom(marker)

      [converted_html, marker]
    end

    private

    def html
      @dom.to_html(save_with: 0).strip
    end

    def transform_html
      replace_snippet
      replace_hreflangs
      inject_lang_html_tag
    end

    def replace_snippet
      strip_snippet
      insert_snippet
    end

    def replace_dom(marker)
      strip_snippet
      strip_hreflangs if add_hreflang

      @dom.traverse { |node| transform_node(node, marker) }

      insert_snippet(true)
      insert_hreflang_tags

      html
    end

    def transform_node(node, marker)
      strip_wovn_ignore(node, marker)
      strip_custom_ignore(node, marker)
      strip_form(node, marker)
      strip_script(node, marker)
    end

    def strip_script(node, marker)
      put_replace_marker(node, marker) if node.name.casecmp('script').zero?
    end

    def strip_form(node, marker)
      if node.name.casecmp('form').zero?
        put_replace_marker(node, marker)
        return
      end

      if node.name.casecmp('input').zero? && node.get_attribute('type') == 'hidden'
        original_text = node.get_attribute('value')
        return if original_text.nil?
        return if original_text.include?(HtmlReplaceMarker::KEY_PREFIX)

        node.set_attribute('value', marker.add_comment_value(original_text))
      end
    end

    def strip_custom_ignore(node, marker)
      classes = node.get_attribute('class')
      return unless classes.present?

      ignored_classes = @store.settings['ignore_class']
      should_be_ignored = (ignored_classes & classes.split(' ')).present?

      put_replace_marker(node, marker) if should_be_ignored
    end

    def strip_wovn_ignore(node, marker)
      put_replace_marker(node, marker) if node && node.get_attribute('wovn-ignore')
    end

    def put_replace_marker(node, marker)
      original_text = node.inner_html
      return if original_text.include?(HtmlReplaceMarker::KEY_PREFIX)

      node.inner_html = marker.add_comment_value(original_text)
    end

    def strip_hreflangs
      supported_langs = @store.supported_langs
      @dom.xpath('//link') do |node|
        node.remove if node['hreflang'] && supported_langs.include?(Lang.iso_639_1_normalization(node['hreflang']))
      end
    end

    def add_hreflang
      !!(@store && @headers)
    end

    def inject_lang_html_tag
      root = @dom.at_css('html')
      return unless root

      current_lang = @headers.lang_code
      default_lang = @store.default_lang

      if current_lang != default_lang
        root['lang'] = current_lang
      else
        root.delete('lang')
      end
    end

    def replace_hreflangs
      strip_hreflang_tags
      insert_hreflang_tags
    end

    def strip_hreflang_tags
      @dom.xpath('//link').each do |node|
        node.remove if node['hreflang'] && @store.supported_langs.include?(Lang.iso_639_1_normalization(node['hreflang']))
      end
    end

    def insert_hreflang_tags
      parent_node = @dom.at_css('head') || @dom.at_css('body') || @dom.at_css('html')
      return unless parent_node

      @store.supported_langs.each do |lang_code|
        insert_node = Nokogiri::XML::Node.new('link', @dom)
        insert_node['rel'] = 'alternate'
        insert_node['hreflang'] = Lang.iso_639_1_normalization(lang_code)
        insert_node['href'] = @headers.redirect_location(lang_code)

        parent_node.add_child(insert_node.to_s)
      end
    end

    # Remove wovn snippet code from dom
    def strip_snippet
      @dom.xpath('//script').each do |script_node|
        script_node.remove if script_node['src'] && script_node['src'] =~ /^\/\/j.(dev-)?wovn.io(:3000)?\//
      end
    end

    def insert_snippet(adds_backend_error_mark = true)
      parent_node = @dom.at_css('head') || @dom.at_css('body') || @dom.at_css('html')
      return unless parent_node

      insert_node = Nokogiri::XML::Node.new('script', @dom)
      insert_node['src'] = "//j.#{@store.wovn_host}/1"
      insert_node['async'] = true
      insert_node['data-wovnio'] = data_wovnio
      insert_node['data-wovnio-type'] = 'fallback_snippet' if adds_backend_error_mark
      # do this so that there will be a closing tag (better compatibility with browsers)
      insert_node.content = ''

      if !parent_node.children.empty?
        parent_node.children.first.add_previous_sibling(insert_node)
      else
        parent_node.add_child(insert_node)
      end
    end

    def data_wovnio
      token = @store.settings['project_token']
      current_lang = @headers.lang_code
      default_lang = @store.settings['default_lang']
      url_pattern = @store.settings['url_pattern']
      lang_code_aliases_json = JSON.generate(@store.settings['custom_lang_aliases'])

      [
        "key=#{token}",
        'backend=true',
        "currentLang=#{current_lang}",
        "defaultLang=#{default_lang}",
        "urlPattern=#{url_pattern}",
        "langCodeAliases=#{lang_code_aliases_json}",
        "version=WOVN.rb_#{VERSION}"
      ].join('&')
    end
  end
end
