################################################################################
# Helper functions.
################################################################################

def bail(msg)
  STDERR.puts(msg)
  exit 1
end

# Will look up the OS specific option in hash 'options'.  Note that if
# this method is called, 'options' MUST contain a matching key.  If a
# block is provided that returns anything other than true, this will
# return the empty string.

def os_opt(options)
  result = options[@os]

  bail 'os_opt - options does not contain a recognised OS symbol.' if result.nil?

  result
end

################################################################################
## Sanity tests
################################################################################

def config_enabled?(cfg)
  enabled = cfg[:enabled].nil? || cfg[:enabled] == true
  right_os = cfg[:inc_os].nil? || cfg[:inc_os].include?(@os)
  wrong_os = !cfg[:exc_os].nil? && cfg[:exc_os].include?(@os)

  warn "DISABLED: #{cfg[:name]}" unless enabled

  enabled && right_os && !wrong_os
end

def correct_type?(cfg, entry_name, expected_type)
  return true if cfg[entry_name].nil?

  ok = cfg[entry_name].class == expected_type

  warn ":#{entry_name} must be a #{expected_type} in entry '#{cfg[:name]}'" unless ok

  ok
end

def run_test(cfg)
  result = cfg[:test].nil? || system(cfg[:test], {:err => File::NULL, :out => File::NULL})

  warn "FAILED TEST: #{cfg[:name]}." unless result

  result
end

def valid_config?(cfg)
  valid_entry = cfg.class == Hash &&
                cfg[:name].class == String &&
                !cfg[:name].chomp.empty?

  warn 'Config entry must be a hash containing a ":name" key.' unless valid_entry

  valid_entry &&
    config_enabled?(cfg) &&
    correct_type?(cfg, :aliases, Hash) &&
    correct_type?(cfg, :paths, Array) &&
    correct_type?(cfg, :manpaths, Array) &&
    correct_type?(cfg, :test, String) &&
    correct_type?(cfg, :vars, Hash) &&
    correct_type?(cfg, :bashrc, Array) &&
    correct_type?(cfg, :profile, Array) &&
    correct_type?(cfg, :inc_os, Array) &&
    correct_type?(cfg, :exc_os, Array) &&
    run_test(cfg)
end

################################################################################
## Extract/copy 'stuff' from config
################################################################################

def extract_paths(cfg, key, prefix)
  result = ["# #{cfg[:name]}"]

  cfg[key].each do |p|
    if p.include?("$#{prefix}")
      result << "export #{prefix}=\"#{p}\""
    else
      result << "export #{prefix}=\"#{p}:$#{prefix}\""
    end
  end

  result << "\n"
end

def extract_map(cfg, key, name)
  result = ["# #{cfg[:name]}"]

  cfg[key].each do |a, c|
    result << "#{name} #{a}=\"#{c}\""
  end

  result << "\n"
end

def extract_aliases(cfg)
  extract_map(cfg, :aliases, 'alias')
end

def extract_exports(cfg)
  extract_map(cfg, :exports, 'export')
end

def extract_vars(cfg)
  extract_map(cfg, :vars, 'set')
end

def extract_profile(cfg)
  result = ["# #{cfg[:name]}"]
  result << cfg[:profile]
  result << "\n"
end

def extract_bashrc(cfg)
  result = ["# #{cfg[:name]}"]
  result << cfg[:bashrc]
  result << "\n"
end

################################################################################
## Output 'stuff'
################################################################################

# Generates bash code for all config that has a given key, by using
# the supplied transform function.
def generate(key, &transform)
  @config                              # for each config entry
    .filter { |cfg| !cfg[key].nil? }   # that has a matching key
    .map { |cfg| transform.call(cfg) } # extract what we need
    .flatten                           # and flatten the results
end

# Expects a block that returns a string.
def write_config(name)
  unless block_given?
    puts 'writeConfig() requires a block.'
    exit 1
  end

  content = yield

  home = ENV['HOME'] + '/'

  File.open(home + name, 'w') do |file|
    file.write(content)
  end
end
