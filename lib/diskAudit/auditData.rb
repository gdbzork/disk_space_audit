require "ostruct"

require "diskAudit/version"
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

    def report(outFD)
      @rdata = []
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
        comma_y = FriendlyNumbers.commify(y)
        units_y = FriendlyNumbers.addUnits(y)
        row = OpenStruct.new
        row.name = n
        row.friendly = "%f %s" % [units_y[0],units_y[1]]
        row.raw = comma_y
        @rdata << row
      end

      path = File.join(Gem.datadir(PACKAGE),"report.txt.erb")
      fd = File.open(path)
      template = fd.read
      fd.close
      renderer = ERB.new(template)
      outFD.write(renderer.result(binding))
      
    end

  end

end
