################################################################################
#
# Each section must contain, at minimum:
#   :name - single string.
#
# Each config entry can contain:
#   :enabled - Defaults to true.
#   :inc_os - An array of [:linux, :osx] etc, if this only applies to given OSs.
#   :exc_os - An array of [:linux, :openbsd] etc, if this should be excluded from an os.
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
# ToDo - actually impliment versioning in the next version :-)
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
elsif RUBY_PLATFORM.include?("freebsd")
  @os = :freebsd
else
  bail("Cannot determine operating system.")
end

warn "Detected operating System: #{@os}"

################################################################################
# OS specific options.
################################################################################

@ls_color = {
  :osx     => "-G",
  :linux   => "--color=auto",
  :freebsd => "-G",
  :openbsd => ""
}

################################################################################
# Prompt.
################################################################################

@prompt = '\u@\h - \W > '

################################################################################
# Application configuration.
################################################################################

@config = [
  {
    :name => "Common aliases & shell settings.",
    :description => "Avoid common foot-bullets, and generally make the shell nicer.",
    :aliases =>
    {
      :rm => "rm -i",
      :cp => "cp -i",
      :mv => "mv -i",
    }
  },

  {
    :name => "SystemD aliases",
    :description => "Aliases so that SystemD looks a bit more posixy and is easier to use.",
    :aliases => {
      :hostname => "hostnamectl hostname",
      :sd_running => "systemctl list-unit-files --type=service --state=enabled",
      :sd_failed => "systemctl list-units --type=service  --state=failed"
    }
  },

  {
    :name => "Color for basic cli apps.",
    :inc_os => [:linux, :freebsd, :osx],
    :aliases =>
    {
      :ls => "ls -h --group-directories-first #{os_opt(@ls_color)}",
      :grep => "grep --color=auto"
    }
  },

  {
    :name => "ColorLs",
    :inc_os => [:openbsd],
    :description => "Color ls output for OpenBSD.",
    :test => "which colorls",
    :aliases =>
    {
      :ls => "colorls -Gh"
    }
  },

  {
    :name => "Core utils",
    :inc_os => [:osx],
    :description => "Make sure GNU utils appear on the path before OSX ones.",
    :paths => ["/usr/local/opt/coreutils/libexec/gnubin:$PATH"],
    :manpaths => ["/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"]
  },

  {
    :name => "Most",
    :enabled => false,
    :description => "Make man pages prettier.",
    :inc_os => [:linux],
    :test => "which most",
    :alias =>
    {
      :less => "most"
    },
    :exports =>
    {
      :PAGER => "most"
    }
  },

  {
    :enabled => true,
    :name => "MOAR",
    :test => "which moar",
    :description => "'less/more', but with syntax-highlighting.",
    :exports =>
    {
      :PAGER => "moar --colors 16M --no-linenumbers",
      :MOAR => "--colors 16M --no-linenumbers"
    },
    :aliases =>
    {
      :less => "moar",
      :more => "moar"
    },
  },

  {
    :enabled => false,
    :name => "Go",
    :test => "which go",
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
      :gtlt => "git log --graph --format='%h %p %d %cn - %ar %s'",
      :gtb => "git branch -vva",
      :gtp => "git pull --rebase"
    }
  },

  {
    :name => "~/bin directory",
    :description => "Add user's ~/bin directory to path.",
    :paths => ["~/bin"],
    :test => "[ -d \"$HOME/bin\" ]"
  },

  {
    :name => "~./local/bin directory",
    :description => "Add user's ~/bin directory to path.",
    :paths => ["~/.local/bin"],
    :test => "[ -d \"$HOME/.local/bin\" ]"
  },

  {
    :enabled => false,
    :name => "CMatrix",
    :test => "which cmatrix",
    :description => "Defaults for cmatrix.",
    :aliases =>
    {
      :cmatrix => "cmatrix -b -u 8 -C blue"
    }
  },

  {
    :enabled => false,
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
    :comments => "Found in the 'python-pywal' package.",
    :profile => [# "if [ -e ~/.cache/wal ]; then rm -rf ~/.cache/wal; fi",
      "wal -i ~/Pictures/Wallpapers/current"],
    :test => "which wal",
    :bashrc => ["(cat ~/.cache/wal/sequences &)"],
  },

  {
    :name => "Keychain",
    :inc_os => [:linux],
    :description => "CLI keychain script for ssh-agent/add.",
    :test => "which keychain",
    :bashrc => ["eval $(keychain --eval --quiet --noask id_rsa)"]
  },

  {
    :name => "Libvirt",
    :description => "Makes virt-manager and virsh play nice.",
    :test => "which virsh",
    :exports =>
    {
      :LIBVIRT_DEFAULT_URI => "qemu:///system"
    }
  },

  {
    :enabled => false,
    :name => "Flutter",
    :test => "which flutter",
    :description => "Mobile development for great victory.",
    :paths => ["/opt/flutter/bin/cache/dart-sdk/bin/"],
    :aliases =>
    {
      :das => "dart /opt/flutter/bin/snapshots/analysis_server.dart.snapshot --lsp"
    },
    :exports =>
    {
      :DART_SDK => "/opt/flutter/bin/cache/dart-sdk/",
      :FLUTTER_ROOT => "/opt/flutter"
    }
  },

  {
    :enabled => false,
    :name => "Kvantum",
    :description => "The bloody lengths I go to, to get virt-manager looking nice.",
    :test => "which kvantum",
    :exports =>
    {
      :QT_STYLE_OVERRIDE => "kvantum"
    }
  },

  {
    :name => "CFLAGS defaults",
    :description => "The usual defaults." +
                    "Note: remove -pipe if you want to compile the kernel...",
    :exports =>
    {
      :CFLAGS => "-march=native -O2 -pipe",
      :CXXFLAGS => "$CFLAGS",
      :MAKEFLAGS => "-j$(nproc)"
    }
  },

  {
    :enabled => false,
    :name => "Sakura colours",
    :description => "Allows Emacs to use true-colour in terminal.",
    :test => "which sakura",
  },

  {
    :name => "Bash Completion",
    :test => "[[ -f '/usr/share/bash-completion/bash_completion' ]]",
    :bashrc => ["source /usr/share/bash-completion/bash_completion"]
  },

  {
    :name => "Ardour",
    :test => "which ardour6",
    :description => "Hack to get around long-standing bug in gtk2.",
    :exports =>
    {
      :GTK2_RC_FILES => "/nonexistent"
    }
  },

  {
    :name => "Neofetch",
    :description => "Screen info tool, required for ricing.",
    :aliases =>
    {
      :neofetch => "neofetch --backend off --color_blocks off --title_fqnm off"
    }
  },

  {
    :name => "Styling",
    :enabled => true,
    :test => "which qt6ct",
    :exports =>
    {
      :comment => "Mostly using GTK3/4 apps, but Zeal is QT6.",
      :QT_QPA_PLATFORMTHEME => "qt6ct",
      :GTK2_RC_FILES => "/usr/share/themes/gnome-professional/gtk-2.0/gtkrc"
    }
  }
]
