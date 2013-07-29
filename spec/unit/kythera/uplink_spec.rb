require_relative '../../spec_helper'

describe Uplink do
  before do
    @config = Configuration.new CONFIG_FILE
    @config = @config.parse

    @uplink = Uplink.new(@config.uplinks.first)
  end

  describe "Configuration" do
    it "has an address" do
      @uplink.config.host.must_equal "irc.malkier.net"
    end

    it "has a port" do
      @uplink.config.port.must_equal 6667
    end

    it "has a send password" do
      @uplink.config.send_password.must_equal "send_linkage"
    end

    it "has a receive password" do
      @uplink.config.receive_password.must_equal "receive_linkage"
    end
  end

  describe "IRC Connection" do
    before do
      @read_return = "PASS #{@uplink.config.receive_password} TS 6 :777\r\n"

      @socket = MiniTest::Mock.new
      @socket.expect(:read_nonblock, @read_return, [8192])
    end

    it "isn't connected yet" do
      @uplink.connected?.must_equal false
    end

    it "connects to the IRC server" do
      @uplink.connect(@socket)
      @uplink.connected?.must_equal true
    end

    it "reads from the IRC server" do
      @uplink.connect(@socket)
      data = @uplink.read
      data.must_equal @read_return

      @socket.verify
    end
  end
end
