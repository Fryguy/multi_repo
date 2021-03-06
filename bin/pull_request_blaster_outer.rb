#!/usr/bin/env ruby

$LOAD_PATH << File.expand_path("../lib", __dir__)

require 'bundler/setup'
require 'multi_repo'

opts = MultiRepo::CLI.options do
  opt :base,    "The target branch for the changes.",                         :type => :string, :required => true
  opt :head,    "The name of the branch to create on your fork.",             :type => :string, :required => true
  opt :script,  "The path to the script that will update the desired files.", :type => :string, :required => true
  opt :message, "The commit message and PR title for this change.",           :type => :string, :required => true
end

results = {}
MultiRepo::CLI.each_repo(opts) do |repo|
  results[repo.github_repo] = MultiRepo::Operations::PullRequestBlasterOuter.new(repo, opts).blast
end

require 'pp'
pp results
