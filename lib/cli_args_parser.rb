@cli_args_parser_fn = lambda do |parser|
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
end