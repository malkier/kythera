class Uplink
  # An exception we raise when disconnected
  class DisconnectedError < Exception
  end

  attr_reader :config, :recvq

  def initialize(config)
    @config    = config
    @connected = false
    @recvq     = []
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

  # Matches CR or LF
  CR_OR_LF = /\r|\n/

  def read
    begin
      data = @socket.read_nonblock 8192
    rescue IO::WaitReadable
      return # Will go back to select and try again
    rescue Exception => err
      raise DisconnectedError, err
    end

    raise DisconnectedError, "empty read" if not data or data.empty?

    # Passes every "line" to the block, including "\n"
    data.scan /(.+\n?)/ do |line|
      line = line.first

      # If the last line had no \n, add this one onto it.
      if @recvq[-1] and @recvq[-1][-1] !~ CR_OR_LF
        @recvq[-1] += line
      else
        @recvq << line
      end
    end

    if @recvq[-1] and @recvq[-1][-1] == "\n"
      parse(@recvq)
    end

    data
  end

  def write(line)
    line += "\r\n"

    begin
      written = @socket.write_nonblock(line)
    rescue IO::WaitWritable
      return # Will go back to select and try again
    rescue Exception => err
      raise DisconnectedError, err
    end

    written
  end

  private

  # Removes the first character from a string
  NO_COL = 1 .. -1

  # Because String#split treats ' ' as /\s/ for some reason
  # XXX - This sucks; it slows down the parser by quite a lot
  RE_SPACE = / /

  # Parses incoming IRC data and sends it off to protocol-specific handlers
  def parse(lines)
    while line = lines.shift
      line.chomp!

      # don't do anything if the line is empty
      next if line.empty?

      if line[0] == ":"
        # Remove the origin from the line, and eat the colon
        origin, line = line.split(RE_SPACE, 2)
        origin = origin[NO_COL]
      else
        origin = nil
      end

      tokens, args = line.split(" :", 2)
      parv = tokens.split(RE_SPACE)
      cmd  = parv.delete_at(0)
      parv << args unless args.nil?

      [origin, cmd, parv]

      # # Downcase it and turn it into a Symbol
      # cmd = "irc_#{cmd.to_s.downcase}".to_sym
      #
      # # Call the protocol-specific handler
      # if self.respond_to?(cmd, true)
      #     self.send(cmd, origin, parv)
      # else
      #     $log.debug "no protocol handler for #{cmd.to_s.upcase}"
      # end
    end
  end
end
