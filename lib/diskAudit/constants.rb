require "etc"

module DiskAudit
  # The version of the module, unsurprisingly.
  VERSION = "2.0.2"
  # The package name.
  PACKAGE = "diskAudit"
  # The name of the executable program.
  PROGNAME = "bioinfDiskAudit"
  # The name of the HTML report.
  REPORTNAME = "diskReport.html"
  # The Javascript to make sortable tables.
  SORTTABLE = "sorttable.js"
  # The filename of the CSS for report formatting.
  CSSNAME = "report.css"
  # The template for log file names, for the HTML report.
  LOGTEMPLATE = "logs_%s.html"
  # Default path to configuration file.
  CONFIG_FILE_DEFAULT = "../../../data/diskAudit/configuration.yaml"
  # Configuration defaults.
  CONFIG_DEFAULTS = {config_file: File.expand_path(CONFIG_FILE_DEFAULT,__FILE__),
                     format: :text,
                     destination: "./tmp",
                     ssh_user: Etc.getlogin,
                     log_level: :info}
end
