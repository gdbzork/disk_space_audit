require "yaml"

module DiskAudit

  class Configuration

    EXPECTED = [:destination,:ssh_user,:system_log,:log_level,:group_id,
                :admins,:targets,:exclude,:people,:useridMap]
    REQUIRED = [:destination,:targets]

    def initialize(defaults,cmd_opts)
      @fields = defaults
      if !cmds_opts[:config_file].nil?
        path = cmds_opts[:config_file]
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

    def method_missing method, *args, &block
      self.class.send(:define_method, method) do 
        return @fields[method.to_sym]
      end
      self.send method, *args, &block
    end

    def add(tag, value)
      @fields[tag.to_sym] = value
    end
  end
end
