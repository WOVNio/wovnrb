module Wovnrb
  class HtmlConverter
    def initialize(dom, store, headers, url_lang_switcher)
      @dom = dom
      @headers = headers
      @store = store
      @url_lang_switcher = url_lang_switcher
    end

    def build
      transform_html
      html
    end

    def build_api_compatible_html
      marker = HtmlReplaceMarker.new
      converted_html = replace_dom(marker)
      converted_html = remove_backend_wovn_ignore_comments(converted_html, marker)
      [converted_html, marker]
    end

    private

    def remove_backend_wovn_ignore_comments(html, marker)
      backend_ignore_regex = /(<!--\s*backend-wovn-ignore\s*-->)(.+?)(<!--\s*\/backend-wovn-ignore\s*-->)/m
      html.gsub(backend_ignore_regex) do |_match|
        comment_start = Regexp.last_match(1)
        ignored_content = Regexp.last_match(2)
        comment_end = Regexp.last_match(3)
        key = marker.add_comment_value(ignored_content)
        comment_start + key + comment_end
      end
    end

    def html
      # Ensure a Content-Type declaration in the header. This mimics Nokogumbo
      # 1.5.0 default serialization behavior.
      @dom.meta_encoding = 'UTF-8' if @dom.respond_to?(:meta_encoding=)

      @dom.to_html(save_with: 0).strip
    end

    def transform_html
      replace_snippet
      replace_hreflangs if @store.settings['insert_hreflangs']
      inject_lang_html_tag
      translate_canonical_tag if @store.settings['translate_canonical_tag']
    end

    def replace_snippet
      strip_snippet
      insert_snippet
    end

    def replace_dom(marker)
      strip_snippet
      strip_hreflangs if @store.settings['insert_hreflangs']

      @dom.traverse { |node| transform_node(node, marker) }

      insert_snippet(adds_backend_error_mark: true)
      insert_hreflang_tags if @store.settings['insert_hreflangs']
      inject_lang_html_tag
      translate_canonical_tag if @store.settings['translate_canonical_tag']

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

        node.set_attribute('value', marker.add_value(original_text))
      end
    end

    def strip_custom_ignore(node, marker)
      classes = node.get_attribute('class')
      return unless classes.present?

      ignored_classes = @store.settings['ignore_class']
      should_be_ignored = (ignored_classes & classes.split).present?

      put_replace_marker(node, marker) if should_be_ignored
    end

    def strip_wovn_ignore(node, marker)
      put_replace_marker(node, marker) if node && (node.get_attribute('wovn-ignore') || node.get_attribute('data-wovn-ignore'))
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

    def inject_lang_html_tag
      root = @dom.at_css('html')
      return unless root
      return if root['lang']

      root['lang'] = @store.default_lang
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

    def translate_canonical_tag
      canonical_node = @dom.at_css('link[rel="canonical"]')
      return unless canonical_node

      lang_code = @headers.lang_code
      return if lang_code == @store.settings['default_lang'] && @store.settings['custom_lang_aliases'][lang_code].nil?

      canonical_url = canonical_node['href']

      translated_canonical_url = @url_lang_switcher.add_lang_code(canonical_url, lang_code, @headers)
      canonical_node['href'] = translated_canonical_url
    end

    # Remove wovn snippet code from dom
    def strip_snippet
      @dom.xpath('//script').each do |script_node|
        script_node.remove if (script_node['src'] && widget_urls.any? { |url| script_node['src'].include? url }) || script_node['data-wovnio'].present?
      end
    end

    def widget_urls
      ["#{@store.settings['api_url']}/widget", 'j.wovn.io', 'j.dev-wovn.io:3000']
    end

    def insert_snippet(adds_backend_error_mark: true)
      parent_node = @dom.at_css('head') || @dom.at_css('body') || @dom.at_css('html')
      return unless parent_node

      insert_node = Nokogiri::XML::Node.new('script', @dom)
      insert_node['src'] = @store.widget_url
      insert_node['async'] = true
      insert_node['data-wovnio'] = data_wovnio
      insert_node['data-wovnio-type'] = 'fallback_snippet' if adds_backend_error_mark
      # do this so that there will be a closing tag (better compatibility with browsers)
      insert_node.content = ''

      if parent_node.children.empty?
        parent_node.add_child(insert_node)
      else
        parent_node.children.first.add_previous_sibling(insert_node)
      end
    end

    def data_wovnio
      token = @store.settings['project_token']
      current_lang = @headers.lang_code
      default_lang = @store.settings['default_lang']
      url_pattern = @store.settings['url_pattern']
      lang_code_aliases_json = JSON.generate(@store.settings['custom_lang_aliases'])
      lang_param_name = @store.settings['lang_param_name']
      custom_domain_langs = @store.custom_domain_langs.to_html_swapper_hash

      result = [
        "key=#{token}",
        'backend=true',
        "currentLang=#{current_lang}",
        "defaultLang=#{default_lang}",
        "urlPattern=#{url_pattern}",
        "langCodeAliases=#{lang_code_aliases_json}",
        "langParamName=#{lang_param_name}",
        "version=WOVN.rb_#{VERSION}"
      ]
      result << "customDomainLangs=#{JSON.generate(custom_domain_langs)}" unless custom_domain_langs.empty?
      result.join('&')
    end
  end
end
