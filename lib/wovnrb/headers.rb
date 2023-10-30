require 'wovnrb/custom_domain/custom_domain_lang_url_handler'

module Wovnrb
  class Headers
    attr_reader :unmasked_url, :url, :protocol, :unmasked_host, :host, :unmasked_pathname, :pathname, :pathname_with_trailing_slash_if_present

    # Generates new instance of Wovnrb::Headers.
    # Its parameters are set by parsing env variable.

    def initialize(env, settings, url_lang_switcher)
      request = Rack::Request.new(env)
      @url_lang_switcher = url_lang_switcher
      @env = env
      @settings = settings
      @protocol = request.scheme
      @unmasked_host = if settings['use_proxy'] && @env.key?('HTTP_X_FORWARDED_HOST')
                         @env['HTTP_X_FORWARDED_HOST']
                       else
                         @env['HTTP_HOST']
                       end
      unless @env.key?('REQUEST_URI')
        # Add '/' to PATH_INFO as a possible fix for pow server
        @env['REQUEST_URI'] = (/^[^\/]/.match?(@env['PATH_INFO']) ? '/' : '') + @env['PATH_INFO'] + (@env['QUERY_STRING'].empty? ? '' : "?#{@env['QUERY_STRING']}")
      end
      # REQUEST_URI is expected to not contain the server name
      # heroku contains http://...
      @env['REQUEST_URI'] = @env['REQUEST_URI'].sub(/^https?:\/\/[^\/]+/, '') if /^https?:\/\//.match?(@env['REQUEST_URI'])
      @unmasked_pathname = @env['REQUEST_URI'].split('?')[0]
      @unmasked_pathname += '/' unless @unmasked_pathname =~ /\/$/ || @unmasked_pathname =~ /\/[^\/.]+\.[^\/.]+$/
      @unmasked_url = "#{@protocol}://#{@unmasked_host}#{@unmasked_pathname}"
      @host = if settings['use_proxy'] && @env.key?('HTTP_X_FORWARDED_HOST')
                @env['HTTP_X_FORWARDED_HOST']
              else
                @env['HTTP_HOST']
              end
      @host = %w[subdomain custom_domain].include?(settings['url_pattern']) ? @url_lang_switcher.remove_lang_from_uri_component(@host, lang_code, self) : @host
      @pathname, @query = @env['REQUEST_URI'].split('?')
      @pathname = %w[path custom_domain].include?(settings['url_pattern']) ? @url_lang_switcher.remove_lang_from_uri_component(@pathname, lang_code, self) : @pathname
      @query ||= ''
      @url = "#{@host}#{@pathname}#{(@query.empty? ? '' : '?') + @url_lang_switcher.remove_lang_from_uri_component(@query, lang_code)}"
      if settings['query'].empty?
        @query = ''
      else
        query_vals = []
        settings['query'].each do |qv|
          rx = Regexp.new("(^|&)(?<query_val>#{qv}[^&]+)(&|$)")
          m = @query.match(rx)
          query_vals.push(m[:query_val]) if m && m[:query_val]
        end
        @query = if query_vals.empty?
                   ''
                 else
                   "?#{query_vals.sort.join('&')}"
                 end
      end
      @query = @url_lang_switcher.remove_lang_from_uri_component(@query, lang_code)
      @pathname_with_trailing_slash_if_present = @pathname
      @pathname = @pathname.gsub(/\/$/, '')
    end

    def url_with_scheme
      "#{@protocol}://#{@url}"
    end

    def unmasked_pathname_without_trailing_slash
      @unmasked_pathname.chomp('/')
    end

    # Get the language code of the current request
    #
    # @return [String] The lang code of the current page
    def lang_code
      url_language && !url_language.empty? ? url_language : @settings['default_lang']
    end

    # picks up language code from requested URL by using url_pattern_reg setting.
    # when language code is invalid, this method returns empty string.
    # if you want examples, please see test/lib/headers_test.rb.
    #
    # @return [String] language code in requrested URL.
    def url_language
      if @url_language.nil?
        full_url = if @settings['use_proxy'] && @env.key?('HTTP_X_FORWARDED_HOST')
                     "#{@env['HTTP_X_FORWARDED_HOST']}#{@env['REQUEST_URI']}"
                   else
                     "#{@env['SERVER_NAME']}#{@env['REQUEST_URI']}"
                   end

        new_lang_code = nil
        if @settings['url_pattern'] == 'custom_domain'
          custom_domain_langs = Store.instance.custom_domain_langs
          custom_domain = custom_domain_langs.custom_domain_lang_by_url(full_url)
          new_lang_code = custom_domain.lang if custom_domain.present?
        else
          rp = Regexp.new(@settings['url_pattern_reg'])
          match = full_url.match(rp)
          new_lang_code = Lang.get_code(match[:lang]) if match && match[:lang] && Lang.get_lang(match[:lang])
        end
        @url_language = new_lang_code.presence || ''
      end
      @url_language
    end

    def redirect(lang)
      redirect_headers = {}
      redirect_headers['location'] = redirect_location(lang)
      redirect_headers['content-length'] = '0'
      redirect_headers
    end

    def redirect_location(lang)
      if lang == @settings['default_lang']
        # IS THIS RIGHT??
        return url_with_scheme
      end

      @url_lang_switcher.add_lang_code(url_with_scheme, lang, self)
    end

    def request_out
      @env['wovnrb.target_lang'] = lang_code
      case @settings['url_pattern']
      when 'query'
        remove_lang_from_query
      when 'subdomain'
        remove_lang_from_host
      when 'custom_domain'
        remove_lang_from_host
        remove_lang_from_path
        # when 'path'
      else
        remove_lang_from_path
      end
      @env
    end

    def out(headers)
      lang_code = Store.instance.settings['custom_lang_aliases'][self.lang_code] || self.lang_code
      should_add_lang_code = lang_code != @settings['default_lang'] && headers.key?('Location') && !@settings['ignore_globs'].ignore?(headers['Location'])

      headers['Location'] = @url_lang_switcher.add_lang_code(headers['Location'], lang_code, self) if should_add_lang_code
      headers
    end

    def dirname
      if pathname_with_trailing_slash_if_present.include?('/')
        pathname_with_trailing_slash_if_present.end_with?('/') ? pathname_with_trailing_slash_if_present : pathname_with_trailing_slash_if_present[0, pathname_with_trailing_slash_if_present.rindex('/') + 1]
      else
        '/'
      end
    end

    def search_engine_bot?
      return false unless @env.key?('HTTP_USER_AGENT')

      bots = %w[Googlebot/ bingbot/ YandexBot/ YandexWebmaster/ DuckDuckBot-Https/ Baiduspider/ Slurp Yahoo]
      bots.any? { |bot| @env['HTTP_USER_AGENT'].include?(bot) }
    end

    def widget_request?
      @env.key?('HTTP_X_WOVN_WIDGET')
    end

    def to_absolute_path(path)
      absolute_path = path.blank? ? '/' : path
      absolute_path = URL.join_paths(dirname, absolute_path) unless absolute_path.starts_with?('/')
      URL.normalize_path_slash(path, absolute_path)
    end

    private

    def remove_lang_from_query
      @env['REQUEST_URI'] = @url_lang_switcher.remove_lang_from_uri_component(@env['REQUEST_URI'], lang_code) if @env.key?('REQUEST_URI')
      @env['QUERY_STRING'] = @url_lang_switcher.remove_lang_from_uri_component(@env['QUERY_STRING'], lang_code) if @env.key?('QUERY_STRING')
      @env['ORIGINAL_FULLPATH'] = @url_lang_switcher.remove_lang_from_uri_component(@env['ORIGINAL_FULLPATH'], lang_code) if @env.key?('ORIGINAL_FULLPATH')
    end

    def remove_lang_from_host
      if @settings['use_proxy'] && @env.key?('HTTP_X_FORWARDED_HOST')
        @env['HTTP_X_FORWARDED_HOST'] = @url_lang_switcher.remove_lang_from_uri_component(@env['HTTP_X_FORWARDED_HOST'], lang_code, self)
      else
        @env['HTTP_HOST'] = @url_lang_switcher.remove_lang_from_uri_component(@env['HTTP_HOST'], lang_code, self)
        @env['SERVER_NAME'] = @url_lang_switcher.remove_lang_from_uri_component(@env['SERVER_NAME'], lang_code, self)
      end
      @env['HTTP_REFERER'] = @url_lang_switcher.remove_lang_from_uri_component(@env['HTTP_REFERER'], lang_code, self) if @env.key?('HTTP_REFERER')
    end

    def remove_lang_from_path
      @env['REQUEST_URI'] = @url_lang_switcher.remove_lang_from_uri_component(@env['REQUEST_URI'], lang_code, self)
      @env['REQUEST_PATH'] = @url_lang_switcher.remove_lang_from_uri_component(@env['REQUEST_PATH'], lang_code, self) if @env.key?('REQUEST_PATH')
      @env['PATH_INFO'] = @url_lang_switcher.remove_lang_from_uri_component(@env['PATH_INFO'], lang_code, self)
      @env['ORIGINAL_FULLPATH'] = @url_lang_switcher.remove_lang_from_uri_component(@env['ORIGINAL_FULLPATH'], lang_code, self) if @env.key?('ORIGINAL_FULLPATH')
      @env['HTTP_REFERER'] = @url_lang_switcher.remove_lang_from_uri_component(@env['HTTP_REFERER'], lang_code, self) if @env.key?('HTTP_REFERER')
    end
  end
end
