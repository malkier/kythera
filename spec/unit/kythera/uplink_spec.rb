require_relative '../../spec_helper'

describe Uplink do
  let(:config) { Configuration.new(CONFIG_FILE).parse }
  let(:socket) { MiniTest::Mock.new }

  subject { Uplink.new config.uplinks.first }

  describe "Configuration" do
    it "has an address" do
      subject.config.host.must_equal "irc.malkier.net"
    end

    it "has a port" do
      subject.config.port.must_equal 6667
    end

    it "has a send password" do
      subject.config.send_password.must_equal "send_linkage"
    end

    it "has a receive password" do
      subject.config.receive_password.must_equal "receive_linkage"
    end

    it "has an SID" do
      subject.config.sid.must_equal "KS0"
    end
  end

  describe "IRC Connection" do
    let(:read_ret)   { "PASS #{subject.config.receive_password} TS 6 :777\r\n" }
    let(:write_line) { "PASS #{subject.config.send_password} TS 6 :777\r\n"    }

    let(:broken_read_1) { ":malkier NOTICE rakaur :you" }
    let(:broken_read_2) { "'re fucking awesome\r\n" }

    before { subject.connect socket }

    it "connects to the IRC server" do
      subject.connected?.must_equal true
    end

    it "reads from the IRC server" do
      socket.expect(:read_nonblock, read_ret, [Integer])

      data = subject.read
      data.must_equal read_ret

      socket.verify
    end

    it "read correctly assembles incomplete lines" do
      socket.expect(:read_nonblock, broken_read_1, [Integer])
      socket.expect(:read_nonblock, broken_read_2, [Integer])
      socket.expect(:read_nonblock, "\n",          [Integer])

      subject.read
      subject.recvq.must_equal [broken_read_1]

      # Stub #parse here or it would wipe out @recvq
      subject.stub(:parse, nil) { subject.read }
      subject.recvq.must_equal [broken_read_1 + broken_read_2]

      # Now actually test that #parse wiped out @recvq
      subject.read
      subject.recvq.must_be_empty

      socket.verify
    end

    it "writes to the IRC server" do
      socket.expect(:write_nonblock, write_line.size, [write_line])
      written = subject.write write_line.chomp

      written.must_equal write_line.length

      socket.verify
    end
  end

  describe "Parser" do
    let(:data) do
      "PASS #{subject.config.receive_password} TS 6 :777\r\n" +
      ":origin COMMAND target :free form text\r\n" +
      "COMMAND target :free form text\r\n" +
      ":origin COMMAND :free form text\r\n"
    end

    let(:parsed_data) do
      [
        [nil, "PASS", [subject.config.receive_password, "TS", "6", "777"]],
        ["origin", "COMMAND", ["target", "free form text"]],
        [nil, "COMMAND", ["target", "free form text"]],
        ["origin", "COMMAND", ["free form text"]]
      ]
    end

    before { subject.connect socket }

    it "parses IRC data into parv" do
      socket.expect(:read_nonblock, data, [Integer])

      subject.read

      parsed_data.must_equal parsed_data

      socket.verify
    end
  end

  describe "Exceptions" do
    it "raises an exception when unable to connect" do
      subject.config.host = "127.0.0.1"
      subject.config.port = 1

      -> { subject.connect }.must_raise Uplink::DisconnectedError
    end

    it "raises an exception when unable to read" do
      def socket.read_nonblock(*args)
        raise
      end

      subject.connect socket

      -> { subject.read }.must_raise Uplink::DisconnectedError
    end

    it "raises an exception when read returns nil" do
      socket.expect(:read_nonblock, nil, [Integer])

      subject.connect socket

      -> { subject.read }.must_raise Uplink::DisconnectedError

      socket.verify
    end

    it "gracefully returns when reading would block" do
      def socket.read_nonblock(*args)
        raise TestWaitReadable
      end

      subject.connect socket

      subject.read.must_be_nil
    end

    it "raises an exception when unable to write" do
      def socket.write_nonblock(*args)
        raise
      end

      subject.connect socket

      -> { subject.write "test" }.must_raise Uplink::DisconnectedError
    end

    it "gracefully returns when writing would block" do
      def socket.write_nonblock(*args)
        raise TestWaitWritable
      end

      subject.connect socket

      subject.write("test").must_be_nil
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
