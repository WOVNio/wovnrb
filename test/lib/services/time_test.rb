require 'test_helper'
require 'wovnrb/services/time'

module Wovnrb
  class TimeTest < WovnMiniTest
    def test_round_down_time
      assert_equal(0, TimeUtil.round_down_time(0, 10))
      assert_equal(10, TimeUtil.round_down_time(10, 10))
      assert_equal(10, TimeUtil.round_down_time(16, 10))
      assert_equal(30, TimeUtil.round_down_time(30, 15))
      assert_equal(100, TimeUtil.round_down_time(100, 10))
    end
  end
end
