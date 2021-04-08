module Wovnrb
  class Railtie < Rails::Railtie
    initializer 'wovnrb.configure_rails_initialization' do |app|
      app.middleware.insert_before(0, Wovnrb::Interceptor) if Rails.configuration.wovnrb[:install_middleware]
    end
  end
end
