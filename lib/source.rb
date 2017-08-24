require 'json'
require 'restclient'
require 'nokogiri'
require 'rails-html-sanitizer'

module Podcasts
  class Source
    attr_accessor :name, :author, :url

    def self.from_h(hash)
      new.tap do |source|
        source.name = hash["name"]
        source.author = hash["author"]
        source.url = hash["url"]
      end
    end

    def self.parse(url)
      # Extract id from URL
      # example url: https://itunes.apple.com/us/podcast/the-tim-ferriss-show/id863897795\?mt\=2

      if /https\:\/\/.+\/id(\d+)\??.*/ =~ url
        itunes_lookup = "https://itunes.apple.com/lookup?id=#{$1}&entity=podcast"
        lookup = JSON.parse(
          RestClient.get(itunes_lookup)
        )
        lookup = lookup["results"].first

        from_h(
          "name" => lookup["collectionName"],
          "author" => Artist.parse(lookup["artistName"]),
          "url" => lookup["feedUrl"]
        )
      end
    end

    def podcasts
      data = RestClient.get(self.url)
      
      Nokogiri(data).xpath("//item").map do |node|
        {
          "podcast" => self.name,
          "title" => node.at_xpath("title").text,
          "description" => Rails::Html::FullSanitizer.new.sanitize(node.at_xpath("description").text),
          "link" => node.at_xpath("link").text
        }
      end.reject(&:empty?)
    end

    def to_h
      {"name" => @name, "author" => @author, "url" => @url}
    end

    def to_s
      to_h.to_s
    end

    # Equality

    def ==(other)
      self.to_h == other.to_h
    end
    alias_method :eql?, :==

    def hash
      to_h.hash
    end 

    class Artist
      def self.parse(name)
        if /(.+)\: .*/ =~ name
          $1
        else
          name
        end
      end
    end
  end
end