# frozen_string_literal: true

require "collateral/pipe"

class <%= camel_name %>::<%= config[:action].classify %> < Collateral::Pipe
  delegate :redis, to: <%= camel_name %>

  def perform(record)
    # process one record at a time (possible in parallel)
  end

  # def call(records)
  #   # process all records in one step
  # end
end
