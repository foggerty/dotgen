################################################################################
# Helper functions.
################################################################################

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
    raise 'os_opt - options does not contain a recognised OS symbol.' 
  end
  
  result
end

def runTest(cfg)
  result =
    cfg[:test] == nil ||
    system(cfg[:test], :err => File::NULL, :out => File::NULL )

  if(!result)
    puts "Config for '#{cfg[:name]}' failed test."
  end
  
  result;
end

def isConfig(cfg)
  if cfg.class == Hash && cfg[:name].class == String

    enabled = cfg[:enabled] == nil || cfg[:enabled] == true
    right_os = cfg[:os] == nil || cfg[:os] == @os
    
    return enabled && right_os
  else
    puts "Each config entry must be a hash, with a :name key (string)."
  end

  return false
end

def isCorrectType(cfg, entryName, expectedType)
  return true if cfg[entryName] == nil

  if cfg[entryName].class != expectedType
    puts ":#{entryName} must be a #{expectedType} in entry '#{cfg[:name]}'"
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
  
  result << "\n"
end

def extractAliases(cfg)
  result = ["# #{cfg[:name]}"]
  
  cfg[:aliases].each do |a, c|
    result << "alias #{a}='#{c}'"
  end

  result << "\n"
end
