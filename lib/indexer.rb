module Podcasts
  class Indexer
    def self.index!(db, source)
      # Parse out name per episode from source
      index = {}

      t1 = Time.now
      name_parser = Podcasts::NameParser.new

      source.podcasts.each do |hash|
        puts hash["title"]
        names_from_title = name_parser.parse(hash["title"])
        names_from_description = name_parser.parse(hash["description"])
        index_names = (names_from_title & names_from_description)
        
        index_names.each do |name| 
          index[name] ||= []
          index[name] << hash
        end
      end

      t2 = Time.now
      puts "#{source.name}: Time = #{(t2 - t1).to_f}"

      index
    end
  end
end