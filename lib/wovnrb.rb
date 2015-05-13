require 'wovnrb/store'
require 'wovnrb/headers'
require 'wovnrb/lang'
require 'dom'
require 'json'

require 'wovnrb/railtie' if defined?(Rails)

module Wovnrb

  DEFAULT_LANG = 'en'
  STORE = Store.new
  
  class Interceptor
    def initialize(app)
      @app = app
    end

    def call(env)
      @env = env
      headers = Headers.new(env, STORE.get_settings)
      lang = headers.lang

      # pass to application
      status, res_headers, body = @app.call(headers.request_out)

      if res_headers["Content-Type"] =~ /html/ && !body[0].nil?
# Can we make this request beforehand?
        values = STORE.get_values(headers.url)
        url = {
                :protocol => headers.protocol, 
                :host => headers.host, 
                :pathname => headers.pathname
              }
        switch_lang(body, values, url, lang) unless status.to_s =~ /^1|302/ || lang === DEFAULT_LANG
        #d = Dom.new(storage.get_values, body, lang)
        #body[0] = transform_body(body, lang)
      end

      headers.out(res_headers)
      [status, res_headers, body]
      #[status, res_headers, d.transform()]
    end

    #def transform_request(env, def_lang=DEFAULT_LANG)
    #  # get subdomain -> match group 1
    #  match = env["SERVER_NAME"].match(/^([^.]+)\.[^.]+\./)
    #  changed_vals = {"HTTP_HOST" => env["HTTP_HOST"],
    #                  "HTTP_REFERER" => env["HTTP_REFERER"],
    #                  "SERVER_NAME" => env["SERVER_NAME"]}
    #  if match && Lang::LANG[match[1]]
    #    changed_vals[:lang] = match[1]
    #    #env["HTTP_HOST"] = env["HTTP_HOST"].sub(/^([^.]*\.)?([^.]+\..+)$/, '\2')
    #    env["HTTP_HOST"] = env["HTTP_HOST"].sub("#{match[1]}.", '')
    #    env["HTTP_REFERER"] = env["HTTP_REFERER"].sub("#{match[1]}.", '') if env["HTTP_REFERER"]
    #    env["SERVER_NAME"] = env["SERVER_NAME"].sub("#{match[1]}.", '')
    #  end
    #  changed_vals[:lang] || def_lang
    #end

    def transform_body(body, lang=DEFAULT_LANG)

      # key = body[0].match(/data-wovnio="key=([^"]+)/)[1]
      # get the url of the requested page
      # escape_url = env["rack.url_scheme"] + env["HTTP_HOST"] + env["PATH_INFO"]
      # get the values from the requested page
      # TODO store these values and simply check file
      response = Net::HTTP.get_response URI.parse("https://j.wovn.io/cdn/0/2Wle3/?u=https%3A%2F%2Fwovn.io%2Fdashboard")
      location = response['location']
      cdn = Net::HTTP.get URI.parse(location)
      res_object_string = cdn.match(/\{\"id[\s\S]*\}\}\}/)
      res_object = JSON.parse(res_object_string.to_s)
      element_values_raw = res_object["element_values"]
      original_lang = res_object["language"]
      element_values = {}
      # fill in the values hash
      element_values_raw.each do |ele_val|
        element_values[ele_val["src_body"]] = {} if element_values[ele_val["src_body"]].nil?
        element_values[ele_val["src_body"]][ele_val["language"]] = [] if element_values[ele_val["src_body"]][ele_val["language"]].nil?
        element_values[ele_val["src_body"]][original_lang] = [] if element_values[ele_val["src_body"]][original_lang].nil?
        count = element_values[ele_val["src_body"]][ele_val["language"]].length
        element_values[ele_val["src_body"]][ele_val["language"]][count] = {"xpath" => ele_val["xpath"], "data" => ele_val["body"]}
        element_values[ele_val["src_body"]][original_lang][count] = {"xpath" => ele_val["xpath"], "data" => ele_val["src_body"]}        
      end

      lang = 'ja'
      d = Dom::Dom.new(element_values, body[0], lang)
      res = d.transform()
      res

    end

    def switch_lang(body, values, url, lang=DEFAULT_LANG)
      def_lang = 'en'
      text_index = values['text_vals']
      src_index = values['img_vals'] || {}
      img_src_prefix = values['img_src_prefix'] || ''
      string_index = {}
      #values.each do |v|
      #  src_data = v['src_body'].strip
      #  data = v['body'].strip != "" ? v['body'].strip : "\u200b"
      #  lang = v['language']
      #  if !string_index.has_key?(src_data)
      #    string_index[src_data] = {}
      #    string_index[src_data][def_lang] = [];
      #  end
      #  # iterator doesn't support [1]
      #  string_index[src_data][def_lang].push({'xpath' => v['xpath'].gsub(/\[1\]/, ''), 'data' => src_data})
      #  string_index[src_data][lang] = [] if !string_index[src_data].has_key?(lang)
      #  string_index[src_data][lang].push({'xpath' => v['xpath'].gsub(/\[1\]/, ''), 'data' => data})
      #end
      body.map! do |b|
        d = Nokogiri::HTML5(b)
        d.xpath('//text()').each do |node|
          if text_index[node.content] && text_index[node.content][lang]
            node.content = text_index[node.content][lang][0]['data']
          end
        end
        d.xpath('//img').each do |node|
          # use regular expressions to support case insensitivity (right?)
          if node.to_html =~ /src=['"][^'"]*['"]/i
            src = node.to_html.match(/src=['"]([^&'"]*)['"]/i)[1]
# THIS SRC CORRECTION DOES NOT HANDLE ONE IMPORTANT CASE
# 1) "../path/with/ellipse"
            # if this is not an absolute src
            if src !~ /:\/\//
              # if this is a path with a leading slash
              if src =~ /^\//
                src = "#{url[:protocol]}://#{url[:host]}#{src}"
              else
                src = "#{url[:protocol]}://#{url[:host]}#{url[:path]}#{src}"
              end
            end
          
            if src_index[src] && src_index[src][lang]
              node.attribute('src').value = "#{img_src_prefix}#{src_index[src][lang][0]['data']}"
            end
          end
        end
        d.to_html
      end
    end

  end

end

