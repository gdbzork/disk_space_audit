require 'test_helper'
require 'diskAudit/logs.rb'

module DiskAudit
  class LogsTest < Minitest::Test
    def test_basic_sanity
      log = Logs.new("zork")
      assert_equal("zork",log.tag)
    end

    def test_basic_links
      log = Logs.new("zork")
      log.broken_link("/this/is/a/path")
      assert_equal("/this/is/a/path",log.links[0].path)
      log.broken_link("/another/path/follows")
      assert_equal("/another/path/follows",log.links[1].path)
    end

  end
end
