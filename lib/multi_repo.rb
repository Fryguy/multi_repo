require 'multi_repo/version'

require "active_support/core_ext/object/blank"
require "active_support/core_ext/module/delegation"

require 'multi_repo/labels'
require 'multi_repo/repo'
require 'multi_repo/repo_set'

require 'pathname'

module MultiRepo
  CONFIG_DIR = Pathname.new("../../config").expand_path(__dir__)
  REPOS_DIR = Pathname.new("../../repos").expand_path(__dir__)

  #
  # CLI helpers
  #

  def self.each_repo(**kwargs)
    raise "no block given" unless block_given?

    repos_for(**kwargs).each do |repo|
      puts header(repo.github_repo)
      yield repo
      puts
    end
  end

  def self.repos_for(repo: nil, repo_set: nil, **_)
    Optimist.die("options --repo or --repo_set must be specified") unless repo || repo_set

    if repo
      Array(repo).map { |n| repo_for(n) }
    else
      MultiRepo::RepoSet[repo_set]
    end
  end

  def self.repo_for(repo)
    Optimist.die(:repo, "must be specified") if repo.nil?

    org, repo_name = repo.split("/").unshift(nil).last(2)
    MultiRepo::Repo.new(repo_name, :org => org)
  end

  def self.common_options(optimist, only: %i[repo repo_set dry_run], except: nil, repo_set_default: "master")
    optimist.banner("")
    optimist.banner("Common Options:")

    subset = Array(only).map(&:to_sym) - Array(except).map(&:to_sym)

    if subset.include?(:repo_set)
      optimist.opt :repo_set, "The repo set to work with.", :type => :string, :default => repo_set_default, :short => "s"
    end
    if subset.include?(:repo)
      msg = "Individual repo(s) to work with."
      if subset.include?(:repo_set)
        sub_opts = {}
        msg << " Overrides --repo-set."
      else
        sub_opts = {:required => true}
      end
      optimist.opt :repo, msg, sub_opts.merge(:type => :strings)
    end
    if subset.include?(:dry_run)
      optimist.opt :dry_run, "Execute without making changes.", :default => false
    end
  end

  #
  # Logging helpers
  #

  HEADER = ("=" * 80).freeze
  SEPARATOR = ("*" * 80).freeze

  def self.header(title)
    title = " #{title} "
    start = (HEADER.length / 2) - (title.length / 2)
    HEADER.dup.tap { |h| h[start, title.length] = title }
  end

  def self.separator
    SEPARATOR
  end

  #
  # Configuration
  #

  def self.config_files_for(prefix)
    Dir.glob(CONFIG_DIR.join("#{prefix}*.yml")).sort
  end

  def self.load_config_file(prefix)
    config_files_for(prefix).each_with_object({}) do |f, h|
      h.merge!(YAML.load_file(f))
    end
  end

  def self.github_api_token
    @github_api_token ||= ENV["GITHUB_API_TOKEN"]
  end

  def self.github_api_token=(token)
    @github_api_token = token
  end

  #
  # Services
  #

  def self.github
    @github ||= begin
      raise "Missing GitHub API Token" if github_api_token.nil?

      require 'octokit'
      Octokit::Client.new(
        :access_token  => github_api_token,
        :auto_paginate => true
      )
    end
  end

  def self.github_repo_names_for(org)
    github
      .list_repositories(org, :type => "sources")
      .reject { |r| r.fork? || r.archived? }
      .map { |r| "#{org}/#{r.name}" }
  end
end
