module Wovnrb
  class << self
    def configuration
      return @configuration ||= Configuration.new
    end
  end

  def self.configure
    yield(self.configuration)
  end

  class Configuration
    attr_accessor :install_middleware

    def initialize
      @install_middleware = true
    end
  end
end
