require "ostruct"
require "erb"
require "fileutils"

module DiskAudit

  # Stores the size of directories on the path
  #
  class PathData

    THRESHOLD = 268435456 # 2^37 bytes / 512 (blocks), or roughly 128Gb

    def initialize()
      @paths = Hash.new
    end

    def add(path,size,uid)
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
          os = OpenStruct.new
          os.path = path
          os.size = size
          byUser[uid] << os
        end
      end
      return byUser
    end
  end
end
