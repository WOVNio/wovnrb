module Wovnrb

  class Headers
    attr_reader :unmasked_url
    attr_reader :url
    attr_reader :protocol
    attr_reader :unmasked_host
    attr_reader :host
    attr_reader :unmasked_pathname
    attr_reader :pathname

    def initialize(env, settings)
      @env = env
      @protocol = @env['rack.url_scheme']
      @unmasked_host = @env['HTTP_HOST']
      @unmasked_pathname = @env['REQUEST_URI'].split('?')[0]
      @unmasked_pathname += '/' unless @unmasked_pathname =~ /\/$/ || @unmasked_pathname =~ /\/[^\/.]+\.[^\/.]+$/
      @unmasked_url = "#{@protocol}://#{@unmasked_host}#{@unmasked_pathname}"
      @host = @env['HTTP_HOST']
      @pathname, @query = @env['REQUEST_URI'].split('?')
      @query = @query || ''
      if settings['query'].length > 0
        query_vals = []
        settings['query'].each do |qv|
          rx = Regexp.new("(^|&)(?<query_val>#{qv}[^&]+)(&|$)")
          m = @query.match(rx)
          if m && m[:query_val]
            query_vals.push(m[:query_val])
          end
        end
        if query_vals.length > 0
          @query = "?#{query_vals.sort.join('&')}"
        else
          @query = ''
        end
      else
        @query = ''
      end
      @pathname = @pathname.gsub(/\/$/, '')
      @url = remove_lang("#{@host}#{@pathname}#{@query}", lang)
    end

    def lang
      (self.path_lang && self.path_lang.length > 0) ? self.path_lang : STORE.get_settings['default_lang']
    end

    def path_lang
      if @path_lang.nil?
        rp = Regexp.new(STORE.get_settings['url_pattern_reg'])
        match = "#{@env['SERVER_NAME']}#{@env['REQUEST_URI']}".match(rp)
        if match && match[:lang] && Lang::LANG[match[:lang]]
          @path_lang = match[:lang]
        else
          @path_lang = ''
        end
      end
      return @path_lang
    end

    def browser_lang
      if @browser_lang.nil?
        match = (@env['HTTP_COOKIE'] || '').match(/wovn_selected_lang\s*=\s*(?<lang>[^;\s]+)/)
        if match && match[:lang] && Lang::LANG[match[:lang]]
          @browser_lang = match[:lang]
        else
          accept_langs = (@env['HTTP_ACCEPT_LANGUAGE'] || '').split(/[,;]/)
          accept_langs.each do |l|
            if Lang::LANG[l]
              @browser_lang = l
              return l
            end
          end
          @browser_lang = self.path_lang
        end
      end
      return @browser_lang
    end

    def redirect(lang=self.browser_lang)
      redirect_headers = {}
      redirect_headers['location'] = self.redirect_location(lang)
      redirect_headers['content-length'] = '0'
      return redirect_headers
    end

    def redirect_location(lang)
      if lang == STORE.get_settings['default_lang']
        return remove_lang("#{@env['HTTP_HOST']}#{@env['REQUEST_URI']}", lang)
      else
        case STORE.get_settings['url_pattern_name']
        when 'query'
          if @env['REQUEST_URI'] !~ /\?/
            location = "#{@env['HTTP_HOST']}#{@env['REQUEST_URI']}?wovn=#{lang}"
          elsif @env['REQUEST_URI'] !~ /(\?|&)wovn=/
            location = "#{@env['HTTP_HOST']}#{@env['REQUEST_URI']}&wovn=#{lang}"
          else
            location = "#{@env['HTTP_HOST']}#{@env['REQUEST_URI']}".sub(/wovn=[^&]*/, "wovn=#{lang}")
          end
          return location
        when 'path'
          rp = Regexp.new(STORE.get_settings['url_pattern_reg'])
          location = "#{@env['HTTP_HOST']}#{@env['REQUEST_URI']}"
          match = location.match(rp)
          if match && match[:lang] && Lang::LANG[match[:lang]]
            location = location[0, match.offset(:lang)[0]] + location[match.offset(:lang)[1], location.length]
            location.insert!(match.offset(:lang)[0], lang)
            return "#{@env['rack.url_scheme']}://#{location}"
          else
            return "#{@env['rack.url_scheme']}://#{@env['HTTP_HOST']}/#{lang}#{@env['REQUEST_URI']}"
          end
       #when 'subdomain'
        else
          rp = Regexp.new(STORE.get_settings['url_pattern_reg'])
          location = "#{@env['HTTP_HOST']}#{@env['REQUEST_URI']}"
          match = location.match(rp)
          if match && match[:lang] && Lang::LANG[match[:lang]]
            location = location[0, match.offset(:lang)[0]] + location[match.offset(:lang)[1], location.length]
            location.insert!(match.offset(:lang)[0], lang)
            return "#{@env['rack.url_scheme']}://#{location}"
          else
            return "#{@env['rack.url_scheme']}://#{lang}.#{location}"
          end
        end
      end
    end

    def settings(settings)
      @settings = settings
    end

    def request_out(def_lang=STORE.get_settings['default_lang'])
      if self.lang
        case STORE.get_settings['url_pattern_name']
        when 'query'
          @env['REQUEST_URI'] = remove_lang(@env['REQUEST_URI'])
          if @env.has_key?('QUERY_STRING')
            @env['QUERY_STRING'] = remove_lang(@env['QUERY_STRING'])
          end
          if @env.has_key?('ORIGINAL_FULLPATH')
            @env['ORIGINAL_FULLPATH'] = remove_lang(@env['ORIGINAL_FULLPATH'])
          end
        when 'path'
          @env['REQUEST_URI'] = remove_lang(@env['REQUEST_URI'])
          @env['REQUEST_PATH'] = remove_lang(@env['REQUEST_PATH'])
          @env['PATH_INFO'] = remove_lang(@env['PATH_INFO'])
          if @env.has_key?('ORIGINAL_FULLPATH')
            @env['ORIGINAL_FULLPATH'] = remove_lang(@env['ORIGINAL_FULLPATH'])
          end
       #when 'subomain'
        else
          @env["HTTP_HOST"] = remove_lang(@env["HTTP_HOST"])
          @env["HTTP_REFERER"] = remove_lang(@env["HTTP_REFERER"])
          @env["SERVER_NAME"] = remove_lang(@env["SERVER_NAME"])
        end
      end
      @env
    end

    def remove_lang(uri, lang=self.path_lang)
        rp = Regexp.new(STORE.get_settings['url_pattern_reg'])
        case STORE.get_settings['url_pattern_name']
        when 'query'
          return uri.sub(/wovn=#{lang}(&|$)/, '\1')
        when 'path'
          return uri.sub(/\/#{lang}(\/|$)/, '/')
       #when 'subomain'
        else
          return uri.sub("//#{lang}.", '//')
        end
    end

    def out(headers)
      if headers.has_key?("Location")
        case STORE.get_settings['url_pattern_name']
        when 'query'
          if headers["Location"] =~ /\?/
            headers["Location"] += "&"
          else
            headers["Location"] += "?"
          end
          headers['Location'] += "wovn=#{self.lang}"
        when 'path'
          headers["Location"] = headers['Location'].sub(/(\/\/[^\/]+)/, '\1/' + self.lang)
       #when 'subdomain'
        else
          headers["Location"] = headers["Location"].sub(/\/\/([^.]+)/, '//' + self.lang + '.\1')
        end
      end
      headers
    end

  end

end
