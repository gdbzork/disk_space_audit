require "yaml"

module DiskAudit

  class Configuration

    CONFIG = FILE.expand_path("../../data/diskAudit/configuration.yaml",__FILE__)

    def initialize(path=CONFIG)
      data = YAML.load_file(path)
      @targets = data["targets"]
      @exclude = data["exclude"]
      @people = data["people"]
      @admins = data["admins"]
      @id2name = data["useridMap"]
    end

    def targets()
      return @target
    end

    def exclude()
      return @exclude
    end

    def people()
      return @people
    end

    def admins()
      return @admins
    end

    def id2name()
      return @id2name
    end
  end
end
