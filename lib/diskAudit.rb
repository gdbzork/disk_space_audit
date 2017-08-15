require "find"
require "net/ssh"
require "date"
require "mail"
require "socket"

require "diskAudit/auditData"
require "diskAudit/constants"

# Audits a path or paths on disk, reporting disk usage by user.
#
# The top-level class that does most of the work is {DiskAudit}.  The
# top-level program just parses the command line and invokes the appropriate
# method in this class.
# 
# The main data structure for storing the results is {AuditData}.  It
# accumulates the main data that the gem collects, and processes it into
# a form that is suitable for the reports to be generated.
#
# @author Gord Brown
module DiskAudit

  # Top-level class to carry out an audit, and ultimately generate a report.
  class DiskAudit

    def initialize(options)
      options.logfile = DiskAudit::LOGFILE if options.logfile.nil?
      @logger = Logger.new(options.logfile)
    end

    # Audits a path.
    # @param path [String] the string representation of the path to audit
    # @return [AuditData] the results of the audit for this path
    def audit(data)
      data.info.setStart
      path = data.info.path
      Find.find(path) do |p|
        if FileTest.symlink?(p)
          data.add(p)
          begin
            File.stat(p)
          rescue
            data.log.broken_link(p)
          end
          Find.prune
        elsif FileTest.file?(p)
          data.add(p)
        else
          if not FileTest.readable?(p)
            data.log.denied(p)
          else
            data.add(p)
          end
        end
      end
      data.mkBigDirs()
      data.info.setDone
    end

    def generate_report(options,args,rdata)
      template_path = Gem.datadir(PACKAGE)
      if not File.exist?(template_path)
        template_path = File.expand_path("../data/diskAudit",File.dirname(__FILE__))
      end

      if options.format == :html
        if options.target != '-'
          js = File.join(template_path,"sorttable.js")
          css = File.join(template_path,"report.css")
          FileUtils.cp(js,options.target)
          FileUtils.cp(css,options.target)
        end
        path = File.join(template_path,"report.html.erb")
      else
        path = File.join(template_path,"report.txt.erb")
      end
      fd = File.open(path)
      template = fd.read
      fd.close

      mailPath = File.join(template_path,"mailreport.txt.erb")
      fd = File.open(mailPath)
      mailTemplate = fd.read
      fd.close

      @date = Date.today.iso8601
      @args = args
      @rdata = rdata
      renderer = ERB.new(template,nil,">")
      if options.target == '-'
        outFD = STDOUT
      else
        outFD = File.open(File.join(options.target,REPORTNAME),"w")
      end
      body = renderer.result(binding)
      mailRenderer = ERB.new(mailTemplate,nil,">")
      mailBody = mailRenderer.result(binding)
      outFD.write(body)
      if options.target != '-'
        outFD.close()
      end
      if !options.mailto.nil?
        mailReport(mailBody,options.mailto)
      end

      # get logs template
      if options.format == :html
        tempNm = "logreport.html.erb"
      else
        tempNm = "logreport.txt.erb"
      end
      log_template_path = File.join(template_path,tempNm)
      fd = File.open log_template_path
      template = fd.read
      fd.close
      renderer = ERB.new(template,nil,">")

      # write log files
      @rdata.each do |tag,data|
        vtag = tag.gsub("/","_")
        if options.target == '-'
          fd = STDOUT
        else
          fd = File.open(File.join(options.target,LOGTEMPLATE % [vtag]),"w")
        end
        txt = renderer.result(data.log.getBinding)
        fd.write(txt)
        if options.target != '-'
          fd.close
        end
      end
    end

    def mailReport(text,addresses)
      opts = {address: "10.20.221.14",
              port: 25,
              domain: "cruk.cam.ac.uk",
              authentication: "plain",
              tls: false,
              enable_starttls_auto: false}
      Mail.defaults do
        delivery_method :smtp, opts
      end
      targets = addresses.split(",")
      Mail.deliver do
        from    "diskAudit@#{Socket.gethostname}"
        to      targets
        subject "disk space audit"
        body    text
      end
    end

    def dump(path,options)
      tag = "#{`hostname`.strip}:#{path}"
      if not File.exist?(path)
        STDERR.write("No such path: '#{path}'...\n")
        return
      end
      data = AuditData.new(tag,path)
      audit(data)
      Marshal.dump(data,STDOUT)
    end

    def execute_remote(paths,options)
      data = {}
      paths.each do |arg|
        components = arg.split(":")
        Net::SSH.start(components[0],options.user) do |ssh|
          raw = ssh.exec!("#{PROGNAME} dump #{components[1]}")
          begin
            data[arg] = Marshal.load(raw)
          rescue
            STDERR.puts("Got unexpected result from '#{arg}': #{raw}")
          end
        end
      end
      args = []
      rdata = {}
      data.each do |k,v|
        args << k
        v.prepare
        rdata[k] = v
      end
      generate_report(options,args,rdata)
    end

    def execute_local(path,options)
      begin
        tag = "#{`hostname`.strip}:#{path}"
        data = AuditData.new(tag,path)
        audit(data)
        data.prepare # generate report-formatted data

        args = [tag]
        rdata = {tag => data}
        generate_report(options,args,rdata)

      rescue Errno::ENOENT => noent
        STDERR.puts "Path not found: '#{path}'"
        STDERR.puts noent.to_s
      end
    end

  end
end
