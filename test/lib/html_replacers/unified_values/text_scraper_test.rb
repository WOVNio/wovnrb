require 'test_helper'

module Wovnrb
  module UnifiedValues
    class TextScraperTest < WovnMiniTest
      def assert_shared_fixture(base_name, ignored_classes = Set.new)
        html = File.read("test/fixtures/unified_values/#{base_name}_actual.html")
        expected_values = JSON.parse(File.read("test/fixtures/unified_values/#{base_name}_expected.json"))

        dom = Nokogiri::HTML5.parse(html)
        actual_values = TextScraper.new(ignored_classes).run(dom)

        assert_shared_fixture_values(expected_values, actual_values)
      end

      def assert_shared_fixture_values(expected_values, actual_values)
        expected_values.zip(actual_values).each do |expected_value, actual|
          assert_equal(expected_value['srcs'].join, actual[:dst])
          assert_equal(expected_value['srcs'].size, actual[:nodes].size)
        end
        assert_equal(expected_values.length, actual_values.length)
      end

      def test_shared_fixture
        assert_shared_fixture('site_html/simple')
      end

      def test_shared_fixture_of_wovn
        assert_shared_fixture('site_html/wovn.io')
      end

      def test_shared_fixture_of_yahoo_jp
        assert_shared_fixture('site_html/www.yahoo.co.jp')
      end

      def test_run_fixtures_of_nested_text_value
        assert_shared_fixture('small_html/nested_text_value')
      end

      def test_run_fixtures_of_nested_text_value_mixed_plan_text
        assert_shared_fixture('small_html/nested_text_value_mixed_plan_text')
      end

      def test_run_fixtures_of_block_inside_inline
        assert_shared_fixture('small_html/block_inside_inline')
      end

      def test_run_fixtures_of_br_tag
        assert_shared_fixture('small_html/br_tag')
      end

      def test_run_fixtures_of_empty_text
        assert_shared_fixture('small_html/empty_text')
      end

      def test_run_fixtures_of_comment_tag
        assert_shared_fixture('small_html/comment_tag')
      end

      def test_run_fixtures_of_ignore_tag
        assert_shared_fixture('small_html/ignore_tag')
      end

      def test_run_fixtures_of_empty_tag
        assert_shared_fixture('small_html/empty_tag')
      end

      def test_run_fixtures_of_deep_nested_block
        assert_shared_fixture('small_html/deep_nested_block')
      end

      def test_run_fixtures_of_deep_nested_inline
        assert_shared_fixture('small_html/deep_nested_inline')
      end

      def test_run_fixtures_of_text_different_inline_each_other
        assert_shared_fixture('small_html/text_different_inline_each_other')
      end

      def test_run_fixtures_of_wovn_ignore
        assert_shared_fixture('small_html/wovn_ignore')
      end

      def test_run_fixtures_of_ignored_class
        assert_shared_fixture('small_html/ignored_class', Set.new(['ignore-me']))
      end

      def test_run_fixtures_of_nested_and_complex_wovn_ignore
        assert_shared_fixture('small_html/nested_and_complex_wovn_ignore')
      end

      def test_run_fixtures_of_text_in_svg
        assert_shared_fixture('small_html/text_in_svg')
      end

      def test_run_fixtures_of_text_with_html_entity
        assert_shared_fixture('small_html/text_with_html_entity')
      end

      def test_run_fixtures_of_complex_text_with_html_entity
        assert_shared_fixture('small_html/complex_text_with_html_entity')
      end

      def test_run_fixtures_of_unknown_or_custom_tag
        assert_shared_fixture('small_html/unknown_or_custom_tag')
      end

      def test_run_fixtures_of_unnecessay_top_end_tag
        assert_shared_fixture('small_html/unnecessay_top_end_tag')
      end

      def test_run_fixtures_of_option_tag
        assert_shared_fixture('small_html/option_tag')
      end

      def test_run_fixtures_of_img
        assert_shared_fixture('small_html/img')
      end
    end
  end
end
