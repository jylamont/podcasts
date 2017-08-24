require 'optparse'
require 'pstore'
require 'erb'
require './lib/podcasts'

@options = {}
@pstore_path = "data.pstore"
@db = PStore.new(@pstore_path)
@sources = []

def parse_args!
  OptionParser.new do |parser|
    banner = [
      "Podcasts #{Podcasts::Version}",
      "Usage: main.rb [options]"
    ].join("\n")
    parser.banner = banner
  
    parser.on("-f", "--find NAME", String, "The name of the podcaster you are searching for.") do |v|
      @options[:find] = v
    end
  
    parser.on("-i", "--ignore-author", "Ignore results where the podcaster is the author.") do |v|
      @options[:ignore_author] = true
    end

    parser.on("-r", "--reindex", "Re-index sources for faster querying") do 
      @options[:index] = true
    end

    parser.on("-s", "--sources", "Print sources.") do
      if @sources.empty?
        puts "There are no sources."
      else
        puts "Sources:"
        puts @sources
      end
    end

    parser.on("-a", "-add", "Add a source") do |v|
      @options[:sources] ||= {}
      @options[:sources][:add] ||= []
      @options[:sources][:add] << v
    end
  
    parser.on("-h", "--help", "Show this help message") do ||
      puts parser
    end
  end.parse!
end

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

  b = binding
  lib_folder = File.expand_path(File.dirname(__FILE__), "lib")
  path = "#{lib_folder}/index.html.erb"
  text = File.open(path).read
  text = ERB.new(text).result(b)

  File.write("/tmp/test.html", text)
end

def search_for_podcaster
  @sources.map do |source|
    Podcasts::FindPodcaster.find(source, @options[:find])
  end.flatten.reject(&:empty?).each do |result|
    result.each do |k,v|
      puts "#{k.capitalize}: #{v}"
    end
    puts ""
  end
end

load_data!
parse_args!

modify_sources! if @options[:sources]
index if @options[:index]
search_for_podcaster if @options[:find]