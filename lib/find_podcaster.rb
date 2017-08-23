require 'nokogiri'

module Podcasts
  class FindPodcaster
    def self.find(source, query)
      data = Nokogiri(
        RestClient.get(source.url)
      )

      results = data.xpath("//item").map do |node|
        {
          "podcast" => source.name,
          "title" => node.at_xpath("title").text,
          "description" => node.at_xpath("description").text,
          "link" => node.at_xpath("link").text
        }
      end.reject(&:empty?)

      results.select do |hash|
        hash["title"].include?(query) || hash["description"].include?(query)
      end.each { |h| h.delete("description") }
    end
  end
end