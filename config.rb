################################################################################
#
# Each section must contain, at minimum:
#   :name - single string.
#
# Each config entry can contain:
#   :enabled - Defaults to true.
#   :os - Either :linux or :osx if this only applies to one OS.
#   :description - Comments (preferably, descriptive ones).
#   :test - Simple command to determine if config should be applied.
#   :paths - an array of paths to add.
#   :aliases - another hash containing key-value (alias-command) pairs.
#   :bashrc - an array of shell code to dump straight into .bashrc.
#   :TODO installation - instructions on how to install if test fails.  Because
#    this is to work with multiple operating systems, usually just a link to
#    the project's web site, unless you're customising this for a single OS,
#    in which case go nuts, and turn it into automatic installation!
#
# Note that if :version is supplied, :version_test MUST be supplied.
# If :version_test is supplied but not :version, it will be ignored.
#
# If both :version and :test are present, both have to pass before the
# entry will be processed.
#
# Paths / Manpaths: note that by default, each path will be exported like so:
#   export PATH='$PATH:{your_path_here}'.
#
# If you want $PATH to appear at the end (or anywhere else), just include it
# in the string, and $PATH will only appear where you specify it.
# Obviously, if you do this multiple time, you'll need to order applications
# in the configuration accordingly.
#
# Note that there is no checking for collisions in aliases.  In fact,
# the 'colorls' config below will override the 'ls' alias defined in
# the 'common aliases' config just because it's processed last when
# Bash reads it's config.  At some point I'll put in a warning when
# that happens...
#
################################################################################

load 'dotgenlib.rb'

################################################################################
# Header/file constants.
################################################################################

@bash_profile = %q(source ~/.profile
source ~/.bashrc
)

@bashrc_load_aliases = %q(# Aliases
if [ -f ~/.aliases ]; then
    source ~/.aliases
fi
)

# Setup bash options
@bash_sanity = %q(# Bash configuration
HISTCONTROL=ignoreboth
HISTSIZE=1000
HISTFILESIZE=2000
shopt -s histappend
shopt -s checkwinsize
)

################################################################################
# Platform and system capabilities.
################################################################################

if RUBY_PLATFORM.include?("linux")
  @os = :linux
elsif RUBY_PLATFORM.include?("openbsd")
  @os = :openbsd
elsif RUBY_PLATFORM.include?("darwin")
  @os = :osx
else
  bail("Cannot determine operating system.")
end

warn "Detected operating System: #{@os}"

################################################################################
# OS specific options.
################################################################################

@ls_color = {:osx     => "-G",
             :linux   => "--color=auto",
             :openbsd => ""}

################################################################################
# Prompt.
################################################################################

@prompt = '\u@\h - \W > '

################################################################################
# Application configuration.
################################################################################

@config = [
  {
    :name => "Common aliases",
    :description => "Avoid common foot-bullets, and generally make the shell nicer.",
    :aliases =>
    {
      :rm => "rm -i",
      :cp => "cp -i",
      :mv => "mv -i",
      :ls => "ls -h #{os_opt(@ls_color)}",
      :grep => "grep --color=auto" # different for OpenBSD?
    }
  },

  {
    :name => "Core utils",
    :os => :osx,
    :description => "Make sure GNU utils appear on the path before OSX ones.",
    :paths => ["/usr/local/opt/coreutils/libexec/gnubin:$PATH"],
    :manpaths => ["/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"]
  },

  {
    :name => "Most",
    :description => "Make man pages prettier.",
    :test => "which most",
    :aliases =>
    {
      :man => "man -P most"
    }
  },

  {
    :name => "Go",
    :enabled => true,
    :description => "Powered by gophers!",
    :paths => ["/usr/local/go/bin",
               "~/go/bin"]
  },

  {
    :name => "Git",
    :test => "which git",
    :description => "Collection of aliases for git.",
    :aliases =>
    {
      :gts => "git status -s -b --column",
      :gtc => "git checkout",
      :gtl => "git log --graph --decorate=full",
      :gtlt => "git log --graph --format=\"%Cgreen %h %p %Cred%d %Cblue%cn - %ar %Creset%s\"",
      :gtb => "git branch -vva",
      :gtp => "git pull --rebase"
    }
  },

  {
    :name => "Flutter",
    :enabled => false,
    :description => "Mobile development for great victory.",
    :paths => ["$HOME/Development/flutter/bin"]
  },

  {
    :name => "Home bin directory",
    :description => "Add user's ~/bin directory to path.",
    :paths => ["~/bin"],
    :test => "[ -d \"$HOME/bin\" ]"
  },

  {
    :name => "CMatrix",
    :test => "which cmatrix",
    :description => "Defaults for cmatrix.",
    :aliases =>
    {
      :cmatrix => "cmatrix -b -u 8 -C blue"
    }
  },

  {
    :name => ".NET Core",
    :test => "which dotnet",
    :description => ".NET Core Framework.",
    :paths => ["~/.dotnet/tools"]
  },

  {
    :name => "Emacs Client",
    :test => "which emacsclient",
    :description => "Alias for Emacs client.",
    :aliases =>
    {
      :em => "emacsclient -t"
    },
    :exports =>
    {
      :EDITOR => "emacsclient -t"
    }
  },

  {
    :name => "pywal",
    :description => "Oh god I've started ricing :-(",
    :comments => "Found in the 'python-pywal' package.
                  Note that still need to call 'wal-R' or 'wal -i path-to-pic'
                  first, in something like the .xinit or bspwm init script.",
    :test => "which wal",
    :bashrc => ["(cat ~/.cache/wal/sequences &)"]
  },

  {
    :name => "Keychain",
    :os => :linux,
    :description => "CLI keychain script for ssh-agent/add.",
    :test => "which keychain",
    :bashrc => ["eval $(keychain --eval --quiet id_rsa)"]
  },

  {
    :name => "ColorLs",
    :os => :openbsd,
    :description => "Color ls output for OpenBSD.",
    :test => "which colorls",
    :aliases =>
    {
      :ls => "colorls -Gh"
    }
  },

  {
    :name => "XDG defaults.",
    :os => :linux,
    :description => "Various ENV variables for XDG.",
    :exports =>
    {
      :XDG_CONFIG_HOME => "/home/matt/.config",
      :XDG_CACHE_HOME  => "/home/matt/.cache",
      :XDG_DATA_HOME   => "/home/matt/.local/share"
    }
  },

  {
    :name => "Libvirt",
    :description => "Makes virt-manager and virsh play nice.",
    :test => "which virsh",
    :exports =>
    {
      :LIBVIRT_DEFAULT_URI => "qemu:///system"
    }
  }
]
