require "diskAudit/friendlyNumbers"

module DiskAudit

  # Stores the results of an audit of a path.
  #
  class AuditData

    CHEAT = {802161580 => "howe01",
             853250745 => "halim01",
             899611315 => "macart01",
             413334374 => "carrol09",
            }

    def initialize()
      @store = Hash.new()
    end

    def add(path)
      s = File.lstat(path)
      @store[s.uid] = @store.fetch(s.uid,0) + s.size
    end

    def report(fd)
      @store.each do |x,y|
        begin
          n = Etc.getpwuid(x).name
        rescue
          if CHEAT.has_key?(x)
            n = CHEAT[x]
          else
            n = "#{x}"
          end
        end
        friendly_y = FriendlyNumbers.commify(y)
        units_y = FriendlyNumbers.addUnits(y)
        fd.write("#{n}: #{units_y} (#{friendly_y})\n")
      end
    end

  end

end
