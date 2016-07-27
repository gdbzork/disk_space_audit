module DiskAudit

  class FriendlyNumbers

    UNITS = ["b","Kb","Mb","Gb","Tb","Pb","Eb","Zb","Yb"]
    SCALE = 1024

    def self.commify(num)
      return num.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
    end

    def self.addUnits(num)
      top = UNITS.length - 1
      i = 0
      n = num
      if n >= SCALE
        n = num.to_f
        while i < top && n >= SCALE
          n = n / SCALE
          i += 1
        end
        n = n.round(1)
      end
      return n,UNITS[i]
    end

  end
end
