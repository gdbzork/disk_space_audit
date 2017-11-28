# DiskAudit

This application audits disk usage on filesystem partitions.

## Installation

To get the latest from GitHub, clone the repository from GitHub, build it,
and install it:

```bash
git clone git@github.com:gdbzork/disk_space_audit.git
cd disk_space_audit
```

Or to download a tagged release from GitHub, navigate to the "Releases" page on
GitHub, pick the latest (normally), then 

```bash
tar xf disk_space_audit-N.n.x.tar.gz
cd disk_space_audit-N.n.x
```

Then
```bash
bundle
gem build diskAudit.gemspec
gem install diskAudit-N.n.x.gem
```

where "N", "n" and "x" are the major release number, minor release number, and
patch level.

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/diskAudit.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

