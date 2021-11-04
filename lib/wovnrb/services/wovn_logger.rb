require 'singleton'
require 'logger' unless defined?(Logger)

module Wovnrb
  class WovnLogger
    attr_reader :uuid

    include Singleton

    class << self
      def error(message)
        instance.error(message)
      end

      def uuid
        instance.uuid
      end
    end

    def initialize
      @uuid = SecureRandom.uuid
      path = Store.instance.settings['log_path']
      if path
        begin
          @logger = Logger.new(path)
        rescue
          begin
            @logger = Logger.new('wovn_error.log')
            @logger.error("Wovn Error: log_path(#{path}) is invalid, please change log_path at config")
          rescue
            @logger = $stderr
            $stderr.puts("Wovn Error: log_path(#{path}) is invalid, please change log_path at config")
          end
        end
      else
        @logger = $stderr
      end
    end

    def set_logger(logger)
      [:error].each do |method|
        raise 'not suite for logger' unless logger.respond_to? method
      end

      @logger = logger
    end

    def error(message)
      if @logger == $stderr
        @logger.puts "[#{@uuid}] Wovnrb Error: #{message}"
      else
        @logger.error "[#{@uuid}] #{message}"
      end
    end
  end
end
