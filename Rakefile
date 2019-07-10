#!/usr/bin/env rake
# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

require 'rake/testtask'
Rake::TestTask.new do |t|
  t.libs = %w[lib test]
  t.test_files = FileList['test/**/*_test.rb']
end

task default: :test
