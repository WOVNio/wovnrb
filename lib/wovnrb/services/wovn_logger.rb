require 'singleton'
require 'logger' unless defined?(Logger)

class Wovnrb
  class WovnLogger
    include Singleton

    def initialize
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
        unless logger.respond_to? method
          raise 'not suite for logger'
        end
      end

      @logger = logger
    end

    def error(message)
      if @logger == $stderr
        @logger.puts "Wovnrb Error: #{message}"
      else
        @logger.error message
      end
    end
  end
end
