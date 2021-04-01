require 'wovnrb/configuration'

module Wovnrb
  class Railtie < Rails::Railtie
    initializer 'wovnrb.configure_rails_initialization' do |app|
      app.middleware.insert_before(0, Wovnrb::Interceptor) if Wovnrb.configuration.install_middleware
    end
  end
end
