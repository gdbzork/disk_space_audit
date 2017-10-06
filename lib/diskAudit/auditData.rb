require "ostruct"
require "erb"
require "fileutils"

require "diskAudit/constants"
require "diskAudit/runInfo"
require "diskAudit/logs"
require "diskAudit/friendlyNumber"
require "diskAudit/pathData"

module DiskAudit

  # Stores the results of an audit of a path.
  #
  class AuditData

    # Map of userids to usernames, for those that the system won't tell us about.
    CHEAT = {802161580 => "howe01",
             853250745 => "halim01",
             899611315 => "macart01",
             413334374 => "carrol09",
             1843454863 => "vowler01",
             1611831722 => "sannar01",
            }

    def initialize(tag,path)
      @info = RunInfo.new
      @info.path= path
      @log = Logs.new(tag)
      @blocks = Hash.new()
      @tree = PathData.new()
    end

    attr_reader :info
    attr_reader :log
    attr_reader :rdata

    def add(path)
      s = File.lstat(path)
      @blocks[s.uid] = @blocks.fetch(s.uid,0) + s.blocks
      @tree.add(path,s.blocks,s.uid)
    end

    def mkBigDirs
      @bigDirs = @tree.identify()
    end

    def prepare
      rdata = []
      @blocks.each do |x,y|
        next if y == 0
        begin
          n = Etc.getpwuid(x).name
        rescue
          if CHEAT.has_key?(x)
            n = CHEAT[x]
          else
            n = "#{x}"
          end
        end
        y = y * 512 # convert blocks to bytes
        units_y = FriendlyNumber.new(y)
        row = OpenStruct.new
        row.name = n
        row.friendly = units_y.fmt
        row.raw = y
        if @bigDirs.has_key?(x)
          pset = @bigDirs[x]
          pset.sort!{|a,b| b.size <=> a.size}
          pset.each do |os|
            os.friendly = FriendlyNumber.new(os.size * 512).fmt
          end
          row.big = pset
        else
          row.big = []
        end
        rdata << row
      end
      @rdata = rdata.sort{|a,b| b.raw <=> a.raw}
    end
  end
end
