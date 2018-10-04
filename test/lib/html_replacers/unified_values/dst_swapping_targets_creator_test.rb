require 'test_helper'

module Wovnrb
  module UnifiedValues
    class DstSwappingTargetsCreatorTest < WovnMiniTest
      def test_run
        text_index = {
          '' => {
            'en' => [
              { 'data' => 'a<a>b</a>c' }
            ]
          }
        }

        DstSwappingTargetsCreator.new(text_index).run!
        assert_equal(%w[a b c], text_index['']['en'][0]['swapping_targets'])
      end

      def test_run_with_data_with_spaces
        text_index = {
          '' => {
            'en' => [
              { 'data' => ' a <a> b </a> c ' }
            ]
          }
        }

        DstSwappingTargetsCreator.new(text_index).run!
        assert_equal([' a ', ' b ', ' c '], text_index['']['en'][0]['swapping_targets'])
      end

      def test_run_with_data_stated_by_tag
        text_index = {
          '' => {
            'en' => [
              { 'data' => '<a>b</a>c' }
            ]
          }
        }

        DstSwappingTargetsCreator.new(text_index).run!
        assert_equal(['', 'b', 'c'], text_index['']['en'][0]['swapping_targets'])
      end

      def test_run_with_data_ended_by_tag
        text_index = {
          '' => {
            'en' => [
              { 'data' => 'a<a>b</a>' }
            ]
          }
        }

        DstSwappingTargetsCreator.new(text_index).run!
        assert_equal(['a', 'b', ''], text_index['']['en'][0]['swapping_targets'])
      end

      def test_run_with_data_with_no_content_inside_tag
        text_index = {
          '' => {
            'en' => [
              { 'data' => 'a<a></a>c' }
            ]
          }
        }

        DstSwappingTargetsCreator.new(text_index).run!
        assert_equal(['a', '', 'c'], text_index['']['en'][0]['swapping_targets'])
      end

      def test_run_with_data_with_tag_only
        text_index = {
          '' => {
            'en' => [
              { 'data' => '<a></a>' }
            ]
          }
        }

        DstSwappingTargetsCreator.new(text_index).run!
        assert_equal(['', '', ''], text_index['']['en'][0]['swapping_targets'])
      end

      def test_run_with_data_without_tag
        text_index = {
          '' => {
            'en' => [
              { 'data' => 'a' }
            ]
          }
        }

        DstSwappingTargetsCreator.new(text_index).run!
        assert_equal(['a'], text_index['']['en'][0]['swapping_targets'])
      end

      def test_run_with_data_with_wovn_ignore
        text_index = {
          '' => {
            'en' => [
              { 'data' => 'a<a wovn-ignore>b</a>c' }
            ]
          }
        }

        DstSwappingTargetsCreator.new(text_index).run!
        assert_equal(%w[a c], text_index['']['en'][0]['swapping_targets'])
      end

      def test_run_with_data_with_closing_tag
        text_index = {
          '' => {
            'en' => [
              { 'data' => 'a<br>bc' }
            ]
          }
        }

        DstSwappingTargetsCreator.new(text_index).run!
        assert_equal(%w[a bc], text_index['']['en'][0]['swapping_targets'])
      end

      def test_run_with_data_with_both_closing_tag_and_no_closing_tag
        text_index = {
          '' => {
            'en' => [
              { 'data' => 'a<a>b<br>c</a>d' }
            ]
          }
        }

        DstSwappingTargetsCreator.new(text_index).run!
        assert_equal(%w[a b c d], text_index['']['en'][0]['swapping_targets'])
      end
    end
  end
end
