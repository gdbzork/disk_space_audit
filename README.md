# DiskAudit

This application audits disk usage on filesystem partitions.

Broadly speaking, for a list of directories, possibly with host names, the package generates a report showing, for each directory, how much space each user's files are occupying, with a list of directories that are particularly big.  In addition, it generates lists of broken symbolic links and unreadable directories (since it cannot record disk usage for directories it cannot read).  Optionally, a reduced version of the report can be emailed to a list of users, and a per-user list of broken links and unreadable directories can be mailed to the owner.

## Installation

Either clone the latest from GitHub and unpack it:

```
git clone git@github.com:gdbzork/disk_space_audit.git
cd disk_space_audit
```

or download a tagged release from `https://github.com/gdbzork/disk_space_audit/releases`, unpack it and change to the source directory:

```
tar xf disk_space_audit-N.n.x.tar.gz
cd disk_space_audit-N.n.x
```

Then make sure you have the necessary support packages, build it and install it.

```
bundle
gem build diskAudit.gemspec
gem install diskAudit-N.n.x.gem
```

Note that "N", "n" and "x" are the major release number, minor release number, and patch level.  In general, the patch level is incremented for bug fixes or documentation changes, the minor release is incremented for backwards-compatible changes, and the major release number is incremented for non-backwards-compatible changes.

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/gdbzork/disk_space_audit.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
