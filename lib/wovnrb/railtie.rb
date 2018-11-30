module Wovnrb
  class Railtie < Rails::Railtie
    initializer 'wovnrb.configure_rails_initialization' do |app|
      app.middleware.insert_before(0, Wovnrb::Interceptor)
      # begin
      #  app.middleware.insert_before(Rack::Runtime, Wovnrb::Interceptor)
      # rescue
      #  app.middleware.insert_before(0, Wovnrb::Interceptor)
      # end

      # if Rails.env.development? && config.respond_to?(:wovnrb)
      #  config.after_initialize do
      #    config.wovnrb[:project_token] = User.first.short_token
      #  end
      # end
    end
  end
end
