require_relative '../spec_helper'

describe Kythera do
  before do
    @kythera = nil
  end

  it "starts up" do
    @kythera.stub(:puts, nil) do
      @kythera = Kythera.new
    end

    @kythera.must_be_instance_of Kythera
  end
end
