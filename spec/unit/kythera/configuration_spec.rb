require_relative '../../spec_helper'

describe Configuration do
  before do
    @config = Configuration.new CONFIG_FILE
    @config = @config.parse
  end

  describe "General" do
    it "uses the default configuration file" do
      Configuration.new.config_file.must_equal Configuration::DEFAULT_FILE
    end

    it "uses the configuration file passed on new" do
      @config.config_file.must_equal CONFIG_FILE
    end

    it "raises exception on a bad file" do
      -> { Configuration.new("").parse }.must_raise Configuration::ParseError
    end
  end

  describe "Daemon" do
    it "contains a daemon section" do
      @config.me.must_be_instance_of OpenStruct
    end

    it "contains a daemon name" do
      @config.me.name.wont_be_nil
    end
  end
end
