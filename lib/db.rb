require 'pstore'

module Podcasts
  class DB
    FILE_PATH = "data.pstore"

    def self.default
      new(FILE_PATH)
    end

    def initialize(file_path)
      @file_path = file_path
    end

    def find(key)
      pstore.transaction { pstore[key] }
    end

    def fetch(key, &block) # Like Hash#fetch
      find(key) || (block.call if block_given?)
    end

    def set(key, value)
      pstore.transaction { pstore[key] = value }
    end

    private

    def pstore
      @db ||= PStore.new(@file_path)
    end
  end
end