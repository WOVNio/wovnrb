module Wovnrb
  # Provides utilities related to Time
  class TimeUtil
    class << self
      def round_down_time(time, unit)
        time - (time % unit)
      end
    end
  end
end
