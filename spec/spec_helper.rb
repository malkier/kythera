Bundler.require :test

require_relative "../lib/kythera"

MiniTest::Reporters.use! [MiniTest::Reporters::SpecReporter.new]
