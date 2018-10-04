module Wovnrb
  module UnifiedValues
    class NodeSwappingTargetsCreator
      # NOTE: `nodes_info` is the format like below
      #
      # [
      #  {:dst=>"an<span>apple is a good</span>foods",
      #    :nodes=>
      #      [
      #        (Text "an"),
      #        (Element:0x13e84e1334 { name = "span", children = [ #(Text "apple is a good")] }),
      #        (Text "apple is a good"),
      #        (Element:0x13e84e1334 { name = "span", childrelib/wovnrb/html_replacers/unified_values/node_swapping_targets_creator.rbn = [ #(Text "apple is a good")] }),
      #        (Text "\n          foods\n        \n      \n")]}
      #      ]
      #   }
      # ]
      def initialize(nodes_info)
        @nodes_info = nodes_info
      end

      # NOTE: `run` make a swapping_targets like below
      #
      # [
      #  {:dst=>"an<span>apple is a good</span>foods",
      #    :nodes=>
      #      [
      #        (Text "an"),
      #        (Element:0x13e84e1334 { name = "span", children = [ #(Text "apple is a good")] }),
      #        (Text "apple is a good"),
      #        (Element:0x13e84e1334 { name = "span", children = [ #(Text "apple is a good")] }),
      #        (Text "\n          foods\n        \n      \n")]}
      #      ]
      #    :swapping_targets=>
      #      [
      #        (Text "an"),
      #        (Text "apple is a good"),
      #        (Text "\n          foods\n        \n      \n")]}
      #      ]
      #   }
      # ]

      def run!
        @nodes_info.each do |node_info|
          mold = []
          node_info[:nodes].each do |node|
            mold_size = mold.size
            mold.push create_dummy_empty_text_node(next_node: node) if mold_size.even? && node.element?
            mold.push node
          end

          mold.push create_dummy_empty_text_node(previous_node: mold.last) if mold.last.element?
          node_info[:swapping_targets] = remove_tag_element(mold)
        end
      end

      def remove_tag_element(mold)
        id_of_tag_with_wovn_ignore = nil
        swapping_targets = []
        mold.each do |node|
          if id_of_tag_with_wovn_ignore.nil? && node.attributes.keys.include?('wovn-ignore')
            id_of_tag_with_wovn_ignore = node.object_id
            next
          end

          if node.object_id == id_of_tag_with_wovn_ignore
            id_of_tag_with_wovn_ignore = nil
          end

          if id_of_tag_with_wovn_ignore.nil? && node.text?
            swapping_targets << node
          end
        end

        swapping_targets
      end

      def create_dummy_empty_text_node(option)
        DummyEmpryTextNode.new(option)
      end

      class DummyEmpryTextNode
        attr_reader :name

        def initialize(next_node: nil, previous_node: nil)
          @name = 'text'
          @next_node = next_node
          @previous_node = previous_node
          @added_empty_text = nil
        end

        def text?
          true
        end

        def content
          ''
        end

        def to_s
          content
        end

        def attributes
          {}
        end

        def parent
          @next_node.try(:parent) || @previous_node.try(:parent)
        end

        def document
          @next_node.try(:document) || @previous_node.try(:document)
        end

        def add_previous_sibling(comment_node)
          @added_empty_text&.add_previous_sibling(comment_node)
        end

        def content=(text)
          return if text == ''

          if @next_node
            @next_node.add_previous_sibling(text)
            @added_empty_text = @next_node.previous
          elsif @previous_node
            @previous_node.add_next_sibling(text)
            @added_empty_text = @previous_node.next
          end
        end
      end
    end
  end
end
