module Wovnrb

  class Headers
    attr_reader :unmasked_url
    attr_reader :url
    attr_reader :protocol
    attr_reader :unmasked_host
    attr_reader :host
    attr_reader :unmasked_pathname
    attr_reader :pathname
    attr_reader :redis_url

    def initialize(env, settings)
      @env = env
      @protocol = @env['rack.url_scheme']
      @unmasked_host = @env['HTTP_HOST']
      unless @env.has_key?('REQUEST_URI')
        @env['REQUEST_URI'] = @env['PATH_INFO'] + (@env['QUERY_STRING'].size == 0 ? '' : "?#{@env['QUERY_STRING']}")
      end
      @unmasked_pathname = @env['REQUEST_URI'].split('?')[0]
      @unmasked_pathname += '/' unless @unmasked_pathname =~ /\/$/ || @unmasked_pathname =~ /\/[^\/.]+\.[^\/.]+$/
      @unmasked_url = "#{@protocol}://#{@unmasked_host}#{@unmasked_pathname}"
      @host = remove_lang(@env['HTTP_HOST'], self.lang)
      @pathname, @query = @env['REQUEST_URI'].split('?')
      @pathname = remove_lang(@pathname, self.lang)
      @query = @query || ''
      @url = "#{@host}#{@pathname}#{(@query.length > 0 ? '?' : '') + remove_lang(@query, self.lang)}"
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
        end
      else
        @query = ''
      end
      @query = remove_lang(@query, self.lang)
      @pathname = @pathname.gsub(/\/$/, '')
      @redis_url = "#{@host}#{@pathname}#{@query}"
      #binding.pry
    end

    def lang
      (self.path_lang && self.path_lang.length > 0) ? self.path_lang : STORE.settings['default_lang']
    end

    def path_lang
      if @path_lang.nil?
        rp = Regexp.new(STORE.settings['url_pattern_reg'])
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
# IS THIS RIGHT?
          @browser_lang = ''
          accept_langs = (@env['HTTP_ACCEPT_LANGUAGE'] || '').split(/[,;]/)
          accept_langs.each do |l|
            if Lang::LANG[l]
              @browser_lang = l
              break
            end
          end
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
      if lang == STORE.settings['default_lang']
# IS THIS RIGHT??
        return "#{self.protocol}://#{self.url}"
        #return remove_lang("#{@env['HTTP_HOST']}#{@env['REQUEST_URI']}", lang)
      else
        location = self.url
        case STORE.settings['url_pattern_name']
        when 'query'
          if location !~ /\?/
            location = "#{location}?wovn=#{lang}"
          else @env['REQUEST_URI'] !~ /(\?|&)wovn=/
            location = "#{location}&wovn=#{lang}"
          end
        when 'subdomain'
          location = "#{lang}.#{location}"
       #when 'path'
        else
          location = location.sub(/(\/|$)/, "/#{lang}/");
        end
        return "#{self.protocol}://#{location}"
      end
    end

    def request_out(def_lang=STORE.settings['default_lang'])
      case STORE.settings['url_pattern_name']
      when 'query'
        @env['REQUEST_URI'] = remove_lang(@env['REQUEST_URI']) if @env.has_key?('REQUEST_URI')
        @env['QUERY_STRING'] = remove_lang(@env['QUERY_STRING']) if @env.has_key?('QUERY_STRING')
        @env['ORIGINAL_FULLPATH'] = remove_lang(@env['ORIGINAL_FULLPATH']) if @env.has_key?('ORIGINAL_FULLPATH')
      when 'subdomain'
        @env["HTTP_HOST"] = remove_lang(@env["HTTP_HOST"])
        @env["SERVER_NAME"] = remove_lang(@env["SERVER_NAME"])
        if @env.has_key?('HTTP_REFERER')
          @env["HTTP_REFERER"] = remove_lang(@env["HTTP_REFERER"])
        end
     #when 'path'
      else
        @env['REQUEST_URI'] = remove_lang(@env['REQUEST_URI'])
        if @env.has_key?('REQUEST_PATH')
          @env['REQUEST_PATH'] = remove_lang(@env['REQUEST_PATH'])
        end
        @env['PATH_INFO'] = remove_lang(@env['PATH_INFO'])
        if @env.has_key?('ORIGINAL_FULLPATH')
          @env['ORIGINAL_FULLPATH'] = remove_lang(@env['ORIGINAL_FULLPATH'])
        end
      end
      @env
    end

    def remove_lang(uri, lang=self.path_lang)
      case STORE.settings['url_pattern_name']
      when 'query'
        return uri.sub(/(^|\?|&)wovn=#{lang}(&|$)/, '\1').gsub(/(\?|&)$/, '')
      when 'subdomain'
        rp = Regexp.new('(^|(//))' + lang + '\.')
        return uri.sub(rp, '\1')
     #when 'path'
      else
        return uri.sub(/\/#{lang}(\/|$)/, '/')
      end
    end

    def out(headers)
      if headers.has_key?("Location")
        case STORE.settings['url_pattern_name']
        when 'query'
          if headers["Location"] =~ /\?/
            headers["Location"] += "&"
          else
            headers["Location"] += "?"
          end
          headers['Location'] += "wovn=#{self.lang}"
        when 'subdomain'
          headers["Location"] = headers["Location"].sub(/\/\/([^.]+)/, '//' + self.lang + '.\1')
       #when 'path'
        else
          headers["Location"] = headers['Location'].sub(/(\/\/[^\/]+)/, '\1/' + self.lang)
        end
      end
      headers
    end

  end

end
