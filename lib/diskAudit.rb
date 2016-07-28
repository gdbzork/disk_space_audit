require "find"
require "diskAudit/auditData"
require "diskAudit/version"

# Audits a path or paths on disk, reporting disk usage by user.
#
# @author Gord Brown
module DiskAudit

  # Top-level class to carry out an audit, and ultimately generate a report.
  class DiskAudit

    # Audits a path.
    # @param path [String] the string representation of the path to audit
    # @return [AuditData] the results of the audit for this path
    def audit(path,data)
      Find.find(path) do |p|
        if FileTest.file?(p)
          data.add(p)
        else
          puts "Visiting '#{p}'..."
        end
      end
    end

    def dump_dirs(paths)
    end

    def execute_remote(paths)
    end

    def report(paths)
      data = AuditData.new
      paths.each do |arg|
        puts "Processing '#{arg}'..."
        audit(arg,data)
      end
      data.report(STDOUT)
    end

  end
end
