################################################################################
# bash_profile and headers.
################################################################################

bash_profile = %q(
source .profile
source .bashrc
)

bashrc_header = %q(
# Aliases
source .aliases
)

################################################################################
# Determine platform and system capabilities.
################################################################################

@os = /linux/ =~ RUBY_PLATFORM ? :linux : :osx
@color = (/color/ =~ ENV["TERM"]) != nil

################################################################################
# OS specific options
################################################################################

@ls_color = {:linux => "--color=auto",
            :osx   => "-G"}

################################################################################
# Prompt - for your customisation pleasure.
################################################################################

@prompt = "(\\j) \\w : \\u > "

################################################################################
# Helper functions.
################################################################################

# Will look up the OS specific option in hash 'options'.  Note that if
# this method is called, 'options' MUST contain a matching key.  If a
# block is provided, and it returns anything other than true, will
# return the empty string.

def os_opt(options)
  if block_given? & !yield
    retun ""
  end
  
  result = options[@os]

  if result == nil
    raise 'os_opt - options does not contain a recognised OS symbol.' 
  end
  
  result
end

################################################################################
# Load in the config.  This happens here, because it uses
# interpolation of a few variables and functions defined in this file.
################################################################################

load './config.rb'

################################################################################
# Work happens here.
################################################################################

# First, sanity check the inputs!

@config.each do |cfg|
  # Must be a hash
  raise "Each entry in config must be a hash." if cfg.class != Hash

  # Must have a name
  raise "Each entry must have a name." if cfg[:name] == nil

  # Aliases must be a hash, if present
  if cfg[:aliases != nil] && cfg[:ailases].class != Hash
    raise "Aliases must be a hash in entry #{cfg[:name]}."
  end

  # Paths must be an array of strings
  if cfg[:paths] != nil && cfg[:paths].class != Array
    raise "Paths must be an array of string in entry #{cfg[:name]}."
  end
end

# Next, output to temporary files.

aliases = []

@config.each do |cfg|
  if cfg[:aliases]

    aliases << "# #{cfg[:name]}"

    cfg[:aliases].each do |a, c|
      aliases << "#{a}='#{c}'"
    end

    aliases << ""
  end
end

puts aliases

# Finally, ask user if they want to overwrite their current dot files.
