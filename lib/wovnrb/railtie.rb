module Wovnrb

  class Railtie < Rails::Railtie
    initializer 'wovnrb.configure_rails_initialization' do |app|
      app.middleware.insert_before(0, Wovnrb::Interceptor)

      #if Rails.env.development? && config.respond_to?(:wovnrb)
      #  config.after_initialize do
      #    config.wovnrb[:user_token] = User.first.short_token
      #  end
      #end
    end
  end

end
