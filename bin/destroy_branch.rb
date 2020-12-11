#!/usr/bin/env ruby

$LOAD_PATH << File.expand_path("../lib", __dir__)

require 'bundler/setup'
require 'multi_repo'

opts = MultiRepo::CLI.options(:except => :dry_run) do
  opt :branch, "The branch to destroy.", :type => :string, :required => true
end

MultiRepo::CLI.each_repo(opts) do |repo|
  repo.checkout("master")
  repo.git.branch("-D", opts[:branch])
end
