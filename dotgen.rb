load './dotGenLib.rb'
load './config.rb'

@aliases = []
@paths = []
@manpaths = []
@bashrc = []

################################################################################
## Setup and sanity check
################################################################################

# Give me a functional construct with side-effects, and by gods I'll us it to
# the fullest.

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

@config.each do |cfg|
  puts "Processing #{cfg[:name]}"
  
  addAliasesToollection(cfg, @aliases)
  addPathsToCollection(cfg, :paths, @paths, "PATH")
  addPathsToCollection(cfg, :manpaths, @manpaths, "MANPATH")
end

@bashrc << @bash_sanity << "\n"
@bashrc << @bashrc_aliases << "\n"
@bashrc << "# Prompt"
@bashrc << "PS1=\"#{@prompt}\""

puts "\n\n"

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
