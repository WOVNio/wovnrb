require 'test_helper'

module Wovnrb
  module UnifiedValues
    class NodeSwappingTargetsCreatorTest < WovnMiniTest
      def test_run
        html = 'a<a>b</a>c'
        result = TextScraper.new(Set.new).run(Nokogiri::HTML5(html))

        nodes_info = [
            {
                nodes: result.first[:nodes]
            }
        ]

        NodeSwappingTargetsCreator.new(nodes_info).run!
        assert_equal(%w[a b c], nodes_info[0][:swapping_targets].map(&:to_s))
      end

      def test_run_with_data_stated_by_tag
        html = '<a>b</a>c'
        result = TextScraper.new(Set.new).run(Nokogiri::HTML5(html))
        nodes = result.first[:nodes]
        nodes_info = [
            {
                nodes: nodes
            }
        ]

        NodeSwappingTargetsCreator.new(nodes_info).run!
        dummy = NodeSwappingTargetsCreator.new('').create_dummy_empty_text_node(next_node: nodes[0])

        assert_equal(['', 'b', 'c'], nodes_info[0][:swapping_targets].map(&:to_s))

        text_for_dummy = 'a'
        dummy.content = text_for_dummy
        assert_equal(text_for_dummy, nodes[0].previous.to_s)
      end

      def test_run_with_data_ended_by_tag
        html = 'a<a>b</a>'
        result = TextScraper.new(Set.new).run(Nokogiri::HTML5(html))
        nodes = result.first[:nodes]
        nodes_info = [
            {
                nodes: nodes
            }
        ]

        NodeSwappingTargetsCreator.new(nodes_info).run!
        dummy = NodeSwappingTargetsCreator.new('').create_dummy_empty_text_node(previous_node: nodes[-1])

        assert_equal(['a', 'b', ''], nodes_info[0][:swapping_targets].map(&:to_s))

        text_for_dummy = 'a'
        dummy.content = text_for_dummy
        assert_equal(text_for_dummy, nodes[-1].next.to_s)
      end

      def test_run_with_data_with_no_content_inside_tag
        html = 'a<a></a>c'
        result = TextScraper.new(Set.new).run(Nokogiri::HTML5(html))
        nodes = result.first[:nodes]
        nodes_info = [
            {
                nodes: nodes
            }
        ]

        NodeSwappingTargetsCreator.new(nodes_info).run!
        dummy = NodeSwappingTargetsCreator.new('').create_dummy_empty_text_node(next_node: nodes[2])

        assert_equal(['a', '', 'c'], nodes_info[0][:swapping_targets].map(&:to_s))

        text_for_dummy = 'a'
        dummy.content = text_for_dummy
        assert_equal(text_for_dummy, nodes[2].previous.to_s)
      end

      def test_run_with_data_without_tag
        html = 'a'
        result = TextScraper.new(Set.new).run(Nokogiri::HTML5(html))
        nodes = result.first[:nodes]
        nodes_info = [
            {
                nodes: nodes
            }
        ]

        NodeSwappingTargetsCreator.new(nodes_info).run!
        assert_equal(['a'], nodes_info[0][:swapping_targets].map(&:to_s))
      end

      def test_run_with_data_with_wovn_ignore
        html = 'a<a wovn-ignore>b</a>c'
        result = TextScraper.new(Set.new).run(Nokogiri::HTML5(html))

        nodes_info = [
            {
                nodes: result.first[:nodes]
            }
        ]

        NodeSwappingTargetsCreator.new(nodes_info).run!
        assert_equal(%w[a c], nodes_info[0][:swapping_targets].map(&:to_s))
      end

      def test_run_with_data_with_closing_tag
        html = 'a<br>bc'
        result = TextScraper.new(Set.new).run(Nokogiri::HTML5(html))

        nodes_info = [
            {
                nodes: result.first[:nodes]
            }
        ]

        NodeSwappingTargetsCreator.new(nodes_info).run!
        assert_equal(%w[a bc], nodes_info[0][:swapping_targets].map(&:to_s))
      end

      def test_run_with_data_with_both_closing_tag_and_no_closing_tag
        html = 'a<a>b<br>c</a>d'
        result = TextScraper.new(Set.new).run(Nokogiri::HTML5(html))

        nodes_info = [
            {
                nodes: result.first[:nodes]
            }
        ]

        NodeSwappingTargetsCreator.new(nodes_info).run!
        assert_equal(%w[a b c d], nodes_info[0][:swapping_targets].map(&:to_s))
      end
    end
  end
end
