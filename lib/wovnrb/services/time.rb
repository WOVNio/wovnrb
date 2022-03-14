module Wovnrb
  # Provides utilities related to Time
  class TimeUtil
    class << self
      def round_down_time(time, unit)
        time - (time % unit)
      end

      def time_proc
        -> { return Time.now.utc.sec }
      end
    end
  end
end
