Bundler.require :test

require_relative "../lib/kythera"

MiniTest::Reporters.use! [MiniTest::Reporters::SpecReporter.new]

CONFIG_FILE = File.expand_path("../fixtures/kythera.conf", __FILE__)
