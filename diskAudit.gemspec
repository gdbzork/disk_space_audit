# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'diskAudit/version'

Gem::Specification.new do |spec|
  spec.name          = "diskAudit"
  spec.version       = DiskAudit::VERSION
  spec.authors       = ["Gord Brown"]
  spec.email         = ["gordon.brown@cruk.cam.ac.uk"]

  spec.summary       = %q{Collect information about users' disk usage.}
  spec.description   = %q{This program traverses a directory tree, collecting
                          information about users' disk usage, including what
                          directories are large, and what sorts of files are
                          taking up space (e.g. BAM, fastq).}
  spec.homepage      = "https://github.com/gdbzork"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = ["bioinfDiskAudit"]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
