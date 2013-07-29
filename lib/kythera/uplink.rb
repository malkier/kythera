class Uplink
  attr_reader :config

  def initialize(config)
    @config    = config
    @connected = false
    @socket    = nil
  end

  public

  def connected?
    @connected
  end

  def connect(socket = nil)
    if not @socket
      begin
        @socket = TCPSocket.new(@config.host, @config.port)
      rescue Exception => err
        raise DisconnectedError, err
      else
        @connected = true
      end
    end

    @socket = socket if socket

    self
  end

  def read
    begin
      data = @socket.read_nonblock 8192
    rescue IO::WaitReadable
      return
    rescue Exception => err
      raise DisconnectedError, err
    end

    raise DisconnectedError, "empty read" if not data or data.empty?

    data
  end

  class DisconnectedError < Exception
  end
end
