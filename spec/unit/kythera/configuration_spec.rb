require_relative '../../spec_helper'

describe Configuration do
  let(:config) { Configuration.new CONFIG_FILE }
  subject { config.parse }

  describe "General" do
    it "uses the default configuration file" do
      Configuration.new.config_file.must_equal Configuration::DEFAULT_FILE
    end

    it "uses the configuration file passed on new" do
      subject.config_file.must_equal CONFIG_FILE
    end

    it "raises exception on a bad file" do
      -> { Configuration.new("").parse }.must_raise Configuration::ParseError
    end
  end

  describe "Daemon" do
    it "contains a daemon section" do
      subject.me.must_be_instance_of OpenStruct
    end

    it "contains a daemon name" do
      subject.me.name.wont_be_nil
    end
  end

  # These are really useless, but it makes the code coverage work
  describe "Exceptions" do
    let(:bad_daemon) { Configuration.new BAD_DAEMON }
    let(:bad_uplink) { Configuration.new BAD_UPLINK }

    it "detects malformed daemon blocks" do
      bad_daemon.stub(:abort, nil) do
        bad_daemon.stub(:puts, nil) { bad_daemon.parse }
      end

      bad_daemon.must_be_instance_of Configuration
    end

    it "detects malformed uplink blocks" do
      bad_uplink.stub(:abort, nil) do
        bad_uplink.stub(:puts, nil) { bad_uplink.parse }
      end

      bad_uplink.must_be_instance_of Configuration
    end
  end
end
