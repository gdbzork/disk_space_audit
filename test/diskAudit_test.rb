require 'test_helper'

class DiskAuditTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::DiskAudit::VERSION
  end

end
