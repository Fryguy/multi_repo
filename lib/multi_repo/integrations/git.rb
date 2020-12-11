require "minigit"

require "active_support/core_ext/kernel/reporting"

module MultiRepo
  module Integrations
    class Git
      attr_reader :repo_name, :path

      def initialize(path, repo_name, clone_source = nil)
        @path         = path
        @repo_name    = repo_name
        @clone_source = clone_source

        @git = _ensure_clone
      end

      def clone_source
        @clone_source ||= "git@github.com:#{repo_name}.git"
      end

      def fetch_all
        fetch(:all => true, :tags => true)
      end

      def hard_checkout(branch, source = "origin/#{branch}")
        reset(:hard => true)
        checkout("-B", branch, source)
      end

      def branch?(branch)
        rev_parse("--verify", branch)
        true
      rescue MiniGit::GitError
        false
      end

      def remote?(remote)
        remote("show", remote)
      rescue MiniGit::GitError
        false
      else
        true
      end

      def remote_branch?(remote, branch)
        ls_remote(remote, branch).present?
      end

      def method_missing(method, *args, &block)
        quiet = args.detect { |a| a.is_a?(Hash) && a.key?(:quiet) }&.delete(:quiet)
        quiet = true if quiet.nil?

        @git.send(quiet ? :capturing : :noncapturing).send(method, *args, &block)
      end

      def respond_to_missing(*args)
        @git.respond_to?(*args)
      end

      private

      def _ensure_clone
        retried = false
        MiniGit.debug = true if ENV["GIT_DEBUG"]
        MiniGit.new(path)
      rescue ArgumentError => err
        raise if retried
        raise unless err.message.include?("does not seem to exist")

        _git_clone
        retried = true
        retry
      end

      def _git_clone
        args = ["clone", clone_source, path]
        cmd  = "git #{args.join(" ")}"
        puts "+ #{cmd}" if ENV["GIT_DEBUG"]
        raise MiniGit::GitError.new(args, $?) unless system(cmd)
      end
    end
  end
end
