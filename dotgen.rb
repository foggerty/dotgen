# What I want here, is a data structure representing what config I
# need (global or individual apps), and the code will then split it
# out into the three files:
#
# .aliases
# .bashrc
# .profile
#
# The aim is to totally avoid ANY conditional logic in the bash files,
# meaning that colour/platform detection etc happen here, mainly
# because a) I loathe bash scripting and b) I loathe bash scripting,
# and c) to ensure that I get as close to identical environments when
# I move between machines.  I also want to be able to specify what an
# application needs, and have this script decide where the various
# bits of configuration go.

# .profile - used by many shells.  Put one-time setup stuff here
# (environment variables, paths etc).
#
# .bashrc - bash-specific configuration (aliases etc)
#
# .bash_profile - bash's version of .profile.  This should source
# .profile and .bashrc (in that order!) and nothing else.


bash_profile = %q(
source .profile
source .bashrc
)

bashrc_header = %q(
# Aliases
source .aliases
)

################################################################################
# Determine system capabilities.
################################################################################

os = /linux/ =~ RUBY_PLATFORM ? :linux : :osx
color = (/color/ =~ ENV["TERM"]) != nil

################################################################################
# OS specific options
################################################################################

ls_color = {:linux => "--color=auto",
            :osx   => "-G"}

################################################################################
# Common/shared config.
################################################################################

common_aliases = {
  :rm => "rm -i",
  :cp => "cp -i",
  :mv => "mv -i",
  :ls => "ls -l #{os_opt(ls_color)}"
}

################################################################################
# Helper functions.
################################################################################

def os_opt(options)
  result = options[os]

  raise 'os_opt - options does not contain a recognised OS symbol.' if result == nil

  result
end

