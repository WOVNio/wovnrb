Bundler.require(*Rails.groups)

module TestSite
  class Application < Rails::Application
    config.load_defaults 6.0
    config.hosts.clear

    config.wovnrb = {
      :project_token => 'EnS!t3',
      :default_lang => 'en',
      :supported_langs => ['en', 'ja', 'fr'],
      :url_pattern => 'path',
      :install_middleware => true
    }
  end
end
