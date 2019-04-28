################################################################################
#
# Each section must contain, at minimum:
#   :name - single string.
#
# Each config entry can contain:
#   :enabled - false, otherwise assumed to be true (can omit).
#   :description - comments.
#   :test - simple command to determine if required app is actually installed.
#   :version - semver version; must be exact match.
#   :version_test - command to get the version (i.e. 'git --version')
#   :paths - an array of paths to add.
#   :aliases - another hash containing key-value (alias-command) pairs.
#   :installation - instructions on how to install if test fails.  Because
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
################################################################################

################################################################################
# Header/file constants.
################################################################################

@bash_profile = %q(
source ~/.profile
source ~/.bashrc
)

@bashrc_header = %q(
# Aliases
if [ -f ~/.aliases ]; then
    source ~/.aliases
fi
)

################################################################################
# Platform and system capabilities.
################################################################################

@os = /linux/i =~ RUBY_PLATFORM ? :linux : :osx
@color = (/color/i =~ ENV["TERM"]) != nil

################################################################################
# OS specific options.
################################################################################

@ls_color = {:osx    => "--color=auto",
             :linux  => "-G"}

################################################################################
# Prompt.
################################################################################

@prompt = '\u@\h - \W > '

################################################################################
# Application configuration.
################################################################################

@config =
[
 {
  :name => "Common aliases",
  :description => "Avoid common foot-bullets, and generally make the shell nicer.",
  :aliases =>
    { 
     :rm => "rm -i",
     :cp => "cp -i",
     :mv => "mv -i",
     :ls => "ls -h #{os_opt(@ls_color){@color}}"
    }
 },

 {
   :name => "Core utils.",
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
  :description => "Powered by gophers!",
  :paths => ["/usr/local/go/bin",
             "~/go/bin"]
 },

 {
  :name => "Git",
  :description => "Collection of aliases for git.",
  :aliases =>
    {
     :gts => "git status -s -b --column",
     :gtc => "git checkout",
     :gtl => "git log --graph --decorate=full",
     :gtb => "git branch -vva"
    }
 },

 {
   :name => "Flutter",
   :description => "Mobile development for great victory.",
   :paths => ["$HOME/Development/flutter/bin"]
 }
]
