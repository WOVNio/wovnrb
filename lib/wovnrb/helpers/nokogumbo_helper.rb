module Wovnrb
  module Helpers
    module NokogumboHelper
      def parse_html(html_string, encoding = 'UTF-8')
        dom = if html_string.strip[0..999] =~ /<html/i
                d = Nokogiri::HTML5(html_string)
                d.encoding = encoding
                d
              else
                parse_fragment(html_string, encoding)
              end

        dom
      end

      # https://www.rubydoc.info/gems/nokogumbo/Nokogiri/HTML5#fragment-class_method
      #
      # Nokogumbo does not properly support parsing fragment and the current
      # implementation of Nokogiri::HTML5.fragment does not handle encoding
      # (second line of code below).
      def parse_fragment(html_string, encoding = 'UTF-8')
        doc = Nokogiri::HTML5.parse(html_string)
        doc.encoding = encoding
        fragment = Nokogiri::HTML::DocumentFragment.new(doc)

        if doc.children.length != 1 or doc.children.first.name != 'html'
          # no HTML?  Return document as is
          fragment = doc
        else
          # examine children of HTML element
          children = doc.children.first.children

          # head is always first.  If present, take children but otherwise
          # ignore the head element
          if children.length > 0 and doc.children.first.name = 'head'
            fragment << children.shift.children
          end

          # body may be next, or last.  If found, take children but otherwise
          # ignore the body element.  Also take any remaining elements, taking
          # care to preserve order.
          if children.length > 0 and doc.children.first.name = 'body'
            fragment << children.shift.children
            fragment << children
          elsif children.length > 0 and doc.children.last.name = 'body'
            body = children.pop
            fragment << children
            fragment << body.children
          else
            fragment << children
          end
        end

        # return result
        fragment
      end

      module_function :parse_html, :parse_fragment
    end
  end
end
