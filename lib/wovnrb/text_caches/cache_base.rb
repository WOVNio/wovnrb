require 'active_support/inflector'

class Wovnrb
  class CacheBase
    @@strategy_map = {
        memory: :memory_cache
    }

    @@default_base_config = {
      strategy: :memory
    }

    @@singleton_cache = nil
    def self.get_single
      raise 'cache is not initialized' unless @@singleton_cache
      @@singleton_cache
    end

    def self.set_single(config)
      @@singleton_cache = self.build(config)
    end

    def self.reset_cache
      @@singleton_cache = nil
    end

    def self.build(config)
      @config = @@default_base_config.merge config

      strategy = @@strategy_map[@config[:strategy]]
      raise "Invalid strategy: #{strategy}" unless strategy

      strategy_sym = strategy.to_sym
      begin
        require "wovnrb/text_caches/#{strategy_sym}"
      rescue LoadError => e
        raise "Could not find #{strategy_sym} (#{e})"
      end

      strategy_class = Wovnrb.const_get(ActiveSupport::Inflector.camelize(strategy_sym))
      strategy_class.new(config)
    end

    def put(key, value)
      raise NotImplementedError.new('put is not defined')
    end

    def get(key)
      raise NotImplementedError.new('put is not defined')
    end
  end
end
