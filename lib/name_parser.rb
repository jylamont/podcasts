require 'namae'
require 'engtagger'

module Podcasts
  class NameParser
    def parse(text, compontent_hits = 1)
      tagged = tagger.add_tags(text)
      return [] if tagged.nil?
      
      # Filter noun phrases by proper nouns
      ppn = tagger.get_proper_nouns(tagged)
      possible_names = extract_names(tagged, ppn.keys)
      
      # Ensure names are actual names
      possible_names.select do |name|
        [name.given, name.family].any? { |i| ppn[i] >= compontent_hits }
      end
    end

    private
    
    def tagger 
      @tgr ||= EngTagger.new
    end

    def extract_names(tagged, ppn)
      result = tagger.get_noun_phrases(tagged).keys.select do |potential|
        potential.split(" ").all? { |i| ppn.include?(i) }
      end.reject { |i| i.split(" ").size == 1 }

      result.map { |possible_name| Namae.parse(possible_name) }.flatten
    end
  end
end