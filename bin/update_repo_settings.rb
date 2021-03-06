#!/usr/bin/env ruby

$LOAD_PATH << File.expand_path("../lib", __dir__)

require 'bundler/setup'
require 'multi_repo'

opts = MultiRepo::CLI.options

MultiRepo::CLI.each_repo(opts) do |repo|
  MultiRepo::Operations::UpdateRepoSettings.new(repo.github_repo, opts).run
end
