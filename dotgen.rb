load './dotGenLib.rb'
load './config.rb'

################################################################################
## Setup and sanity check
################################################################################

@entries = @config.select() {|cfg| cfg_enabled(cfg)}

if @entries.length == 0
  puts "Either everything is disabled, or nothing applies to this OS."
  exit(0)
end

@entries.each do |cfg|
    
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

  # Manpaths must be an array of strings
  if cfg[:manpaths] != nil && cfg[:manpaths].class != Array
    raise "Manpaths must be an array of string in entry #{cfg[:name]}."
  end

end

################################################################################
## Put it all together
################################################################################

@aliases = []
@paths = []
@manpaths = []
@bashrc = []

def addAliases(cfg, name)
  if cfg[:aliases]

    @aliases << "# #{name}"

    cfg[:aliases].each do |a, c|
      @aliases << "alias #{a}='#{c}'"
    end

    @aliases << ""
  end
end

def addPathsToCollection(name, collection, paths, prefix)
    collection << "# #{name}"

    paths.each do |p|
      if p.include?("$#{prefix}")
        collection << "export #{prefix}=\"#{p}\""
      else
        collection << "export #{prefix}=\"$#{prefix}:#{p}\""
      end
    end

    collection << ""
end

def addPaths(cfg, name)
  if cfg[:paths]
    addPathsToCollection(name, @paths, cfg[:paths], "PATH")
  end
end

def addManPaths(cfg, name)
  if cfg[:manpaths]
    addPathsToCollection(name, @manpaths, cfg[:manpaths], "MANPATH")
  end
end

@entries.each do |cfg|
  name = cfg[:name]

  addAliases(cfg, name)
  addPaths(cfg, name)
  addManPaths(cfg, name)
end

@bashrc << @bash_sanity << "\n"
@bashrc << @bashrc_aliases << "\n"
@bashrc << "# Prompt"
@bashrc << "PS1=\"#{@prompt}\""

puts ".aliases ========================================="
puts @aliases

puts "\n.bash_profile =================================="
puts @bash_profile

puts "\n.profile ======================================="
puts @paths
puts @manpaths

puts "\n.bashrc ========================================"
puts @bashrc

# Finally, ask user if they want to overwrite their current dot files.

puts "\n\n"
puts "Does that all look ok?  Enter 'y' to agree and overwrite your config."

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
