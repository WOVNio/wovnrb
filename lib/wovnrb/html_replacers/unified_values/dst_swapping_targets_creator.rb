module Wovnrb
  module UnifiedValues
    class DstSwappingTargetsCreator
      # NOTE: `text_index` is the format like below
      #
      # {
      #  "<span>apple is a good</span>foods"=>
      #    {"ja" =>
      #      [{"xpath"=>"/html/body/div", "data"=>"りんごは<span>おいしい</span>たべものです"}]
      #    },
      #  "click<a>here</a>"=>
      #    {"ja" =>
      #      [{"xpath"=>"/html/body/div", "data"=>"<a>こちら</a>をクリックしてください"}]
      #    }
      # }

      def initialize(text_index)
        @text_index = text_index
      end

      # NOTE: `run` make a swapping target like below
      #
      # {
      #  "<span>apple is a good</span>foods"=>
      #    {"ja" =>
      #      [{"xpath"=>"/html/body/div", "data"=>"りんごは<span>おいしい</span>たべものです", 'swapping_targets'=>["りんごは", "おいしい", "たべものです"]}]
      #    },
      #  "click<a>here</a>"=>
      #    {"ja" =>
      #      [{"xpath"=>"/html/body/div", "data"=>" <a>こちら</a>をクリックしてください"}, 'swapping_targets'=>["", "こちら", "をクリックしてください"]]
      #    }
      # }

      def run!
        @text_index.each do |_, v|
          mold = []
          v.values.each do |values|
            values.each do |value|
              value['data'].split(/(<.+?>)/).each_with_index do |data, _index|
                mold_size = mold.size
                mold.push('') if mold_size.even? && data.start_with?('<')
                mold.push(data)
              end

              mold.push('') if mold.last.match?(/\A<.+?>\z/)

              value['swapping_targets'] = remove_tag_element(mold)
            end
          end
        end
      end

      private

      def remove_tag_element(mold)
        end_tag_of_wovn_ignore = nil
        swapping_targets = []

        mold.each do |value|
          if end_tag_of_wovn_ignore.nil? && value =~ /\A<.*wovn-ignore>\z/
            end_tag_of_wovn_ignore = "</#{value.gsub(' wovn-ignore', '')[1..-1]}"
            next
          end

          end_tag_of_wovn_ignore = nil if value == end_tag_of_wovn_ignore

          if end_tag_of_wovn_ignore.nil? && !value.match?(/\A<.+?>\z/)
            swapping_targets << value
          end
        end

        swapping_targets
      end
    end
  end
end
