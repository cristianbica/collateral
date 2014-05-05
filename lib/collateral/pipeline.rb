require 'parallel'
require 'benchmark'

module Collateral
  class Pipeline

    attr :env

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
      b = Benchmark.measure do
        run_next([{}])
      end
      puts "DONE #{b.real.round(4)}s\n"
    end

    def name
      self.class.name.underscore.split("/").last.humanize.upcase
    end

    def run_next(messages)
      next_pipe = pipes.shift
      if next_pipe
        @step += 1
        puts "Starting pipe #{@step}: #{next_pipe.description}"
        logger.info "Starting pipe #{@step}: #{next_pipe.description}"
        next_pipe.call(messages)
      else
        logger.info "ALL PIPES DONE"
      end
    end

    private
    def reset_state
      @pipes = nil
      @env = {}
    end

    def pipes
      @pipes ||= self.class.stack.map do |pipe|
        pipe.first.new(self, {workers: 1, batch_size: 0, progress: false}.merge(step.pipe))
      end
    end

    def logger
      self.class.logger
    end

  end
end
