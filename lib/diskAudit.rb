require "find"
require "net/ssh"
require "diskAudit/auditData"
require "diskAudit/version"

# Audits a path or paths on disk, reporting disk usage by user.
#
# @author Gord Brown
module DiskAudit

  USER = "brown22"
  RUBY_BIN = "/opt/software/ruby/ruby-2.3.1/bin"
  REMOTE = "bioinfDiskAudit"
  TARGET = "/var/www/html/diskAudit"

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
          $log.debug("Visiting '#{p}'...")
        end
      end
    end

    def generate_report(data)
      js = File.join(Gem.datadir(PACKAGE),"sorttable.js")
      css = File.join(Gem.datadir(PACKAGE),"report.css")
      FileUtils.cp(js,TARGET)
      FileUtils.cp(css,TARGET)
      @args = []
      @rdata = {}
      data.each do |k,v|
        @args << k
        @rdata[k] = v.report()
      end

      path = File.join(Gem.datadir(PACKAGE),"report.html.erb")
      fd = File.open(path)
      template = fd.read
      fd.close
      $log.debug("about to create renderer...")
      renderer = ERB.new(template,nil,">")
      $log.debug("rendering... #{@rdata.length}")
      outFD.write(renderer.result(binding))
    end

    def dump_dir(path)
      $log.debug("Processing '#{path}'...")
      data = AuditData.new
      audit(path,data)
      Marshal.dump(data,STDOUT)
    end

    def execute_remote(paths)
      paths.each do |arg|
        components = arg.split(":")
        $log.debug("host: #{components[0]}  target: #{components[1]}")
        Net::SSH.start(components[0],USER) do |ssh|
          raw = ssh.exec!("#{RUBY_BIN}/ruby #{RUBY_BIN}/#{REMOTE} dump #{components[1]}")
          data[arg] = Marshal.load(raw)
        end
      end
      generate_report(data)
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
