#!/usr/bin/env ruby

$LOAD_PATH << File.expand_path("../lib", __dir__)

require 'bundler/setup'
require 'multi_repo'

opts = MultiRepo::CLI.options do
  opt :title,  "The milestone title.",            :type => :string, :required => true
  opt :due_on, "The due date.",                   :type => :string
  opt :close,  "Whether to close the milestone.", :default => false
end
Optimist.die(:due_on, "is required") if !opts[:close] && !opts[:due_on]
Optimist.die(:due_on, "must be a date format") if opts[:due_on] && !MultiRepo::Operations::UpdateMilestone.valid_date?(opts[:due_on])

MultiRepo::CLI.each_repo(opts) do |repo|
  MultiRepo::Operations::UpdateMilestone.new(repo, opts).run
end
