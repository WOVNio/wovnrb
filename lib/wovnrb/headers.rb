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
      @changed_vals = {}
      @env = env
      @protocol = @env['rack.url_scheme']
      @unmasked_host = @env['HTTP_HOST']
      @unmasked_pathname = @env['REQUEST_PATH']
      @unmasked_pathname += '/' unless @pathname =~ /\/$/ || @pathname =~ /\/[^\/.]+\.[^\/.]+$/
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
      @url = "#{@protocol}://#{@host}#{@pathname}#{@query}"
      @url_pattern_reg = settings['url_pattern_reg']
    end

    def lang
      if @lang.nil?
        rp = Regexp.new(@url_pattern_reg)
        match = "#{@env['SERVER_NAME']}#{@env['REQUEST_URI']}".match(rp)
        if match && match[:lang] && Lang::LANG[match[:lang]]
          @lang = match[:lang]
        else
          return DEFAULT_LANG
        end
      end
      return @lang
    end

    def settings(settings)
      @settings = settings
    end

    def request_out(def_lang=DEFAULT_LANG)
      out = @env
      # get subdomain -> match group 1
      rp = Regexp.new(@url_pattern_reg)
      #match = out["SERVER_NAME"].match(rp)
      #match = out["SERVER_NAME"].match(/^([^.]+)\.[^.]+\./)
      @changed_vals = {"HTTP_HOST" => out["HTTP_HOST"],
                      "HTTP_REFERER" => out["HTTP_REFERER"],
                      "SERVER_NAME" => out["SERVER_NAME"]}
      if self.lang#match && Lang::LANG[match[:lang]]
        #out["HTTP_HOST"] = out["HTTP_HOST"].sub(/^([^.]*\.)?([^.]+\..+)$/, '\2')
        out["HTTP_HOST"] = out["HTTP_HOST"].sub("#{self.lang}.", '')
        out["HTTP_REFERER"] = out["HTTP_REFERER"].sub("#{self.lang}.", '') if out["HTTP_REFERER"]
        out["SERVER_NAME"] = out["SERVER_NAME"].sub("#{self.lang}.", '')
      end
      out
    end

    def out(headers)
      if headers.has_key?("Location")
        headers["Location"] = headers["Location"].sub(/\/\/[^\/]+\//, "//#{@changed_vals['HTTP_HOST']}/")
      end
    end

  end

end
