module MultiRepo
  module CLI
    #
    # Repos
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
        begin
          MultiRepo::RepoSet.fetch(repo_set)
        rescue KeyError
          Optimist.die(:repo_set, "not found")
        end
      end
    end

    def self.repo_for(repo_name)
      Optimist.die(:repo, "must be specified") if repo.nil?

      org, repo_name = repo_name.split("/").unshift(nil).last(2)
      MultiRepo::Repo.new(repo_name, :org => org)
    end

    #
    # Options
    #

    def self.options(**kwargs, &block)
      require "optimist"
      Optimist.options do
        instance_eval(&block)
        instance_eval(&MultiRepo::CLI.common_options(kwargs))
      end
    end

    def self.common_options(only: %i[repo repo_set dry_run], except: nil, repo_set_default: nil)
      proc do
        banner("")
        banner("Common Options:")

        subset = Array(only).map(&:to_sym) - Array(except).map(&:to_sym)

        if subset.include?(:repo_set)
          opt :repo_set, "The repo set to work with.", :type => :string, :default => repo_set_default, :short => "s"
        end
        if subset.include?(:repo)
          msg = "Individual repo(s) to work with."
          if subset.include?(:repo_set)
            sub_opts = {}
            msg << " Overrides --repo-set."
          else
            sub_opts = {:required => true}
          end
          opt :repo, msg, sub_opts.merge(:type => :strings, :short => "r")
        end
        if subset.include?(:dry_run)
          opt :dry_run, "Execute without making changes.", :default => false, :short => "d"
        end
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
  end
end
