require 'test_helper'

module Wovnrb
  class HtmlReplaceMarkerTest < WovnMiniTest
    def test_add_comment_value
      marker = HtmlReplaceMarker.new
      assert_equal('<!-- __wovn-backend-ignored-key-0 -->', marker.add_comment_value('hello'))
    end

    def test_add_comment_value_multiple_times
      maker = HtmlReplaceMarker.new
      assert_equal('<!-- __wovn-backend-ignored-key-0 -->', maker.add_comment_value('hello'))
      assert_equal('<!-- __wovn-backend-ignored-key-1 -->', maker.add_comment_value('hello'))
      assert_equal('<!-- __wovn-backend-ignored-key-2 -->', maker.add_comment_value('hello'))
      assert_equal('<!-- __wovn-backend-ignored-key-3 -->', maker.add_comment_value('hello'))
    end

    def test_add_same_comment_value_multiple_times
      marker = HtmlReplaceMarker.new

      25.times do |i|
        assert_equal("<!-- __wovn-backend-ignored-key-#{i} -->", marker.add_comment_value('hello'))
      end
    end

    def test_revert
      marker = HtmlReplaceMarker.new
      original_html = '<html><body>hello<a>  replacement </a>world </body></html>'
      key = marker.add_comment_value('hello')
      new_html = original_html.sub('hello', key)
      assert_equal("<html><body>#{key}<a>  replacement </a>world </body></html>", new_html)
      assert_equal(original_html, marker.revert(new_html))
    end

    def test_revert_input_value
      marker = HtmlReplaceMarker.new
      original_html = '<html><body><input type="hidden" value="please-revert"></body></html>'
      key = marker.add_comment_value('please-revert')
      new_html = original_html.sub('please-revert', key)
      assert_equal("<html><body><input type=\"hidden\" value=\"#{key}\"></body></html>", new_html)
      assert_equal(original_html, marker.revert(new_html))
    end

    def test_revert_input_empty_value
      marker = HtmlReplaceMarker.new
      original_html = '<html><body><input type="hidden" value=""></body></html>'
      key = marker.add_comment_value('')
      new_html = original_html.sub('value=""', "value=\"#{key}\"")
      assert_equal("<html><body><input type=\"hidden\" value=\"#{key}\"></body></html>", new_html)
      assert_equal(original_html, marker.revert(new_html))
    end

    def test_revert_multiple_values
      marker = HtmlReplaceMarker.new
      original_html = '<html><body>hello<a>  replacement </a>world </body></html>'
      key1 = marker.add_comment_value('hello')
      key2 = marker.add_comment_value('replacement')
      key3 = marker.add_comment_value('world')
      new_html = original_html.sub('hello', key1)
      new_html = new_html.sub('replacement', key2).sub('world', key3)
      assert_equal("<html><body>#{key1}<a>  #{key2} </a>#{key3} </body></html>", new_html)
      assert_equal(original_html, marker.revert(new_html))
    end

    def test_revert_multiple_similar_values
      marker = HtmlReplaceMarker.new
      original_html = '<html><body>'
      25.times { |i| original_html += "<a>hello_#{i}</a>" }
      original_html += '</body></html>'

      new_html = original_html
      keys = []
      25.times do |i|
        key = marker.add_comment_value("hello_#{i}")
        keys << key
        new_html = new_html.sub("hello_#{i}", key)
      end

      assert_equal(false, new_html.include?('hello'))
      assert_equal(original_html, marker.revert(new_html))
    end

    def test_revert_same_value
      marker = HtmlReplaceMarker.new
      original_html = '<html><body>hello<a>hello</a>hello</body></html>'
      key1 = marker.add_comment_value('hello')
      key2 = marker.add_comment_value('hello')
      key3 = marker.add_comment_value('hello')
      new_html = "<html><body>#{key1}<a>#{key2}</a>#{key3}</body></html>"
      assert_equal(original_html, marker.revert(new_html))
    end
  end
end
