require 'test_helper'
require 'singleton'

module Wovnrb
  class StoreTest < WovnMiniTest
    def setup
      Singleton.__init__(WovnLogger)
    end

    def test_initialize
      log_file_name = 'test_tmp.log'
      Store.instance.update_settings('log_path' => log_file_name)
      WovnLogger.instance
      assert(File.exist?(log_file_name))
      File.delete(log_file_name)
    end

    def test_initialize_without_path
      Store.instance.update_settings('log_path' => nil)
      WovnLogger.instance
      assert_equal($stderr, WovnLogger.instance.instance_variable_get(:@logger))
    end

    def test_initialize_with_invalid_path
      log_file_name = 'in/val/id/test_tmp.log'
      Store.instance.update_settings('log_path' => log_file_name)
      WovnLogger.instance
      assert_equal(false, File.exist?(log_file_name))
      assert_equal(true, File.exist?('wovn_error.log'))
      File.delete('wovn_error.log')
    end

    def test_error
      mock = LogMock.mock_log
      WovnLogger.instance.error('aaa')
      assert_equal(['aaa'], mock.errors)
    end
  end
end
