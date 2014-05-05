module Collateral
  class Pipe

    def initialize(pipeline, options)
      @pipeline = pipeline
      @options  = options
    end

    def description
      self.class.name.underscore.humanize
    end

    def call(messages)
      batches = @options[:batch_size]==0 ? [messages] : messages.in_groups_of(@options[:batch_size])
      logger.info " Processing #{batches.size} batches with #{@options[:workers]} workers (messages: #{messages.count}, batch size: #{@options[:batch_size]})"
      puts " Processing #{batches.size} batch(es) with #{@options[:workers]} worker(s) (messages: #{messages.count}, batch size: #{@options[:batch_size]})"
      result = nil

      bmr = Benchmark.measure do

        bar = ProgressBar.new("Processing", batches.size) if @options[:progress]
        result = Parallel.map(batches, :in_threads => @options[:workers],
          :start  => ->(item,index) { logger.info "Start: #{index.inspect}" },
          :finish => ->(item,index) {
            logger.info "Finish: #{index.inspect}"
            #bar.increment if @options[:progress]
            #bar.increment! if @options[:progress]
            bar.inc if @options[:progress]
            #print "\r"; n+=1; print "#{n} of #{batches.size} done"
          }
          ) do |batch|
          batch.compact.each do |data|
            perform(data)
          end
        end
        bar.finish if @options[:progress]

      end

      puts "DONE #{bmr.real.round(4)}s (#{bmr.format('Sys: %0.2ys   User: %0.2us   ChildsSys: %0.2Ys   ChildsUser: %0.2Us   TotalCPU: %0.2t')})"
      puts ""
      logger.info "DONE #{bmr.real.round(4)}s (#{bmr.format('Sys: %0.2ys   User: %0.2us   ChildsSys: %0.2Ys   ChildsUser: %0.2Us   TotalCPU: %0.2t')})"
      @pipeline.run_next(result.flatten(1).compact)
    end

    def perform(*args)
      raise "Must be implemented in subclasses"
    end

    def logger
      PlacesManager.logger
    end


  end
end
