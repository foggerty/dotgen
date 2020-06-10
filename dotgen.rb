load './dotgenlib.rb'
load './config.rb'

@aliases = []
@paths = []
@manpaths = []
@bashrc = []

################################################################################
## Setup and sanity check.
################################################################################

@config.filter! do |cfg|
  isConfig(cfg) &&
    isCorrectType(cfg, :aliases, Hash) &&
    isCorrectType(cfg, :paths, Array) &&
    isCorrectType(cfg, :manpaths, Array) &&
    isCorrectType(cfg, :test, String) &&
    isCorrectType(cfg, :vars, Hash) &&
    runTest(cfg)
end

if @config.length == 0
  bail "Either all config is disabled, or none of it applies to this OS."
end

################################################################################
## Extract various configuration 'stuff'.
################################################################################

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

@vars = @config.
  filter {|cfg| cfg[:vars] != nil}.
  map {|cfg| extractVars(cfg)}.
  flatten

@bashrc << @bash_sanity
@bashrc << @bashrc_aliases
@bashrc << "# Prompt"
@bashrc << "PS1=\"#{@prompt}\"\n"

################################################################################
## Doom, death and destruction - write our finished results.
################################################################################

puts "Enter 'y' to agree to 'stuff' and overwrite your Bash config."

answer = gets.chomp

if answer == 'y' || answer == 'Y'
  writeConfig(".bash_profile") { @bash_profile }
  writeConfig(".aliases") { @aliases }
  writeConfig(".bashrc") { @bashrc }
  writeConfig(".profile") { [@paths, @manpaths, @vars] }
end
