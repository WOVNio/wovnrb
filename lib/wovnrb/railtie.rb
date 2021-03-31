module Wovnrb
  def self.middleware_inserted?(app, middleware)
    app.middleware.send(:operations).each do |_, middlewares, _|
      return true if middlewares&.include?(middleware)
    end

    false
  end

  class Railtie < Rails::Railtie
    initializer 'wovnrb.configure_rails_initialization' do |app|
      unless Wovnrb.middleware_inserted?(app, Wovnrb::Interceptor)
        if defined?(Rack::Deflater) && Wovnrb.middleware_inserted?(app, Rack::Deflater)
          app.middleware.insert_after(Rack::Deflater, Wovnrb::Interceptor)
        else
          app.middleware.insert_before(0, Wovnrb::Interceptor)
        end
      end
    end
  end
end
