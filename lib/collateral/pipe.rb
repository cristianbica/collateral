require "active_support/core_ext/array"

module Collateral
  class Pipe

    attr :pipeline
    attr :env

    def initialize(pipeline, options)
      @pipeline = pipeline
      @options  = options
      @env = @pipeline.env
    end

    def description
      self.class.name
    end

    def call(messages)
      batches = @options[:batch_size]==0 ? [messages] : messages.in_groups_of(@options[:batch_size])
      logger.debug " Processing #{batches.size} batches with #{@options[:workers]} workers (messages: #{messages.count}, batch size: #{@options[:batch_size]})"
      puts " Processing #{batches.size} batch(es) with #{@options[:workers]} worker(s) (messages: #{messages.count}, batch size: #{@options[:batch_size]})"
      result = nil

      bmr = Benchmark.measure do

        bar = ProgressBar.new("Processing", batches.size) if @options[:progress]
        result = Parallel.map(batches, :in_threads => @options[:workers],
          :start  => ->(item,index) { logger.debug "Start: #{index.inspect}" },
          :finish => ->(item,index, result) {
            logger.debug "Finish: #{index.inspect}"
            bar.inc if @options[:progress]
        }) do |batch|
          batch.compact.map do |data|
            perform(data)
          end
        end
        bar.finish if @options[:progress]
      end
      puts "DONE #{bmr.real.round(4)}s (#{bmr.format('Sys: %0.2ys   User: %0.2us   ChildsSys: %0.2Ys   ChildsUser: %0.2Us   TotalCPU: %0.2t')})"
      logger.debug "DONE #{bmr.real.round(4)}s (#{bmr.format('Sys: %0.2ys   User: %0.2us   ChildsSys: %0.2Ys   ChildsUser: %0.2Us   TotalCPU: %0.2t')})"
      @pipeline.run_next(result.flatten.compact)
    end

    def perform(*args)
      raise "Must be implemented in subclasses"
    end

    def logger
      @pipeline.logger
    end

  end
end
