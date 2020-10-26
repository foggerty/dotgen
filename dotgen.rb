load './dotgenlib.rb'
load './config.rb'

@aliases = []
@paths = []
@manpaths = []
@bashrc = []
@exports = [ ]

################################################################################
## Setup and sanity check.
################################################################################

@config.filter! do |cfg|
  valid_config?(cfg)
end

if @config.length.zero?
  bail 'Either all config is disabled/broken, or none of it applies to this OS.'
end

@config.each{ |cfg| puts "APPLYING:\t#{cfg[:name]}" }

################################################################################
## Extract various configuration 'stuff'.
################################################################################

@aliases  = generate(:aliases)  { |cfg| extract_aliases(cfg) }
@paths    = generate(:paths)    { |cfg| extract_paths(cfg, :paths, 'PATH') }
@manpaths = generate(:manpaths) { |cfg| extract_paths(cfg, :manpaths, 'MANPATH') }
@vars     = generate(:vars)     { |cfg| extract_vars(cfg) }
@cmds     = generate(:bashrc)   { |cfg| extract_bashrc(cfg) }
@exports  = generate(:exports)  { |cfg| extract_exports(cfg) }

@bashrc << @bash_sanity
@bashrc << @bashrc_load_aliases
@bashrc << '# Prompt'
@bashrc << "PS1=\"#{@prompt}\"\n"
@bashrc << @cmds.join("\n")


################################################################################
## Doom, death and destruction - write our finished results.
################################################################################

puts "Enter 'y' to agree to 'stuff' and overwrite your Bash config."

answer = gets.chomp

if answer.downcase == 'y'
  write_config('.bash_profile') { @bash_profile }
  write_config('.aliases') { @aliases.join("\n") }
  write_config('.bashrc') { @bashrc.join("\n") }
  write_config('.profile') { [@paths, @manpaths, @vars, @exports].flatten.join("\n") }
end
