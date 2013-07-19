require_relative '../spec_helper'

describe Configuration do
  it "configures itself" do
    Configuration.load!
  end
end
