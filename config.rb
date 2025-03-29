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
## Header/file constants.
#

@bash_profile = <<~BASH_PROFILE
  source ~/.profile
  source ~/.bashrc
BASH_PROFILE

@bashrc_load_aliases = <<~ALIASES
  # Aliases
  if [ -f ~/.aliases ]; then
    source ~/.aliases
  fi
ALIASES

# Setup bash options
@bash_sanity = <<~SANITY
  # Bash configuration
  HISTCONTROL=ignoreboth
  HISTSIZE=1000
  HISTFILESIZE=2000
  shopt -s histappend
  shopt -s checkwinsize
SANITY

################################################################################
## Platform and system capabilities.
#

if RUBY_PLATFORM.include?('linux')
  @os = :linux
elsif RUBY_PLATFORM.include?('openbsd')
  @os = :openbsd
elsif RUBY_PLATFORM.include?('darwin')
  @os = :osx
elsif RUBY_PLATFORM.include?('freebsd')
  @os = :freebsd
else
  bail('Cannot determine operating system.')
end

warn "Detected operating System: #{@os}"

################################################################################
## OS specific options.
#

@ls_color = {
  osx: '-G',
  linux: '--color=auto',
  freebsd: '-G',
  openbsd: ''
}

################################################################################
## Prompt.
#

@prompt = '\u@\h - \W > '

################################################################################
## Application configuration.
#

@config = [
  {
    name: 'Common aliases & shell settings.',
    description: 'Avoid common foot-bullets, and generally make the shell nicer.',
    aliases:
    {
      rm: 'rm -i',
      cp: 'cp -i',
      mv: 'mv -i',
      free: 'free -hm'
    }
  },

  {
    name: 'SystemD aliases',
    description: 'Aliases to make SystemD easier to use.',
    test: 'which systemctl',
    aliases: {
      hostname: 'hostnamectl hostname',
      sd_running: 'systemctl list-unit-files --type=service --state=enabled',
      sd_failed: 'systemctl list-units --type=service --state=failed'
    }
  },

  {
    name: 'Color for basic cli apps.',
    inc_os: [:linux, :freebsd, :osx],
    aliases:
    {
      ls: "ls -p -h --group-directories-first #{os_opt(@ls_color)}",
      grep: 'grep --color=auto'
    }
  },

  {
    name: 'Core utils',
    inc_os: [:osx],
    description: 'Make sure GNU utils appear on the path before OSX ones.',
    paths: ['/usr/local/opt/coreutils/libexec/gnubin:$PATH'],
    manpaths: ['/usr/local/opt/coreutils/libexec/gnuman:$MANPATH']
  },

  {
    name: 'Git',
    test: 'which git',
    description: 'Collection of aliases for git.',
    aliases:
    {
      gts: 'git status -s -b --column --ahead-behind',
      gtc: 'git checkout',
      gtl: 'git log --graph --decorate=full',
      gtlt: "git log --graph --format='%h %p %d %cn - %ar %s'",
      gtb: 'git branch -vva',
      gtp: 'git pull --rebase'
    }
  },

  {
    name: '~/bin directory',
    description: 'Add user\'s ~/bin directory to path.',
    paths: ['~/bin'],
    test: '[ -d "$HOME/bin" ]'
  },

  {
    name: './local/bin directory',
    description: 'Add user\'s ~/.local/bin directory to path.',
    paths: ['~/.local/bin'],
    test: '[ -d "$HOME/.local/bin" ]'
  },

  {
    name: '.NET Core',
    test: 'which dotnet',
    description: '.NET Core Framework.',
    paths: ['~/.dotnet/tools']
  },

  {
    name: 'Emacs Client',
    test: 'which emacsclient',
    description: 'Alias for Emacs client.',
    aliases:
    {
      em: 'TERM=alacritty-direct emacsclient -t'
    },
    exports:
    {
      VISUAL: 'emacsclient -t',
      EDITOR: 'emacsclient -t'
    }
  },

  {
    name: 'Keychain',
    inc_os: [:linux],
    description: 'CLI keychain script for ssh-agent/add.',
    test: 'which keychain',
    profile: ['eval $(keychain --systemd --eval --noask --agents ssh $HOME/.ssh/id_rsa)']
  },

  {
    name: 'Libvirt',
    description: 'Makes virt-manager and virsh play nice.',
    test: 'which virsh',
    exports:
    {
      LIBVIRT_DEFAULT_URI: 'qemu:///system'
    }
  },

  {
    name: 'CFLAGS defaults',
    description: 'The usual defaults.\
      Note: remove -pipe if you want to compile the kernel!',
    exports:
    {
      CFLAGS: '-march=native -O2 -pipe',
      CXXFLAGS: '$CFLAGS',
      MAKEFLAGS: '-j$(nproc)'
    }
  },

  {
    name: 'Bash Completion',
    test: "[[ -f '/usr/share/bash-completion/bash_completion' ]]",
    bashrc: ['source /usr/share/bash-completion/bash_completion']
  },

  {
    name: 'Ardour',
    test: 'which ardour6',
    description: 'Hack to get around long-standing bug in gtk2.',
    exports:
    {
      GTK2_RC_FILES: '/nonexistent'
    }
  },

  {
    name: 'Ruby',
    comments: 'https://felipec.wordpress.com/2022/08/25/fixing-ruby-gems-installation/',
    test: 'which ruby',
    paths: ["#{`ruby -e 'print Gem.user_dir'`}/bin"],
    exports: {
      GEM_HOME: `ruby -e "print Gem.user_dir"`
    }
  },

  {
    name: 'wall',
    description: 'Oh god I\'ve started ricing :-(',
    test: 'which wal',
    bashrc: ['cat ~/.cache/wal/sequences']
  },

  {
    name: 'Starship',
    description: 'Pretty prompt',
    test: 'which starship',
    bashrc: ['if ! [[ $(env | grep TERM) =~ "linux" ]]; ' \
             'then eval $(starship init bash); fi']
  },

  {
    name: 'Bat / Manpager',
    test: 'which batman',
    aliases:
    {
      man: 'batman',
      less: 'bat'
    }
  },

  {
    name: 'FZF',
    test: 'which fzf',
    bashrc: ['eval "$(fzf --bash)"'],
    exports:
    {
      FZF_DEFAULT_OPTS_FILE: '$HOME/.config/fzf/config',
      FZF_CTRL_T_COMMAND: '""'
    }
  },

  {
    name: 'FZF and BAT ingetration.',
    test: 'which bat && which fzf',
    aliases:
    {
      fzf: 'fzf --preview \"bat --line-range=:500 {}\"'
    }
  },

  {
    name: 'Ripgrep',
    exports:
    {
      RIPGREP_CONFIG_PATH: '$HOME/.config/ripgrep/config'
    }
  },

  {
    name: 'Flatpak',
    test: 'which flatpak',
    xdgpaths: ['$HOME/.local/share/flatpak/exports/share',
               '/var/lib/flatpak/exports/share']
  },

  {
    name: 'Golang',
    test: '[ -d "$HOME/go/bin" ]',
    paths: ['$HOME/go/bin']
  }

]
