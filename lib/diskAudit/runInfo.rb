module DiskAudit

  # Store some information about this run, such as start and end times, the
  # host, and the path that was evaluated.
  class RunInfo
    def initialize
      @host = `hostname`.strip
    end

    # Retrieve run host
    attr_reader :host

    # Set the start time.
    def setStart
      @start = Time.now
    end
    # Retrieve the start time.
    attr_reader :start

    # Set the done time.
    def setDone
      @done = Time.now
    end
    # Retrieve the done time.
    attr_reader :done

    # The path that was evaluated on this run
    attr_reader :path
    def path=(path)
      @path = path
      setVolumeInfo
    end

    # Size of the disk partition we're looking at
    attr_reader :size
    # Amount used of the disk partition we're looking at
    attr_reader :used
    # Amount available of the disk partition we're looking at
    attr_reader :avail
    private
    def setVolumeInfo
      stdout  = `df -h #{@path}`
      lines = stdout.split("\n")
      # horrible hack in case df splits a line
      lines[1] = lines[1] + " " + lines[2] if lines.length == 3
      heads = lines[0].split
      values = lines[1].split
      instance_variable_set("@#{heads[1].downcase}",values[1])
      instance_variable_set("@#{heads[2].downcase}",values[2])
      instance_variable_set("@#{heads[3].downcase}",values[3])
    end
  end
end
