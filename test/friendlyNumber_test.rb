require 'test_helper'
require 'diskAudit/friendlyNumber.rb'

module DiskAudit

  class FriendlyNumberTest < Minitest::Test

    def test_basic_sanity
      a = FriendlyNumber.new(99)
      assert_equal(99,a.sig)
      assert_equal("b",a.units)
      assert_equal("99",a.commify)
    end

    def test_one_comma
      a = FriendlyNumber.new(1024)
      assert_equal("1,024",a.commify)
    end

    def test_several_commas
      a = FriendlyNumber.new(10242345678)
      assert_equal("10,242,345,678",a.commify)
    end

    def test_negative_commas
      a = FriendlyNumber.new(-142345678)
      assert_equal("-142,345,678",a.commify)
    end

    def test_fractional_commas
      a = FriendlyNumber.new(142345678.3)
      assert_equal("142,345,678.3",a.commify)
    end

    def test_edge_1024
      a = FriendlyNumber.new(1024)
      assert_equal(1,a.sig)
      assert_equal("Kb",a.units)
    end

    def test_edge_1023
      a = FriendlyNumber.new(1023)
      assert_equal(1023,a.sig)
      assert_equal("b",a.units)
    end

    def test_edge_1025
      a = FriendlyNumber.new(1025)
      assert_equal(1.0,a.sig)
      assert_equal("Kb",a.units)
    end

    def test_middle_1525
      a = FriendlyNumber.new(1525)
      assert_equal(1.5,a.sig)
      assert_equal("Kb",a.units)
    end

    def test_yotta
      a = FriendlyNumber.new(1525159951491059582496710)
      assert_equal(1.3,a.sig)
      assert_equal("Yb",a.units)
    end

    def test_beyond_yotta
      a = FriendlyNumber.new(1525159912351491059582496710)
      assert_equal(1261.6,a.sig)
      assert_equal("Yb",a.units)
    end

    def test_negative_1525
      a = FriendlyNumber.new(-1525)
      assert_equal(-1.5,a.sig)
      assert_equal("Kb",a.units)
    end

    def test_negative_decimal_1525
      a = FriendlyNumber.new(-1525.1928348)
      assert_equal(-1.5,a.sig)
      assert_equal("Kb",a.units)
    end

  end

end
