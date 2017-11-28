require 'test_helper'
require 'diskAudit/configuration'
require 'diskAudit/constants'

module DiskAudit

  class ConfigurationTest < Minitest::Test

    def test_basic_sanity
      a = Configuration.new(CONFIG_DEFAULTS,{})
      assert_equal(1592081963,a.group_id)
    end

    def test_cmdline_override
      a = Configuration.new(CONFIG_DEFAULTS,{format: :html})
      assert_equal(:html,a.format)
    end

  end

end
