# -*- encoding: UTF-8 -*-
require 'test_helper'
require 'webmock/minitest'
require 'wovnrb/html_replacers/html_text_replacer'
require 'wovnrb/html_replacers/html_text_scraper'
require 'wovnrb/services/text_util'

module Wovnrb
  class HTMLTextReplacerTest < WovnMiniTest
    def setup
      @scraper = HTMLTextScraper.new(
        HTMLTextReplacer::NON_RECURSIVE_TEXT_CONTAINERS,
        HTMLTextReplacer::INLINE_TEXT_CONTAINERS,
        HTMLTextReplacer::ALLOWED_WITHIN_TEXT_CONTAINERS,
      )
    end

    def create_node(node_text)
      doc = Nokogiri::HTML('')
      node = Nokogiri::XML::Node::new('p', doc)
      node.inner_html = node_text

      node.children[0]
    end

    def test_get_complex_data
      node = create_node('hello')
      data = @scraper.get_complex_data(node)
      assert_equal('hello', data)
    end

    def test_get_complex_data_with_span
      node = create_node('<div>hello<span>complex</span>world</div>')
      data = @scraper.get_complex_data(node)
      assert_equal(3, node.children.size)
      assert_equal('hello<span>complex</span>world', data)
    end

    def test_is_text_value
      node = create_node('hello')
      result = @scraper.is_text_value?(node)
      assert_equal(true, result)
    end

    def test_is_text_value_with_multiple_text_container
      node = create_node('<div><a>hello</a><span>world</span></div>')
      result = @scraper.is_text_value?(node)
      assert_equal(true, result)
    end

    def test_is_text_value_with_text_container
      node = create_node('<div><a>hello</a></div>')
      result = @scraper.is_text_value?(node)
      assert_equal(false, result)
    end

    def test_is_text_value_with_plain_text_container
      node = create_node('<div>hello</div>')
      result = @scraper.is_text_value?(node)
      assert_equal(false, result)
    end

    def test_is_valid_text_node
      node = create_node('hello')
      result = @scraper.is_valid_text_node?(node)
      assert_equal(true, result)
    end

    def test_is_valid_text_node_with_empty
      node = create_node(' ')
      result = @scraper.is_valid_text_node?(node)
      assert_equal(false, result)
    end

    def test_is_valid_text_node_with_empty_html_entity
      node = create_node('&nbsp;')
      result = @scraper.is_valid_text_node?(node)
      assert_equal(false, result)
    end

    def test_is_valid_text_node_with_div
      node = create_node('<div>hello</div>')
      result = @scraper.is_valid_text_node?(node)
      assert_equal(false, result)
    end

    def test_is_parent_of_single_text_container
      node = create_node('<div>hello</div>')
      result = @scraper.is_parent_of_single_text_container?(node)
      assert_equal(true, result)
    end

    def test_is_parent_of_single_text_container_having_inline
      node = create_node('<div><a>hello</a></div>')
      result = @scraper.is_parent_of_single_text_container?(node)
      assert_equal(true, result)
    end

    def test_is_parent_of_single_text_container_having_div
      node = create_node('<div><div>hello</div></div>')
      result = @scraper.is_parent_of_single_text_container?(node)
      assert_equal(true, result)
    end

    def test_is_parent_of_single_text_container_having_multiple_element
      node = create_node('<div><div>hello</div>world</div>')
      result = @scraper.is_parent_of_single_text_container?(node)
      assert_equal(false, result)
    end

    def test_is_valid_text_container
      node = create_node('hello')
      result = @scraper.is_accepted_within_text_container?(node)
      assert_equal(true, result)
    end

    def test_is_valid_text_container_with_inline
      node = create_node('<a>hello</a>')
      result = @scraper.is_accepted_within_text_container?(node)
      assert_equal(true, result)
    end

    def test_is_valid_text_container_with_netted_inline
      node = create_node('<span><a>hello</a>world</span>')
      result = @scraper.is_accepted_within_text_container?(node)
      assert_equal(true, result)
    end

    def test_is_valid_text_container_with_div
      node = create_node('<div>hello</div>')
      result = @scraper.is_accepted_within_text_container?(node)
      assert_equal(false, result)
    end

    def test_is_valid_text_container_with_inline_and_div
      node = create_node('<a><div>hello</div></a>')
      result = @scraper.is_accepted_within_text_container?(node)
      assert_equal(false, result)
    end

    def test_is_non_recursive_text_container
      scraper = HTMLTextScraper.new(['div'], ['dummy'], ['dummy'])
      ['div', 'DIV', 'dummy', 'DUMMY'].each do |tag|
        node = create_node("<#{tag}>hello</#{tag}>")
        result = scraper.is_non_recursive_text_container?(node)

        assert_equal(tag.downcase == 'div', result, tag)
      end
    end

    def test_is_inline_text_container?
      scraper = HTMLTextScraper.new(['dummy'], ['span'], ['dummy'])
      ['span', 'SPAN', 'dummy', 'DUMMY'].each do |tag|
        node = create_node("<#{tag}>hello</#{tag}>")
        result = scraper.is_inline_text_container?(node)

        assert_equal(tag.downcase == 'span', result, tag)
      end
    end

    def test_node_to_src
      node = create_node('<div>hello</div>')
      src = @scraper.node_to_src(node, false, false)

      assert_equal('hello', src)
    end

    def test_node_to_src_with_inline
      node = create_node('<a>hello</a>')
      src = @scraper.node_to_src(node, false, false)

      assert_equal('hello', src)
    end

    def test_node_to_src_with_nest
      node = create_node('<div>hello<a>world</a>welcome</div>')
      src = @scraper.node_to_src(node, false, false)

      assert_equal('hello<a>world</a>welcome', src)
    end

    def test_node_to_src_with_single_nest
      node = create_node('<div><a>hello</a></div>')
      src = @scraper.node_to_src(node, false, false)

      assert_equal('<a>hello</a>', src)
    end

    def test_get_node_text
      node = create_node('hello&lt;&gt;world')
      assert_equal('hello<>world', node.text)
      src = @scraper.get_node_text(node, true)

      assert_equal('hello&lt;&gt;world', src)
    end
  end
end
