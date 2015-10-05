module Wovnrb
  class URL

    def self.resolve_absolute_url(curr_location, rel_location)
    end

    # Set the path lang to 
    def self.prepend_path(url, dir)

     result = url.sub(/(.+\.[^\/]+)(\/|$)/, '\1/' + dir + '\2') 
     return result

     end

=begin

     url_slash = url.count("/")

      if url.include?("//") && url_slash >= 3 then

        url_base = url.split("/", 4)

        url_begin = url_base[0]
        url_middle = url_base[2]
        url_end = url_base[3]

        result = url_begin + "//" + url_middle + "/" + dir + "/" + url_end

        return result

      elsif url.include?("//") then 

        result = url + "/" + dir 

        return result

      elsif url.include?("/") #&& url_slash >= 2 then

        url_base = url.split("/", 2)

        url_begin = url_base[0]
        url_end = url_base[1]

       result = url_begin + "/" + dir + "/" + url_end

        return result

      else

        result = url + "/" + dir

        return result

     end
    end

=end

    #def self.set_query_lang(url, lang, param_name='wovn')
    #  url =
    #  lang =
    #  param_name = 'wovn'
    #  return 
    #end

    #def self.set_subdomain_lang(url, lang)
    #end

    #def self.remove_subdomain(url)
    #end

          #def self.add_subdomain(url, subdomain)
    #end
    #def iself.set_query_param(url, param, value)
    #end

  end
end
