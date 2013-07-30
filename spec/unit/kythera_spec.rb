require_relative '../spec_helper'

describe Kythera do
  it "has the correct version number" do
    Kythera::VERSION.must_equal "0.0.1"
  end

  it "knows its name" do
    Kythera::ME.must_equal "kythera"
  end

  it "starts up" do
    str = "#{Kythera::ME}: version #{Kythera::VERSION} [#{RUBY_PLATFORM}]"

    output = MiniTest::Mock.new
    output.expect(:puts, nil, [str])

    k = Kythera.new output
    k.must_be_instance_of Kythera

    output.verify
  end
end
