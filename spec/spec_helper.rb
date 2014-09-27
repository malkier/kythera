# Code-coverage utilites
require 'simplecov'
SimpleCov.start do
  add_filter '/.bundle/'
end

require 'coveralls'
Coveralls.wear!

# Import required Ruby libs
require "minitest/autorun"

# Import required gems
Bundler.require :test

# Import our files
require_relative "../lib/kythera"

MiniTest::Reporters.use! [MiniTest::Reporters::SpecReporter.new]

CONFIG_FILE  = File.expand_path("../fixtures/kythera.conf",    __FILE__)
BAD_DAEMON   = File.expand_path("../fixtures/bad-daemon.conf", __FILE__)
BAD_UPLINK   = File.expand_path("../fixtures/bad-uplink.conf", __FILE__)
