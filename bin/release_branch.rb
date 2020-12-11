#!/usr/bin/env ruby

$LOAD_PATH << File.expand_path("../lib", __dir__)

require 'bundler/setup'
require 'multi_repo'

opts = MultiRepo::CLI.options(:except => :dry_run) do # TODO: Implement dry_run
  opt :branch, "The new branch name.", :type => :string, :required => true
end

review = StringIO.new
post_review = StringIO.new

MultiRepo::CLI.repos_for(opts).each do |repo|
  next if repo.options.has_real_releases

  release_branch = MultiRepo::Operations::ReleaseBranch.new(repo, opts)

  puts MultiRepo::CLI.header("Branching #{repo.name}")
  release_branch.run
  puts

  review.puts MultiRepo::CLI.header(repo.name)
  review.puts release_branch.review
  review.puts
  post_review.puts release_branch.post_review
end

puts
puts MultiRepo::CLI.separator
puts
puts "Review the following:"
puts
puts review.string
puts
puts "If all changes are correct,"
puts "  run the following script to push all of the new branches"
puts
puts post_review.string
puts
puts "Once completed, be sure to follow the rest of the release checklist."
