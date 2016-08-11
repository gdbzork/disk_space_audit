module DiskAudit

  # Convert numbers to friendly formats (with commas, or with units, e.g. Mb).
  #
  # Supports up to yottabytes (or arbitrary for commas).  Negative numbers
  # work, but for the comma-adding, decimals do not.
  #
  # For example, if the argument to the constructor is 23456, "commify" will
  # return "23,456" (as a string), ".sig" will provide 2.3, and ".units"
  # will return "Kb".
  class FriendlyNumber

    private
    UNITS = ["b","Kb","Mb","Gb","Tb","Pb","Eb","Zb","Yb"]
    SCALE = 1024
    public
   
    # The "base" of the converted number with (at most) 1 digit after the
    # decimal, e.g. 1.4
    attr_reader :sig
    # The units of the converted number, e.g. "Gb"
    attr_reader :units

    # The constructor.
    #
    # @param num [Number] the number to make friendlier to read.
    def initialize(num)
      @num = num
      @sig, @units = toUnits(num)
    end

    # Add commas (to an integer).
    #
    # For example, 10234564 becomes "10,234,564"
    def commify()
      return @num.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
    end

    def fmt
      if @units == 'b'
        f = "%d %s" % [@sig,@units]
      else
        f = "%.1f %s" % [@sig,@units]
      end
      return f
    end

    private
    def toUnits(num)
      flip = false
      if num < 0
        num = -num
        flip = true
      end
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
      n = -n if flip
      return n, UNITS[i]
    end

  end
end
