require_relative '../../spec_helper'

describe Configuration do
  it "configures itself" do
    must_send [Configuration, "load_configuration"]

    Configuration.load_configuration
  end
end
