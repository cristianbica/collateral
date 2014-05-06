require 'parallel'
require 'benchmark'
require 'logger'
require 'progressbar'

module Collateral
  class Pipeline

    attr :env
    attr :logger

    class << self

      def stack
        @stack ||= []
      end

      def use(pipeline_action_class, options={})
        stack << [pipeline_action_class, options]
      end

      def logger
        @logger ||= Logger.new(STDOUT)
      end
    end

    def initialize(*args)
      @options = args.last.is_a?(Hash) ? args.pop : {}
      @data    = args
    end

    def start
      reset_state
      puts "Starting pipeline #{name}"
      logger.debug "-"*80
      logger.debug "Starting pipeline #{name}"
      setup
      b = Benchmark.measure do
        run_next(@data)
      end
      puts "DONE #{b.real.round(4)}s\n"
      logger.debug "DONE #{b.real.round(4)}s\n"
    end

    def setup
    end

    def name
      self.class.name
    end

    def run_next(messages)
      next_pipe = pipes.shift
      if next_pipe
        @step += 1
        puts "Starting pipe #{@step}: #{next_pipe.description}"
        logger.debug "Starting pipe #{@step}: #{next_pipe.description}"
        next_pipe.call(messages)
      else
        logger.debug "ALL PIPES DONE"
      end
    end

    def logger
      self.class.logger
    end

    private
    def reset_state
      @pipes = nil
      @env = {}
      @env[:session] = self.class.name.underscore.split("/").last + "_" + SecureRandom.hex(8)
      @step = 0
    end

    def pipes
      @pipes ||= self.class.stack.map do |pipe|
        pipe.first.new(self, {workers: 1, batch_size: 0, progress: false}.merge(pipe.last))
      end
    end

  end
end
