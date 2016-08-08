require "find"
require "net/ssh"
require "date"

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
  DEST = "/var/www/html/diskAudit/diskReport.html"

  # Top-level class to carry out an audit, and ultimately generate a report.
  class DiskAudit

    # Audits a path.
    # @param path [String] the string representation of the path to audit
    # @return [AuditData] the results of the audit for this path
    def audit(path,data)
      Find.find(path) do |p|
        if FileTest.symlink?(p)
          data.add(p)
          begin
            File.stat(p)
          rescue
            $log.info("Broken SymLink: '#{p}'")
          end
          Find.prune
        elsif FileTest.file?(p)
          data.add(p)
        else
          if not FileTest.readable?(p)
            $log.warn("PERMISSION DENIED: '#{p}'")
          else
            $log.debug("Visiting '#{p}'...")
            data.add(p)
          end
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
      @volInfo = {}
      data.each do |k,v|
        @args << k
        @rdata[k] = v.report()
        @volInfo[k] = v.volumeInfo()
      end
      @date = Date.today.iso8601

      path = File.join(Gem.datadir(PACKAGE),"report.html.erb")
      fd = File.open(path)
      template = fd.read
      fd.close
      $log.debug("about to create renderer...")
      renderer = ERB.new(template,nil,">")
      $log.debug("rendering... #{@rdata.length}")
      outFD = File.open(DEST,"w")
      outFD.write(renderer.result(binding))
      outFD.close()
    end

    def dump_dir(path)
      if not File.exist?(path)
        $log.error("No such path: '#{path}'...")
        STDOUT.write("No such path: '#{path}'...\n")
        return
      end
      $log.debug("Processing '#{path}'...")
      data = AuditData.new
      audit(path,data)
      data.mkBigDirs()
      data.getVolumeInfo(path)
      Marshal.dump(data,STDOUT)
    end

    def execute_remote(paths)
      data = {}
      paths.each do |arg|
        components = arg.split(":")
        $log.debug("host: #{components[0]}  target: #{components[1]}")
        Net::SSH.start(components[0],USER) do |ssh|
          raw = ssh.exec!("#{RUBY_BIN}/ruby #{RUBY_BIN}/#{REMOTE} dump #{components[1]}")
          begin
            data[arg] = Marshal.load(raw)
          rescue
            $log.error("Got unexpected result from '#{arg}': #{raw}")
          end
        end
      end
      generate_report(data)
    end

    def report(paths)
      @date = Date.today.iso8601
      host = `hostname`.strip
      @args = []
      @rdata = {}
      paths.each do |arg|
        if not File.exist? arg
          $log.error("No such path: '#{arg}'")
          next
        end
        $log.info("Processing '#{arg}'...")
        data = AuditData.new
        audit(arg,data)
        data.mkBigDirs()
        full = "#{host}:#{arg}"
        @args << full
        @rdata[full] = data.report
      end
      path = File.join(Gem.datadir(PACKAGE),"report.txt.erb")
      if not File.exist?(path)
        path = File.expand_path("../data/diskAudit/report.txt.erb",File.dirname(__FILE__))
      end
      fd = File.open(path)
      template = fd.read
      fd.close
      $log.debug("about to create renderer...")
      renderer = ERB.new(template,nil,">")
      $log.debug("rendering... #{@rdata.length}")
      STDOUT.write(renderer.result(binding))
    end

  end
end
