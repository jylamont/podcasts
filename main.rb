require 'optparse'
require 'pstore'

require './lib/podcasts'

@options = {}
@pstore_path = "data.pstore"
@db = PStore.new(@pstore_path)
@sources = []

def clean_sources(sources)
  sources.reject do |obj|
    obj.nil? || (obj.empty? if obj.respond_to?(:empty?))
  end.uniq
end

def load_data!
  @db.transaction do 
    @sources = clean_sources(@db[:sources] || []).map do |h| 
      Podcasts::Source.from_h(h)
    end
  end
end

def modify_sources!
  @options[:sources][:add].each do |url|
    @sources << Podcasts::Source.parse(url)
  end

  @db.transaction do 
    @db[:sources] = clean_sources(@sources).map(&:to_h)
  end
end

def index
  @index = {}

  @sources.each do |source|
    Podcasts::Indexer.index!(@data, source).each do |name, results|
      @index[name] ||= []
      @index[name] += results
    end
  end

  @db.transaction do 
    @db[:index] = @index
  end
end

def search_for_podcaster
  @db.transaction { @db[:index][@options[:find]] }.flatten.reject(&:empty?).each do |result|
    result.each do |k,v|
      puts "#{k.capitalize}: #{v}"
    end
    puts ""
  end
end

load_data!
OptionParser.new(&@cli_args_parser_fn).parse! # Parse Command Line options

modify_sources! if @options[:sources]
index if @options[:index]
search_for_podcaster if @options[:find]