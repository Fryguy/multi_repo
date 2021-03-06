require 'multi_repo/version'

require "active_support/core_ext/object/blank"
require "active_support/core_ext/module/delegation"

require 'multi_repo/cli'
require 'multi_repo/labels'
require 'multi_repo/repo'
require 'multi_repo/repo_set'

require 'pathname'

module MultiRepo
  def self.config_dir
    @config_dir ||= Pathname.new(Dir.pwd).join("config")
  end

  def self.config_dir=(dir)
    @config_dir = Pathname.new(dir)
  end

  def self.repos_dir
    @repos_dir ||= Pathname.new(Dir.pwd).join("repos")
  end

  def self.repos_dir=(dir)
    @repos_dir = Pathname.new(dir)
  end

  #
  # Configuration
  #

  def self.config_files_for(prefix)
    Dir.glob(config_dir.join("#{prefix}*.yml")).sort
  end

  def self.load_config_file(prefix)
    config_files_for(prefix).each_with_object({}) do |f, h|
      h.merge!(YAML.load_file(f))
    end
  end

  #
  # Services
  #

  def self.github(**args)
    @github ||= begin
      require "multi_repo/integrations/github"
      MultiRepo::Integrations::GitHub.new(**args)
    end
  end
end
