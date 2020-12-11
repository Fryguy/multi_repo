#!/usr/bin/env ruby

$LOAD_PATH << File.expand_path("../lib", __dir__)

require 'bundler/setup'
require 'multi_repo'

opts = MultiRepo::CLI.options do
  opt :tag,    "The new tag name.",       :type => :string, :required => true
  opt :branch, "The branch to tag from.", :type => :string
  opt :skip,   "The repo(s) to skip.",    :type => :strings
end
opts[:branch] ||= opts[:tag].split("-").first
opts[:repo_set] = opts[:branch] unless opts[:repo] || opts[:repo_set]

review = StringIO.new
post_review = StringIO.new

# Move manageiq repo to the end of the list.  The rake release script on manageiq
#   depends on all of the other repos running their rake release scripts first.
repos = MultiRepo::CLI.repos_for(opts)
repos = repos.partition { |r| r.github_repo != "ManageIQ/manageiq" }.flatten

repos.each do |repo|
  next if Array(opts[:skip]).include?(repo.name)
  next if repo.options.has_real_releases || repo.options.skip_tag

  release_tag = MultiRepo::Operations::ReleaseTag.new(repo, opts)

  puts MultiRepo::CLI.header("Tagging #{repo.name}")
  release_tag.run
  puts

  review.puts MultiRepo::CLI.header(repo.name)
  review.puts release_tag.review
  review.puts
  post_review.puts release_tag.post_review
end

puts
puts MultiRepo::CLI.separator
puts
puts "Review the following:"
puts
puts review.string
puts
puts "If the tags are all correct,"
puts "  run the following script to push all of the new tags"
puts
puts post_review.string
puts
