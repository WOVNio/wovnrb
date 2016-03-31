require 'wovnrb/lang'
require 'wovnrb/store'
require 'minitest/autorun'


module Wovnrb
  class WovnMiniTest < Minitest::Test
    def before_setup
      super
      Wovnrb::Store.instance.reset
    end
  end

  class LogMock
    attr_accessor :errors

    def self.mock_log
      Store.instance.settings['log_path'] = nil
      mock = self.new
      WovnLogger.instance.set_logger(mock)
      mock
    end

    def initialize
      @errors= []
    end

    def error(message)
      @errors << message
    end
  end
end
