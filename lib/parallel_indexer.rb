module Podcasts
  class ParallelIndexer
    def self.index(sources)
      new.index(sources)
    end

    def index(sources)
      sources_queue, results_queue = Queue.new, Queue.new
    
      sources.each { |s| sources_queue << s }
      num_threads = [sources_queue.size, 4].min

      work_fn = lambda do 
        while source = sources_queue.pop(true) rescue false do
          results_queue << Podcasts::Indexer.index!(source)
        end
      end
    
      num_threads.times.map do 
        Thread.new(&work_fn)
      end.each(&:join)
      
      collect_results(results_queue)
    end

    private

    def collect_results(results_queue)
      index = {}

      while result = results_queue.pop(true) rescue false do
        result.each do |name, results|
          index[name] ||= []
          index[name] += results
        end
      end

      index
    end
  end
end