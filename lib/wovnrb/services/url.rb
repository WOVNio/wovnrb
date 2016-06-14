class Wovnrb
  class URL
    def self.resolve_absolute_url(curr_location, rel_location)
    end

    # Set the path lang to
    def self.prepend_path(url, dir)
     result = url.sub(/(.+\.[^\/]+)(\/|$)/, '\1/' + dir + '\2')
     return result
     end
  end
end
