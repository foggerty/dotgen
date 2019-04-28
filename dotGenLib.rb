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

# Given a (valid) Bash command, will return true/false depending on
# the exit value of the command.  i.e. Give this a shit command
# and it'll most likely return false no matter what.

def test(command)
  # Erm, just return exit value?
end

