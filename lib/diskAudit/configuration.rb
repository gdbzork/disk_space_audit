require "yaml"

module DiskAudit

  # Load, store the configuration data, for the rest of the application to use.
  #
  # The configuration data are a combination of some hard-coded defaults, the contents of the
  # configuration file, and command-line parameters.  In order of precedence, command-line
  # parameters override the contents of the configuration file, which in turn override the
  # hard-coded defaults.
  #
  # The syntax and contents of the configuration file are described in the top-level README.md.
  #
  # Usage:
  #   conf = Configuration.new(DiskAudit::CONFIG_DEFAULTS,args)
  #   peeps = conf.people
  #
  # More generally, to retrieve configuration item `zork`, use `conf.zork`.
  class Configuration

    # Sections we expect to see in the configuration file.
    EXPECTED = [:destination,:ssh_user,:system_log,:log_level,:group_id,
                :admins,:targets,:exclude,:people,:useridMap]
    # Sections that are required in the configuration file.
    REQUIRED = [:destination,:targets]

    # Create a new configuration object, from the defaults, the configuration file, and the 
    # parameters from the command line.
    # @param defaults [Hash] The initial hard-coded defaults.
    # @param cmd_opts [Hash] Parameters from the command line (pre-parsed by `optparse`).
    def initialize(defaults,cmd_opts)
      @fields = defaults
      if !cmd_opts[:config_file].nil?
        path = cmd_opts[:config_file]
      else
        path = defaults[:config_file]
      end
      data = YAML.load_file(path)
      # Now combine data:
      #   defaults, config file, command line (low->high priority)
      data.each do |k,v|
        if EXPECTED.include? k.to_sym
          @fields[k.to_sym] = v
        else
          STDERR.puts "Warning: unknown section '#{k}' in config file"
        end
      end
      cmd_opts.each do |k,v|
        @fields[k] = v
      end
    end

    # For simplicity, the configuration object will accept any "method"; if the method
    # name corresponds with a field in the configuration data, the value of the field will be
    # returned.  Otherwise it returns `nil`.  
    def method_missing method, *args, &block
      self.class.send(:define_method, method) do 
        return @fields[method.to_sym]
      end
      self.send method, *args, &block
    end

    # Add a new configuration key/value pair.
    # @param tag [String] the key.
    # @param value [Object] the value to store.
    def add(tag, value)
      @fields[tag.to_sym] = value
    end
  end
end
