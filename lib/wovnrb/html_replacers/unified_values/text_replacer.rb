module Wovnrb
  module UnifiedValues
    class TextReplacer < ReplacerBase
      def initialize(store, text_index)
        super(store)
        @text_index = text_index
      end

      def replace(dom, lang)
        translated_nodes_with_targets = NodeSwappingTargetsCreator.new(TextScraper.new(@ignored_class_set).run(dom)).run!
        text_index_with_targets = DstSwappingTargetsCreator.new(@text_index).run!

        translated_nodes_with_targets.each do |translated_nodes_with_target|
          dst_swapping_targets = text_index_with_targets[translated_nodes_with_target[:dst]]&.fetch(lang.lang_code, nil)&.first&.fetch('swapping_targets', nil)
          next unless dst_swapping_targets

          translated_nodes_with_target[:swapping_targets].each_with_index do |node_swapping_target, index|
            # NOTE: current logic to swap back search text node and find wovn-src base on the text node.
            #       if `translated_text` is empry string, translated html don't have text node. it means that widget can't find wovn-src and swap back
            #       so we use `\u200b`(ZERO WIDTH SPACE) instead of empty string
            translated_text = dst_swapping_targets[index].blank? ? "\u200b" : dst_swapping_targets[index]
            original_text = node_swapping_target.content

            node_swapping_target.content = translated_text
            add_comment_node(node_swapping_target, original_text)
          end
        end
      end
    end
  end
end
