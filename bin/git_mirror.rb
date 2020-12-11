#!/usr/bin/env ruby

$LOAD_PATH << File.expand_path("../lib", __dir__)

require 'bundler/setup'
require 'manageiq/release'

success = MultiRepo::Operations::GitMirror.new.mirror_all
exit 1 unless success
