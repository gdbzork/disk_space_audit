require "etc"

module DiskAudit
  # The version of the module, unsurprisingly.
  VERSION = "1.1.0"
  # The package name.
  PACKAGE = "diskAudit"

  PROGNAME = "bioinfDiskAudit"
  REPORTNAME = "diskReport.html"
  SORTTABLE = "sorttable.js"
  CSSNAME = "report.css"
  LOGTEMPLATE = "logs_%s.html"

  # User configuration default values
  CONFIG_FILE_DEFAULT = "../../../data/diskAudit/configuration.yaml"
  CONFIG_DEFAULTS = {config_file: File.expand_path(CONFIG_FILE_DEFAULT,__FILE__),
                     format: :text,
                     destination: "./tmp",
                     ssh_user: Etc.getlogin,
                     log_level: :info}
  
end
