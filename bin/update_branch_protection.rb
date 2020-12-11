#!/usr/bin/env ruby

$LOAD_PATH << File.expand_path("../lib", __dir__)

require 'bundler/setup'
require 'multi_repo'

opts = MultiRepo::CLI.options do
  opt :branch, "The branch to protect.", :type => :string, :required => true
end
opts[:repo_set] = opts[:branch] unless opts[:repo] || opts[:repo_set]

MultiRepo::CLI.repos_for(opts).each do |repo|
  next if opts[:branch] != "master" && repo.options.has_real_releases

  puts MultiRepo::CLI.header(repo.name)
  MultiRepo::Operations::UpdateBranchProtection.new(repo.github_repo, opts).run
  puts
end
