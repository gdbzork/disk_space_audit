require "ostruct"
require "erb"
require "fileutils"

require "diskAudit/version"
require "diskAudit/friendlyNumbers"

module DiskAudit

  # Stores the size of directories on the path
  #
  class PathData

    THRESHOLD = 268435456 # 2^37 bytes / 512 (blocks), or roughly 137Gb

    def initialize()
      @paths = Hash.new
    end

    def add(path,size,uid)
      $log.debug("Adding uid='#{uid}' size='#{size} '#{path}'")
      if not @paths.has_key? uid
        @paths[uid] = OpenStruct.new
        @paths[uid].total = 0
        @paths[uid].kids = Hash.new()
      end
      components = File.dirname(path).split(File::SEPARATOR)
      current = @paths[uid]
      current.total += size
      components.each do |c|
        if not current.kids.has_key? c
          current.kids[c] = OpenStruct.new
          current.kids[c].total = 0
          current.kids[c].kids = Hash.new()
        end
        current = current.kids[c]
        current.total += size
      end
    end

#    def identify_r(path,current,candidates)
#      reported = false
#      current.kids.each do |component,os|
#        reported = true if identify_r(File.join(path,component),os,candidates)
#      end
#      if not reported and current.total > THRESHOLD
#        candidates[path] = current.total
#        reported = true
#      end
#      return reported
#    end

    def identify_r(path,current,candidates)
      reported = 0
      current.kids.each do |component,os|
        reported = [reported,identify_r(File.join(path,component),os,candidates)].max
      end
      mult = (current.total / THRESHOLD).to_i
      if mult >= 1 and mult >= reported * 2
        candidates[path] = current.total
        reported = mult
      end
      return reported
    end

    def identify()
      candidates = Hash.new()
      byUser = Hash.new()
      @paths.each do |uid,pathset|
        byUser[uid] = []
        candidates = Hash.new()
        identify_r("",pathset,candidates)
        candidates.each do |path,size|
          $log.debug("Adding uid=#{uid} size=#{size} path=#{path}")
          os = OpenStruct.new
          os.path = path
          os.size = size
          byUser[uid] << os
        end
      end
      return byUser
    end

  end

  # Stores the results of an audit of a path.
  #
  class AuditData

    CHEAT = {802161580 => "howe01",
             853250745 => "halim01",
             899611315 => "macart01",
             413334374 => "carrol09",
            }

    def initialize()
#      @store = Hash.new()
      @blocks = Hash.new()
      @tree = PathData.new()
    end

    def add(path)
      s = File.lstat(path)
#      @store[s.uid] = @store.fetch(s.uid,0) + s.size
      @blocks[s.uid] = @blocks.fetch(s.uid,0) + s.blocks
      @tree.add(path,s.blocks,s.uid)
    end

    def mkBigDirs()
      @bigDirs = @tree.identify()
    end

    def report()
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
#        comma_y = FriendlyNumbers.commify(y)
        y = y * 512 # convert blocks to bytes
        units_y = FriendlyNumbers.addUnits(y)
        row = OpenStruct.new
        row.name = n
        if units_y[1] != "b"
          row.friendly = "%.1f %s" % [units_y[0],units_y[1]]
        else
          row.friendly = "%d %s" % [units_y[0],units_y[1]]
        end
#        row.comma = comma_y
        row.raw = y
#        blksize = FriendlyNumbers.addUnits(@blocks[x] * 512)
#        row.blksize = "%.1f %s" % [blksize[0],blksize[1]]
#        row.diff = FriendlyNumbers.commify((@blocks[x] * 512) - y)
        if @bigDirs.has_key?(x)
          pset = @bigDirs[x]
          pset.sort!{|a,b| b.size <=> a.size}
          pset.each do |os|
            os.friendly = "%.1f %s" % FriendlyNumbers.addUnits(os.size * 512)
          end
          row.big = pset
        else
          row.big = []
        end
        rdata << row
      end
      rdata = rdata.sort{|a,b| b.raw <=> a.raw}
      return rdata

#      path = File.join(Gem.datadir(PACKAGE),"report.html.erb")
#      fd = File.open(path)
#      template = fd.read
#      fd.close
#      $log.debug("about to create renderer...")
#      renderer = ERB.new(template,nil,">")
#      $log.debug("rendering... #{@rdata.length}")
#      outFD.write(renderer.result(binding))
      
    end

  end

end
