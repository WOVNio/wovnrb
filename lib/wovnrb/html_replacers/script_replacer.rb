module Wovnrb
  class ScriptReplacer < ReplacerBase
    def initialize(store)
      @store = store
    end

    def replace(dom, lang)
      remove_embed_wovn_script(dom)
      add_wovn_script(dom, lang)
    end

    private
    def remove_embed_wovn_script(dom)
      dom.xpath('//script').each do |script_node|
        if script_node['src'] && script_node['src'] =~ /^\/\/j.(dev-)?wovn.io(:3000)?\//
          script_node.remove
        end
      end
    end

    def add_wovn_script(dom, lang)
      parent_node = dom.at_css('head') || dom.at_css('body') || dom.at_css('html')

      # INSERT BACKEND WIDGET
      insert_node = Nokogiri::XML::Node.new('script', dom)
      insert_node['src'] = "//j.#{@store.wovn_host}/1"
      insert_node['async'] = true
      version = defined?(VERSION) ? VERSION : ''
      insert_node['data-wovnio'] = "key=#{@store.settings['user_token']}&backend=true&currentLang=#{lang.lang_code}&defaultLang=#{@store.settings['default_lang']}&urlPattern=#{@store.settings['url_pattern']}&langCodeAliases=#{JSON.dump(@store.settings['custom_lang_aliases'])}&version=#{version}"
      # do this so that there will be a closing tag (better compatibility with browsers)
      insert_node.content = ' '
      if parent_node.children.size > 0
        parent_node.children.first.add_previous_sibling(insert_node)
      else
        parent_node.add_child(insert_node)
      end
    end
  end
end
