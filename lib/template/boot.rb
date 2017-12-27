# frozen_string_literal: true

require "rubygems"
require "bundler"

ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __FILE__)
require "bundler/setup" if File.exist?(ENV["BUNDLE_GEMFILE"])
Bundler.setup

$LOAD_PATH << File.expand_path("../lib", __FILE__)
