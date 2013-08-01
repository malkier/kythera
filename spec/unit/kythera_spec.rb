require_relative '../spec_helper'

describe Kythera do
  let(:output) { MiniTest::Mock.new }

  subject { Kythera.new output }

  it "starts up" do
    output.expect(:puts, nil, [String])

    subject.must_be_instance_of Kythera

    output.verify
  end
end
