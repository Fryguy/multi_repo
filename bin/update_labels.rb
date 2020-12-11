#!/usr/bin/env ruby

$LOAD_PATH << File.expand_path("../lib", __dir__)

require 'bundler/setup'
require 'manageiq/release'
require 'optimist'

opts = Optimist.options do
  MultiRepo.common_options(self, :repo_set_default => nil)
end
opts[:repo] = MultiRepo::Operations::Labels.all.keys.sort unless opts[:repo] || opts[:repo_set]

MultiRepo.each_repo(opts) do |repo|
  MultiRepo::Operations::UpdateLabels.new(repo.github_repo, opts).run
end
