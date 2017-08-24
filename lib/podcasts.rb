module Podcasts
  Version = "0.1.0"

  require_relative 'cli_args_parser'
  require_relative 'db'
  require_relative 'indexer'
  require_relative 'name_parser'
  require_relative 'source'
end