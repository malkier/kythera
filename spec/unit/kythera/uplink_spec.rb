require_relative '../../spec_helper'

describe Uplink do
  before do
    @config = Configuration.new CONFIG_FILE
    @config = @config.parse

    @uplink = Uplink.new @config.uplinks.first
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

    it "has an SID" do
      @uplink.config.sid.must_equal "KS0"
    end
  end

  describe "IRC Connection" do
    before do
      @read_return = "PASS #{@uplink.config.receive_password} TS 6 :777\r\n"
      @write_line  = "PASS #{@uplink.config.send_password} TS 6 :777\r\n"

      @socket = MiniTest::Mock.new
      @uplink.connect @socket
    end

    it "connects to the IRC server" do
      @uplink.connected?.must_equal true
    end

    it "reads from the IRC server" do
      @socket.expect(:read_nonblock, @read_return, [8192])

      data = @uplink.read
      data.must_equal @read_return

      @socket.verify
    end

    it "writes to the IRC server" do
      @socket.expect(:write_nonblock, @write_line.size, [@write_line])
      written = @uplink.write @write_line.chomp

      written.must_equal @write_line.length

      @socket.verify
    end
  end

  describe "Exceptions" do
    it "raises an exception when unable to connect" do
      @uplink.config.host = "127.0.0.1"
      @uplink.config.port = 1

      -> { @uplink.connect }.must_raise Uplink::DisconnectedError
    end

    it "raises an exception when unable to read" do
      @socket = MiniTest::Mock.new

      def @socket.read_nonblock(*args)
        raise
      end

      @uplink.connect @socket

      -> { @uplink.read }.must_raise Uplink::DisconnectedError
    end

    it "raises an exception when read returns nil" do
      @socket = MiniTest::Mock.new
      @socket.expect(:read_nonblock, nil, [8192])

      @uplink.connect @socket

      -> { @uplink.read }.must_raise Uplink::DisconnectedError

      @socket.verify
    end

    it "gracefully returns when reading would block" do
      @socket = MiniTest::Mock.new

      def @socket.read_nonblock(*args)
        raise TestWaitReadable
      end

      @uplink.connect @socket

      @uplink.read.must_be_nil
    end

    it "raises an exception when unable to write" do
      @socket = MiniTest::Mock.new

      def @socket.write_nonblock(*args)
        raise
      end

      @uplink.connect @socket

      -> { @uplink.write "test" }.must_raise Uplink::DisconnectedError
    end

    it "gracefully returns when writing would block" do
      @socket = MiniTest::Mock.new

      def @socket.write_nonblock(*args)
        raise TestWaitWritable
      end

      @uplink.connect @socket

      @uplink.write("test").must_be_nil
    end
  end
end

# We can't raise IO::WaitReadable/Writable because they're Modules
class TestWaitReadable < Exception
  include IO::WaitReadable
end

class TestWaitWritable < Exception
  include IO::WaitWritable
end
