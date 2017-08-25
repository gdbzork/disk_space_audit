require 'test_helper'
require 'diskAudit/runInfo.rb'

module DiskAudit
  class RunInfoTest < Minitest::Test
    def test_set_path
      a = RunInfo.new
      a.path = "."
      assert_equal(".",a.path)
    end

    def test_set_start
      a = RunInfo.new
      a.setStart
      sleep(0.1)
      assert(a.start < Time.now)
    end

    def test_set_done
      a = RunInfo.new
      a.setDone()
      sleep(0.1)
      assert(a.done < Time.now)
    end

    def test_set_size
      a = RunInfo.new
      a.path = "."
      refute_nil(a.size)
    end
  end
end
