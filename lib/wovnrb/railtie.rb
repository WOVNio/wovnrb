module Wovnrb
  class Railtie < Rails::Railtie
    initializer 'wovnrb.configure_rails_initialization' do |app|
      install_middleware = Rails.configuration.wovnrb.fetch(:install_middleware, true)

      app.middleware.insert_before(0, Wovnrb::Interceptor) if install_middleware
    end
  end
end
