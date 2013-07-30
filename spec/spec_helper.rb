# SimpleCov is a special case
#require 'simplecov'
#SimpleCov.start

# Import required Ruby libs
require "minitest/autorun"

# Import required gems
Bundler.require :test

# Import our files
require_relative "../lib/kythera"

MiniTest::Reporters.use! [MiniTest::Reporters::SpecReporter.new]

CONFIG_FILE     = File.expand_path("../fixtures/kythera.conf", __FILE__)
BAD_CONFIG_FILE = File.expand_path("../fixtures/kythera-bad.conf", __FILE__)
