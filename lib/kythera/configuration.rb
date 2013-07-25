class Configuration
  attr_reader :config_file

  DEFAULT_FILE = File.expand_path("../../etc/kythera.conf", __FILE__)

  def initialize(file = nil)
    @config_file = file ? file : DEFAULT_FILE
    @config = Object.new
    @config.extend Configuration::DSL
  end

  public

  def parse
    @config.config_file = @config_file

    begin
      file = File.read(@config_file)
    rescue Exception => e
      raise Configuration::ParseError
    end

    # The configuration magic begins here...
    error = catch(:error) { @config.instance_eval(file) }

    if error.kind_of?(Exception)
      puts 'kythera: error loading configuration:'
      puts "\t#{error}"

      line = error.backtrace[1].split(':')[1]

      puts "\t\t#{$0}:#{line}"

      abort
    end

    @config
  end
end

module Configuration::DSL
  attr_accessor :config_file, :me

  def daemon(&block)
    @me = OpenStruct.new
    @me.extend(Configuration::DSL::Daemon)

    begin
      @me.instance_eval(&block)
    rescue Exception => err
      throw :error, err
    end
  end
end

module Configuration::DSL::Daemon
  private

  def name(name)
    self.name = name
  end
end

class Configuration::ParseError < Exception
end
