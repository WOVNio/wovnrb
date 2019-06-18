module Wovnrb
  def self.middleware_inserted?(app)
    app.middleware.send(:operations).each do |_, middlewares, _|
      return true if middlewares.include?(Wovnrb::Interceptor)
    end

    false
  end

  class Railtie < Rails::Railtie
    initializer 'wovnrb.configure_rails_initialization' do |app|
      app.middleware.insert_before(0, Wovnrb::Interceptor) unless Wovnrb.middleware_inserted?(app)
    end
  end
end
