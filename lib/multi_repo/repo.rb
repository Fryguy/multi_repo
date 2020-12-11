require "ostruct"
require "multi_repo/integrations/git"

module MultiRepo
  class Repo
    attr_reader :name, :options, :path

    def initialize(name, options = nil)
      @name    = name
      @options = OpenStruct.new(options || {})
      @path    = REPOS_DIR.join(github_repo)
    end

    def chdir
      Dir.chdir(path) { yield }
    end

    def github_repo
      if name.include?("/")
        name
      else
        [options.org || "ManageIQ", name].join("/")
      end
    end

    def git
      @git ||= MultiRepo::Integrations::Git.new(path, github_repo, options.clone_source)
    end

    delegate_missing_to :git

    def fetch
      git.fetch_all
    end

    def checkout(branch, source = "origin/#{branch}")
      git.hard_checkout(branch, source)
    end

    def write_file(file, content, dry_run: false, **kwargs)
      if dry_run
        puts "** dry-run: Writing #{path.join(file).expand_path}"
      else
        File.write(file, content, kwargs.merge(:chdir => path))
      end
    end

    def rm_file(file, dry_run: false)
      return unless File.exist?(path.join(file))
      if dry_run
        puts "** dry-run: Removing #{path.join(file).expand_path}"
      else
        Dir.chdir(path) { FileUtils.rm_f(file) }
      end
    end

    def detect_readme_file
      Dir.chdir(path) do
        %w[README.md README README.txt].detect do |f|
          File.exist?(f)
        end
      end
    end
  end
end
