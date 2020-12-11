#!/usr/bin/env ruby

$LOAD_PATH << File.expand_path("../lib", __dir__)

require 'bundler/setup'
require 'multi_repo'

opts = MultiRepo::CLI.options(:except => :dry_run) do
  opt :tag, "The tag to destroy", :type => :string, :required => true
end
opts[:repo_set] = opts[:tag].split("-").first unless opts[:repo] || opts[:repo_set]

post_review = StringIO.new

MultiRepo::CLI.each_repo(opts) do |repo|
  next if repo.options.has_real_releases || repo.options.skip_tag

  destroy_tag = MultiRepo::Operations::DestroyTag.new(repo, opts)
  destroy_tag.run
  post_review.puts(destroy_tag.post_review)
end

puts
puts "Run the following script to delete '#{opts[:tag]}' tag from all remote repos"
puts
puts post_review.string
