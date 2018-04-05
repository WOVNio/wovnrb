module Wovnrb
  class Settings < Hash
    def initialize(*args, **kwargs)
      super(*args, **kwargs)
      @dynamic_settings = {}
    end

    def [](key)
      return @dynamic_settings[key] if @dynamic_settings.key?(key)
      return ignore_globs if key == 'ignore_globs'
      super(key)
    end

    def ignore_globs
      ignore_paths = self['ignore_paths']
      return [] unless ignore_paths.kind_of?(Array)
      ignore_paths.map { |pattern| Glob.new(pattern) }
    end

    def clear_dynamic_settings!
      @dynamic_settings.clear
    end

    def update_dynamic_settings!(params)
      # If the user defines dynamic settings for this request, use it instead of the config
      DYNAMIC_KEYS.each do |params_key, setting_key|
        value = params[params_key]
        @dynamic_settings[setting_key] = value if value
      end
    end

    DYNAMIC_KEYS = {
      'wovn_token' => 'project_token',
      'wovn_ignore_paths' => 'ignore_paths',
    }
  end
end
