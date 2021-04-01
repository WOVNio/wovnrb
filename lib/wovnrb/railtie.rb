require 'wovnrb/configuration'

module Wovnrb
  class Railtie < Rails::Railtie
    initializer 'wovnrb.configure_rails_initialization' do |app|
      if Wovnrb.configuration.install_middleware
        app.middleware.insert_before(0, Wovnrb::Interceptor)
      end
    end
  end
end
