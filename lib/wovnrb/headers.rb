module Wovnrb
  class Headers
    attr_reader :unmasked_url, :url, :protocol, :unmasked_host, :host, :unmasked_pathname, :pathname, :pathname_with_trailing_slash_if_present

    # Generates new instance of Wovnrb::Headers.
    # Its parameters are set by parsing env variable.

    def initialize(env, settings)
      request = Rack::Request.new(env)

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
        @env['REQUEST_URI'] = (@env['PATH_INFO'] =~ /^[^\/]/ ? '/' : '') + @env['PATH_INFO'] + (@env['QUERY_STRING'].empty? ? '' : "?#{@env['QUERY_STRING']}")
      end
      # REQUEST_URI is expected to not contain the server name
      # heroku contains http://...
      @env['REQUEST_URI'] = @env['REQUEST_URI'].sub(/^https?:\/\/[^\/]+/, '') if @env['REQUEST_URI'] =~ /^https?:\/\//
      @unmasked_pathname = @env['REQUEST_URI'].split('?')[0]
      @unmasked_pathname += '/' unless @unmasked_pathname =~ /\/$/ || @unmasked_pathname =~ /\/[^\/.]+\.[^\/.]+$/
      @unmasked_url = "#{@protocol}://#{@unmasked_host}#{@unmasked_pathname}"
      @host = if settings['use_proxy'] && @env.key?('HTTP_X_FORWARDED_HOST')
                @env['HTTP_X_FORWARDED_HOST']
              else
                @env['HTTP_HOST']
              end

      @host = remove_lang(@host, lang_code) unless settings['url_pattern'] == 'subdomain'
      @pathname, @query = @env['REQUEST_URI'].split('?')
      @pathname = remove_lang(@pathname, lang_code) unless settings['url_pattern'] == 'path'
      @query ||= ''
      @url = "#{@host}#{@pathname}#{(@query.empty? ? '' : '?') + remove_lang(@query, lang_code)}"
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
      @query = remove_lang(@query, lang_code)
      @pathname_with_trailing_slash_if_present = @pathname
      @pathname = @pathname.gsub(/\/$/, '')
    end

    def unmasked_pathname_without_trailing_slash
      @unmasked_pathname.chomp('/')
    end

    # Get the language code of the current request
    #
    # @return [String] The lang code of the current page
    def lang_code
      path_lang && !path_lang.empty? ? path_lang : @settings['default_lang']
    end

    # picks up language code from requested URL by using url_pattern_reg setting.
    # when language code is invalid, this method returns empty string.
    # if you want examples, please see test/lib/headers_test.rb.
    #
    # @return [String] language code in requrested URL.
    def path_lang
      if @path_lang.nil?
        rp = Regexp.new(@settings['url_pattern_reg'])
        match = if @settings['use_proxy'] && @env.key?('HTTP_X_FORWARDED_HOST')
                  "#{@env['HTTP_X_FORWARDED_HOST']}#{@env['REQUEST_URI']}".match(rp)
                else
                  "#{@env['SERVER_NAME']}#{@env['REQUEST_URI']}".match(rp)
                end
        @path_lang = if match && match[:lang] && Lang.get_lang(match[:lang])
                       Lang.get_code(match[:lang])
                     else
                       ''
                     end
      end
      @path_lang
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
        "#{protocol}://#{url}"
        # return remove_lang("#{@env['HTTP_HOST']}#{@env['REQUEST_URI']}", lang)
      else
        # TODO test
        lang_code = Store.instance.settings['custom_lang_aliases'][lang] || lang
        location = url
        case @settings['url_pattern']
        when 'query'
          lang_param_name = @settings['lang_param_name']
          location = if location =~ /\?/
                       "#{location}&#{lang_param_name}=#{lang_code}"
                     else
                       "#{location}?#{lang_param_name}=#{lang_code}"
                     end
        when 'subdomain'
          location = "#{lang_code.downcase}.#{location}"
        # when 'path'
        else
          location = location.sub(/(\/|$)/, "/#{lang_code}/")
        end
        "#{protocol}://#{location}"
      end
    end

    def request_out(_def_lang = @settings['default_lang'])
      @env['wovnrb.target_lang'] = lang_code
      case @settings['url_pattern']
      when 'query'
        @env['REQUEST_URI'] = remove_lang(@env['REQUEST_URI']) if @env.key?('REQUEST_URI')
        @env['QUERY_STRING'] = remove_lang(@env['QUERY_STRING']) if @env.key?('QUERY_STRING')
        @env['ORIGINAL_FULLPATH'] = remove_lang(@env['ORIGINAL_FULLPATH']) if @env.key?('ORIGINAL_FULLPATH')
      when 'subdomain'
        if @settings['use_proxy'] && @env.key?('HTTP_X_FORWARDED_HOST')
          @env['HTTP_X_FORWARDED_HOST'] = remove_lang(@env['HTTP_X_FORWARDED_HOST'])
        else
          @env['HTTP_HOST'] = remove_lang(@env['HTTP_HOST'])
          @env['SERVER_NAME'] = remove_lang(@env['SERVER_NAME'])
        end
        @env['HTTP_REFERER'] = remove_lang(@env['HTTP_REFERER']) if @env.key?('HTTP_REFERER')
      # when 'path'
      else
        @env['REQUEST_URI'] = remove_lang(@env['REQUEST_URI'])
        @env['REQUEST_PATH'] = remove_lang(@env['REQUEST_PATH']) if @env.key?('REQUEST_PATH')
        @env['PATH_INFO'] = remove_lang(@env['PATH_INFO'])
        @env['ORIGINAL_FULLPATH'] = remove_lang(@env['ORIGINAL_FULLPATH']) if @env.key?('ORIGINAL_FULLPATH')
        @env['HTTP_REFERER'] = remove_lang(@env['HTTP_REFERER']) if @env.key?('HTTP_REFERER')
      end
      @env
    end

    # TODO: this should be in Lang for reusability
    # Remove language code from the URI.
    #
    # @param uri  [String] original URI
    # @param lang_code [String] language code
    # @return     [String] removed URI
    def remove_lang(uri, lang = path_lang)
      lang_code = Store.instance.settings['custom_lang_aliases'][lang] || lang

      # Do nothing if lang is empty.
      return uri if lang_code.nil? || lang_code.empty?

      case @settings['url_pattern']
      when 'query'
        lang_param_name = @settings['lang_param_name']
        uri.sub(/(^|\?|&)#{lang_param_name}=#{lang_code}(&|$)/, '\1').gsub(/(\?|&)$/, '')
      when 'subdomain'
        rp = Regexp.new("(^|(//))#{lang_code}\\.", 'i')
        uri.sub(rp, '\1')
      # when 'path'
      else
        uri.sub(/\/#{lang_code}(\/|$)/, '/')
      end
    end

    def out(headers)
      r = Regexp.new("//#{@host}")
      lang_code = Store.instance.settings['custom_lang_aliases'][self.lang_code] || self.lang_code
      if lang_code != @settings['default_lang'] && headers.key?('Location') && headers['Location'] =~ r && !@settings['ignore_globs'].ignore?(headers['Location'])
        case @settings['url_pattern']
        when 'query'
          headers['Location'] += if headers['Location'] =~ /\?/
                                   '&'
                                 else
                                   '?'
                                 end
          headers['Location'] += "#{@settings['lang_param_name']}=#{lang_code}"
        when 'subdomain'
          headers['Location'] = headers['Location'].sub(/\/\/([^.]+)/, "//#{lang_code}.\\1")
        # when 'path'
        else
          headers['Location'] = headers['Location'].sub(/(\/\/[^\/]+)/, "\\1/#{lang_code}")
        end
      end
      headers
    end

    def dirname
      if pathname.include?('/')
        pathname.end_with?('/') ? pathname : pathname[0, pathname.rindex('/') + 1]
      else
        '/'
      end
    end
  end
end
