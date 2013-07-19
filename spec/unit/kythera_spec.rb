require_relative '../spec_helper'

describe Kythera do
  before do
    @kythera = Minitest::Mock.new
  end

  it "has the correct version number" do
    Kythera::VERSION.must_equal "0.0.1"
    @kythera.expect :some_meth, "return value"
    @kythera.some_meth
    @kythera.verify
  end

  it "knows its name" do
    Kythera::ME.must_equal "kythera" 
  end
end
