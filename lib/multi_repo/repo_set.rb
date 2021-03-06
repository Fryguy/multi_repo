require 'yaml'
require 'active_support/core_ext/enumerable'

module MultiRepo
  class RepoSet
    def self.fetch(*args)
      all.fetch(*args)
    end

    def self.[](set_name)
      all[set_name]
    end

    def self.all
      @all ||=
        config.each_with_object({}) do |(set_name, repos), h|
          h[set_name] = repos.map { |name, options| Repo.new(name, options) }
        end
    end

    def self.config
      @config ||= MultiRepo.load_config_file("repos")
    end
    private_class_method :config
  end
end
