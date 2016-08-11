require "find"
require "net/ssh"
require "date"

require "diskAudit/auditData"
require "diskAudit/constants"

# Audits a path or paths on disk, reporting disk usage by user.
#
# @author Gord Brown
module DiskAudit

  # Top-level class to carry out an audit, and ultimately generate a report.
  class DiskAudit

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

      @date = Date.today.iso8601
      @args = args
      @rdata = rdata
      STDERR.puts("raw data len: #{@rdata.length}")
      STDERR.puts("raw data 0: #{@rdata[0].class}")
      renderer = ERB.new(template,nil,">")
      if options.target == '-'
        outFD = STDOUT
      else
        outFD = File.open(File.join(options.target,REPORTNAME),"w")
      end
      outFD.write(renderer.result(binding))
      if options.target != '-'
        outFD.close()
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
        fd.write(renderer.result(data.log.getBinding))
        if options != '-'
          fd.close
        end
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
