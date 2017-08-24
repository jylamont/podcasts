require 'optparse'
require './lib/podcasts'

@options = {}
@db = Podcasts::DB.default
@sources = []

def clean_sources
  @sources.reject do |obj|
    obj.nil? || (obj.empty? if obj.respond_to?(:empty?))
  end.uniq
end

def load_data!
  @sources = @db.fetch(:sources) { [] }
  @sources = clean_sources.map do |h| 
    Podcasts::Source.from_h(h)
  end
end

def modify_sources!
  @options[:sources][:add].each do |url|
    @sources << Podcasts::Source.parse(url)
  end

  @db.set(:sources, clean_sources.map(&:to_h))
end

def index
  @index = {}

  @sources.each do |source|
    Podcasts::Indexer.index!(source).each do |name, results|
      @index[name] ||= []
      @index[name] += results
    end
  end

  @db.set(:index, @index)
end

def search_for_podcaster
  results = @db.find(:index)
    .fetch(@options[:find], [])
    .flatten
    .reject(&:empty?)

  results.each do |result|
    result.each { |k,v| puts "#{k.capitalize}: #{v}" }
    puts ""
  end
end

load_data!
OptionParser.new(&@cli_args_parser_fn).parse! # Parse Command Line options

modify_sources! if @options[:sources]
index if @options[:index]
search_for_podcaster if @options[:find]