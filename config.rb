################################################################################
#
# Each section must contain, at minimum:
#   :name - single string.
#
# Each config entry can contain:
#   :description - basically just comments, currently not used.
#   :test - simple command to determine if required app is actually installed.
#   :paths - an array of paths to add.
#   :aliases - another hash containing key-value (alias-command) pairs.
#   :installation - instructions on how to install if test fails

################################################################################

@config = [
  {
    :name => "Common aliases",
    :description => "Just a few safety features to avoid the more common foot-bullets, and stuff to make the shell nicer.",
    :aliases => { 
      :rm => "rm -i",
      :cp => "cp -i",
      :mv => "mv -i",
      :ls => "ls -l -#{os_opt(@ls_color){@color}}"
    }
  },

  {
    :name => "Most",
    :description => "Make man pages prettier.",
    :aliases => {
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
    :aliases => {
      :gts => "git status -s -b --column",
      :gtc => "git checkout",
      :gtl => "git log --graph --decorate=full",
      :gtb => "git branch -vva"
    }
  }
]
