

module Podcasts
  class FindPodcaster
    def self.find(source, query)
      source.podcasts.select do |hash|
        hash["title"].include?(query) || hash["description"].include?(query)
      end.each { |h| h.delete("description") }
    end
  end
end