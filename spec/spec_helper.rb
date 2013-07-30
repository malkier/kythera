# SimpleCov is a special case
#require 'simplecov'
#SimpleCov.start

Bundler.require :test

require_relative "../lib/kythera"

MiniTest::Reporters.use! [MiniTest::Reporters::SpecReporter.new]

CONFIG_FILE     = File.expand_path("../fixtures/kythera.conf", __FILE__)
BAD_CONFIG_FILE = File.expand_path("../fixtures/kythera-bad.conf", __FILE__)
