require 'test_helper'

module Wovnrb
  module UnifiedValues
    class ElementCategoryTest < WovnMiniTest
      def test_contents
        assert_equal(116, ElementCategory::CONTENT_TYPES.size)
      end

      def test_inline_elements
        expected_inlines = %w[a abbr b bdi bdo button cite code data dfn em i kbd label legend mark meter option q rb rp rt rtc s samp small span strong sub sup time u var]
        assert_same_elements(expected_inlines, ElementCategory::INLINE_ELEMENTS.to_a)
      end

      def test_empty_elements
        expected_inlines = %w[br param source track wbr input]
        assert_same_elements(expected_inlines, ElementCategory::EMPTY_ELEMENTS.to_a)
      end

      def test_ignore_elements
        expected_inlines = %w[area audio canvas embed iframe img map meta object picture video]
        assert_same_elements(expected_inlines, ElementCategory::IGNORE_ELEMENTS.to_a)
      end

      def test_skip_elements
        expected_inlines = %w[base link noscript script style template]
        assert_same_elements(expected_inlines, ElementCategory::SKIP_ELEMENTS.to_a)
      end

      def test_skip_elements_without_attributes
        expected_inlines = %w[textarea]
        assert_same_elements(expected_inlines, ElementCategory::SKIP_ELEMENTS_WITHOUT_ATTRIBUTES.to_a)
      end

      def test_block_elements
        expected_inlines = %w[address article aside bb blockquote body caption col colgroup datalist dd del details dialog div dl dt fieldset figcaption figure footer form h1 h2 h3 h4 h5 h6 head header hgroup hr html ins li main menu nav ol optgroup output p pre progress ruby section select slot summary svg table tbody td tfoot th thead title tr ul]
        assert_same_elements(expected_inlines, ElementCategory::BLOCK_ELEMENTS.to_a)
      end

      def test_no_duplication
        elements = ElementCategory::INLINE_ELEMENTS + ElementCategory::EMPTY_ELEMENTS + ElementCategory::IGNORE_ELEMENTS + ElementCategory::SKIP_ELEMENTS + ElementCategory::SKIP_ELEMENTS_WITHOUT_ATTRIBUTES + ElementCategory::BLOCK_ELEMENTS
        element_size_sum = ElementCategory::INLINE_ELEMENTS.size + ElementCategory::EMPTY_ELEMENTS.size + ElementCategory::IGNORE_ELEMENTS.size + ElementCategory::SKIP_ELEMENTS.size + ElementCategory::SKIP_ELEMENTS_WITHOUT_ATTRIBUTES.size + ElementCategory::BLOCK_ELEMENTS.size

        assert_equal(elements.size, ElementCategory::CONTENT_TYPES.size)
        assert_equal(element_size_sum, ElementCategory::CONTENT_TYPES.size)
      end
    end
  end
end
