# frozen_string_literal: true

require "collateral"
require "redis"

class <%= camel_name %> < Collateral::Pipeline
  def self.root
    @root ||= Pathname(File.expand_path("../../", __FILE__))
  end

  def self.load_config(name)
    file = root.join("config", "#{name}.yml").read
    YAML.safe_load(file)
  end

  def self.logger
    @logger ||= Logger.new(File.expand_path("../../log/<%= snake_name %>.log", __FILE__)).tap do |logger|
      logger.level = Logger::DEBUG
    end
  end

  def self.redis
    @redis ||= Redis.new(load_config("redis")["default"])
  end

<%- actions.each do |action| -%>
  autoload :<%= action.classify %>, "<%= snake_name %>/<%= action %>"
<%- end -%>

<%- actions.each do |action| -%>
  use <%= camel_name %>::<%= action.classify %> # workers: 10, batch_size: 100, progress: true
<%- end -%>

  def setup
    # do some setup
  end
end
