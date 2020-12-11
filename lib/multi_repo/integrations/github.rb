require "octokit"

module MultiRepo
  module Integrations
    class GitHub
      def self.api_token
        @api_token ||= ENV["GITHUB_API_TOKEN"]
      end

      def self.api_token=(token)
        @api_token = token
      end

      def self.api_endpoint
        @api_endpoint ||= ENV["GITHUB_API_ENDPOINT"]
      end

      def self.api_endpoint=(endpoint)
        @api_endpont = endpoint
      end

      def self.default_params
        {
          :access_token  => api_token,
          :api_endpoint  => api_endpoint,
          :auto_paginate => true
        }.compact
      end

      attr_reader :client

      def initialize(**args)
        args = self.class.default_params.merge(args)
        raise ArgumentError, "Missing GitHub API Token" unless args[:access_token]

        require 'octokit'
        @client = Octokit::Client.new(args)
      end

      delegate_missing_to :@client

      def active_repos(org)
        list_repositories(org, :type => "sources").reject { |r| r.fork? || r.archived? }
      end

      def active_repo_names(org)
        active_repos(org).map { |r| "#{org}/#{r.name}" }
      end
    end
  end
end
