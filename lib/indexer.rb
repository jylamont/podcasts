module Podcasts
  class Indexer
    def self.index!(source)
      new.index(source)
    end

    def index(source)
      # Parse out name per episode from source
      index = {}
      
      bm(source) do 
        source.podcasts.each do |hash|
          index_names = parse_names(hash)
          next if index_names.empty?

          index_names.each do |name|  
            key = name.to_s
            index[key] ||= []
            index[key] << sanitized_podcast_hash(hash)
          end      
        end
      end
      
      index
    end

    private

    def bm(source, &block)
      t1 = Time.now
      result = block.call
      t2 = Time.now

      puts "Indexed #{source.podcasts.size} podcasts for #{source.name} in #{(t2 - t1).to_f}s"
      result
    end

    def parse_names(hash)
      names_from_title = name_parser.parse(hash["title"])
      names_from_description = name_parser.parse(hash["description"])
      (names_from_title & names_from_description)
    end

    def name_parser
      @name_parser ||= Podcasts::NameParser.new
    end
    
    def sanitized_podcast_hash(hash)
      {
        "podcast" => hash["podcast"],
        "title" => hash["title"],
        "link" => hash["link"]
      }
    end
  end
end