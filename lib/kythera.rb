require_relative 'kythera/configuration'

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
end
