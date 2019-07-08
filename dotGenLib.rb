################################################################################
# Helper functions.
################################################################################

# Will look up the OS specific option in hash 'options'.  Note that if
# this method is called, 'options' MUST contain a matching key.  If a
# block is provided that returns anything other than true, this will
# return the empty string.

def os_opt(options)
  if block_given? & !yield
    retun ""
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
    system(cfg[:test], :err => File::NULL )

  if(!result)
    puts "Config entry #{cfg[:name]} failed test."
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

def addPathsToCollection(cfg, key, collection, prefix)
  return if cfg[key] == nil

  collection << "# #{cfg[:name]}"

  cfg[key].each do |p|
    if p.include?("$#{prefix}")
      collection << "export #{prefix}=\"#{p}\""
    else
      collection << "export #{prefix}=\"$#{prefix}:#{p}\""
    end
  end

  collection << "\n"
end

def addAliasesToollection(cfg, result)
  if cfg[:aliases]

    result << "# #{cfg[:name]}"

    cfg[:aliases].each do |a, c|
      result << "alias #{a}='#{c}'"
    end

    result << "\n"
  end
end
