################################################################################
# Helper functions.
################################################################################

def bail(msg)
  SSTDERR.puts(msg)
  exit 1
end

# Will look up the OS specific option in hash 'options'.  Note that if
# this method is called, 'options' MUST contain a matching key.  If a
# block is provided that returns anything other than true, this will
# return the empty string.

def os_opt(options)
  if block_given? & !yield
    return ""
  end
  
  result = options[@os]

  if result == nil
    bail 'os_opt - options does not contain a recognised OS symbol.' 
  end
  
  result
end

def runTest(cfg)
  result =
    cfg[:test] == nil ||
    system(cfg[:test], :err => File::NULL, :out => File::NULL )

  if(!result)
    STDERR.puts "Config for '#{cfg[:name]}' failed test."
  end
  
  result;
end

def isConfig(cfg)
  if cfg.class == Hash && cfg[:name].class == String

    enabled = cfg[:enabled] == nil || cfg[:enabled] == true
    right_os = cfg[:os] == nil || cfg[:os] == @os
    
    return enabled && right_os
  end

  STDERR.puts "Each config entry must be a hash, with a :name key (string)."
  
  return false
end

def isCorrectType(cfg, entryName, expectedType)
  return true if cfg[entryName] == nil

  if cfg[entryName].class != expectedType
    STDERR.puts ":#{entryName} must be a #{expectedType} in entry '#{cfg[:name]}'"
    return false
  end
  
  return true
end

################################################################################
## Extract/copy 'stuff'
################################################################################

def extractPaths(cfg, key, prefix)
  result = ["# #{cfg[:name]}"]

  cfg[key].each do |p|
    if p.include?("$#{prefix}")
      result << "export #{prefix}=\"#{p}\""
    else
      result << "export #{prefix}=\"$#{prefix}:#{p}\""
    end
  end

  result
end

def extractMap(cfg, key, name)
  result = ["# #{cfg[:name]}"]
  
  cfg[key].each do |a, c|
    result << "#{name} #{a}='#{c}'"
  end

  result
end

def extractAliases(cfg)
  extractMap(cfg, :aliases, "alias")
end

def extractVars(cfg)
  extractMap(cfg, :vars, "export")
end  

################################################################################
## Output 'stuff
################################################################################

# Expects a block that returns an array of string.
def writeConfig(name)
  if !block_given?
    puts "'writeConfig() requires a block."
    exit 1
  end

  content = yield
  
  if content.class != String && content.class != Array
    bail "'wrieConfig(#{name})' expects to receive a string or array."
  end

  if content.class == Array
    content = content.join("\n")
  end
  
  home = ENV["HOME"] + "/"
  
  File.open(home + name, "w") do |file|
    file.write(content + "\n")
  end
end
