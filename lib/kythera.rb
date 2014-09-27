# Import required Ruby libs
require 'ostruct'

# Import our files
require_relative 'kythera/configuration'
require_relative 'kythera/uplink'

# Contains all of the application-wide stuff
class Kythera
  # For backwards-incompatible changes
  V_MAJOR = 0

  # For backwards-compatible changes
  V_MINOR = 0

  # For minor changes and bugfixes
  V_PATCH = 1

  # A String representation of the version number
  VERSION = "#{V_MAJOR}.#{V_MINOR}.#{V_PATCH}"

  # Our name for things we print out
  ME = "kythera"

  # Get us up and running!
  def initialize
    puts "#{ME}: version #{VERSION} [#{RUBY_PLATFORM}]"
  end
end
