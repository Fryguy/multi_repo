#!/usr/bin/env ruby

$LOAD_PATH << File.expand_path("../lib", __dir__)

require 'bundler/setup'
require 'multi_repo'

opts = MultiRepo::CLI.options(:only => :repo_set)

puts MultiRepo::CLI.repos_for(opts).collect(&:name)
