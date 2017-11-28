# DiskAudit

This application audits disk usage on filesystem partitions.

Broadly speaking, for a list of directories, possibly on multiple hosts, the package generates a report showing, for each directory, how much space each user's files are occupying, with a list of directories that are particularly big.  In addition, it generates lists of broken symbolic links and unreadable directories (since it cannot record disk usage for directories it cannot read).  Optionally, a reduced version of the report can be emailed to a list of users, and a per-user list of broken links and unreadable directories can be mailed to the owner.

### Installation

Either clone the latest from GitHub and unpack it:

```bash
>>>>>>> 756da7a877f832b51bd9ad426fe153da3f8e8152
git clone git@github.com:gdbzork/disk_space_audit.git
cd disk_space_audit
```

or download a tagged release from `https://github.com/gdbzork/disk_space_audit/releases`, unpack it and change to the source directory:

```bash
>>>>>>> 756da7a877f832b51bd9ad426fe153da3f8e8152
tar xf disk_space_audit-N.n.x.tar.gz
cd disk_space_audit-N.n.x
```

Then make sure you have the necessary support packages, build it and install it:
```bash
bundle
gem build diskAudit.gemspec
gem install diskAudit-N.n.x.gem
```

where "N", "n" and "x" are the major release number, minor release number, and
patch level.

Note that "N", "n" and "x" are the major release number, minor release number, and patch level.  In general, the patch level is incremented for bug fixes or documentation changes, the minor release is incremented for backwards-compatible changes, and the major release number is incremented for non-backwards-compatible changes.

### Usage

The overall model of operation is that the report generator will be run on some host machine (typically via a `cron` job), connecting to one or more remote machines (possibly including the host machine), scanning listed directories on the remote machine(s), then generating a report showing the disk usage, by user, on each of the specified paths.  The report may be text or html.  Optionally the report can be mailed to a list of users.  Log messages are written to a specified file on the host.

In addition, the program generates a list of broken symbolic links, and of subdirectories it did not have read access to (and so cannot include in the report).   individual reports of broken links and unreadable directories can be mailed to the owners of the broken paths.

#### Configuration

##### Configuration file

Execution of the package is controlled primarily by a configuration file in YAML syntax (see http://www.yaml.org/).  Sections that should be set are:

`destination` -- the directory to write the results files into.  May also be set on the command line (default: `./tmp`).

`format` -- output format, either "text" or "html".  May also be set on the command line (default: text).

`ssh_user` -- username of the remote user when generating a report for a remote host (default: the current user).

`group_id` -- Unix filesystem group the report is being generated for, so we can report on `lustre` group quotas.

`system_log` -- file to append log messages to (on the local machine) (default: stderr).

`log_level` -- how much logging to do: "debug", "info", "warn", "error" (default: warn).

`admins` -- a list of admin email addresses for warning/error messages.

`targets` -- a list of `host:path` pairs for which to generate reports.

`exclude` -- a list of `host:path` pairs to exclude from the above targets (for example, a target might be `bioinf-srv003:/data` but the report should exclude `bioinf-srv003:/data/reference_data`).

`people` -- a dictionary of `username:email address` pairs who should receive emails when this report is run (if emails are enabled).

`useridMap` -- a map of numeric userids to usernames, to allow the report to name people whose accounts are no longer active, and who therefore are only known by their numeric userid.  (Think of it as a "cheat list" to allow the report to name the guilty, rather than just identifying them by number.)

Following is an example of a configuration file.  Note the difference in syntax between lists (`targets` for example) and maps (`people`).

```YAML
destination: /var/www/html/diskAudit
format: html
ssh_user: brown22
system_log: /var/log/diskAudit/diskAudit.log
log_level: info
admins:
  - Gordon.Brown@cruk.cam.ac.uk
targets:
  - bioinf-srv003:/data
  - sol-srv003:/lustre/mib-cri
  - clust1-headnode:/mnt/scratcha/bioinformatics
  - clust1-headnode:/mnt/scratchb/bioinformatics
exclude:
  - bioinf-srv003:/data/reference_data
people:
  baller01 : Stephane.Ballereau@cruk.cam.ac.uk
  bowers01 : Richard.Bowers@cruk.cam.ac.uk
  brown22 : Gordon.Brown@cruk.cam.ac.uk
useridMap:
  802161580 : howe01
  853250745 : halim01
  899611315 : macart01
```

The default configuration file is stored as part of the package, in `.../data/diskAudit/configuration.yaml`.  An alternative configuration file can be supplied on the command line.

##### Other Configuration

For the package to operate correctly, `ssh` keys must be set up so that the host machine (on which the report is being generated) can remote login to the target machines (for which we want reports) without a password.

Ruby and this gem must be installed on the host and target machines.  The Ruby executable and the top-level program of this gem (`bioinfDiskAudit`) must be in the `PATH` on the target machines.  (In a normal installation, the program will reside in the same directory as the Ruby executable.)

#### Command Line Syntax

The basic syntax of the command line is:

```
bioinfDiskAudit [options] dump|remote|local [<path>]
```

The three subcommands determine overall behaviour:
  * `remote` -- normal mode: communicate with remote hosts and generate a report.
  * `dump` -- this instruction tells the program that it is running on a remote host, to scan a directory hierarchy and return the results to the controller.
  * `local` -- run the program on a local directory.  This is primarily for testing purposes.  The `<path>` parameter is used in local mode to provide the path to examine; it should not be specified in other modes.

Normal usage will only ever use `remote`; the program will invoke its remote copies via `dump`.  

If an option is not specified either in the configuration file or on the command line, then whatever it controls will be omitted.  For example, if no ``people`` are listed, no emails will be sent.  And so on.

Several options control the behaviour of the program (defaults in square brackets).

`--config *file*` -- configuration file to use [`data/diskAudit/configuration.yaml` relative to the installation directory].

`--destination *path*` -- directory in which to write output files [`./tmp`].

`-d|--dump` -- write configuration to stdout (and exit).

`--format text|html` -- output format, text or html [text].

`-h|--help` -- display usage message (and exit).

`--level debug|info|warn|error` -- logging level required [warn].

`--logfile *file*` -- file to append log messages to [stderr].

`--nomail` -- do not send any emails, whatever the configuration might indicate.

`-v|--version` -- write the version of the package to stdout (and exit).

#### Logging

As briefly mentioned above, log messages can be written to a file on the host machine.  The `log_level` parameter in the configuration file determines the level of logging:

  1. `debug` -- debugging messages (very verbose)
  1. `info` -- informative messages (somewhat verbose)
  1. `warn` -- warnings (non-fatal errors)
  1. `error` -- fatal errors (program cannot continue)

As with every other logging system in the world, setting a particular level includes all messages of that *and higher* severity.

### Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

### Contributing

Bug reports are welcome on GitHub at https://github.com/gdbzork/disk_space_audit.


### License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
