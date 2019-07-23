load './dotGenLib.rb'
load './config.rb'

@aliases = []
@paths = []
@manpaths = []
@bashrc = []

################################################################################
## Setup and sanity check
################################################################################

@config.filter! do |cfg|
  
  valid =
    isConfig(cfg) &&
    isCorrectType(cfg, :aliases, Hash) &&
    isCorrectType(cfg, :paths, Array) &&
    isCorrectType(cfg, :manpaths, Array) &&
    isCorrectType(cfg, :test, String)

  valid && runTest(cfg)
end

if @config.length == 0
  puts "Either all config is disabled, or none of it applies to this OS."
  exit 0
end

@aliases = @config.
             filter {|cfg| cfg[:aliases] != nil}.
             map {|cfg| extractAliases(cfg)}.
             flatten

@paths = @config.
           filter {|cfg| cfg[:paths] != nil}.
           map {|cfg| extractPaths(cfg, :paths, "PATH")}.
           flatten

@manpaths = @config.
              filter {|cfg| cfg[:manpaths] != nil}.
              map {|cfg| extractPaths(cfg, :manpaths, "MANPATH")}.
              flatten

@bashrc << @bash_sanity
@bashrc << @bashrc_aliases
@bashrc << "# Prompt"
@bashrc << "PS1=\"#{@prompt}\"\n"

# Doom, death and destruction - write our finished result.

puts "Enter 'y' to agree to 'stuff' and overwrite your Bash config."

answer = gets.chomp

if answer == 'y' || answer == 'Y'
  home = ENV["HOME"] + "/"
  
  File.open(home + ".bash_profile", "w") do |file|
    file.write(@bash_profile)
  end

  File.open(home + ".aliases", "w") do |file|
    file.write(@aliases.join("\n"))
  end
  
  File.open(home + ".profile", "w") do |file|
    file.write(@paths.join("\n"))
    file.write("\n")
    file.write(@manpaths.join("\n"))
  end
  
  File.open(home + ".bashrc", "w") do |file|
    file.write(@bashrc.join("\n"))
  end
end
