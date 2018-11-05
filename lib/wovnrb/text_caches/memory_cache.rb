require 'active_support/cache'
require 'lz4-ruby'

module Wovnrb
  class MemoryCache < CacheBase
    @@default_memory_cache_config = {
      cache_megabytes: 200,
      ttl_seconds: 300
    }

    def initialize(config)
      @config = merge_setting(@@default_memory_cache_config, config)
      cache_size = @config[:cache_megabytes].to_f
      ttl = @config[:ttl_seconds].to_i
      @cache_store = ActiveSupport::Cache::MemoryStore.new(expires_in: ttl.seconds, size: cache_size.megabytes)
    end

    def put(key, value)
      @cache_store.write(key, compress(value))
    end

    def get(key)
      stored_value =@cache_store.fetch(key)
      decompress(stored_value) if stored_value
    end

    def options
      @cache_store.options.clone
    end

    private
    def merge_setting(original_config, merging_config)
      config = original_config.clone
      config.keys.each do |key|
        key_string = key.to_s
        if merging_config.has_key?(key_string) && merging_config[key_string].present?
          config[key] = merging_config[key_string]
        end
      end
      config
    end

    def compress(value)
      LZ4.compress(value)
    end

    def decompress(value)
      LZ4.decompress(value, value.bytesize, 'UTF-8')
    end
  end
end
