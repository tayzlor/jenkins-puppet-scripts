#!/usr/bin/env ruby

# Run this file at the top of your git branch and it will get
# a list of yaml files that have changed compared to a remote branch
# and then check the yaml syntax of those files.
#
# If you don't supply a remote branch as an argument, then
# origin/develop will be used
#
# Example output
#
# git_check_yaml.rb
# YAML_SYNTAX:hieradata/common/zeus.yaml:ERROR:25:1:found character that cannot start any token - line 25, column 1
#
require "pp"
require "yaml"

def check_file(filename)
  begin
    r = YAML.load_file(filename)
      rescue Errno::ENOENT => ex
        $stderr.print "YAML_SYNTAX:#{filename}:ERROR:0:0:File does not exist!\n"
        status = 1
      rescue Psych::SyntaxError => ex
        $stderr.print "YAML_SYNTAX:#{filename}:ERROR:#{ex.line}:#{ex.column}:#{ex.problem} - line #{ex.line}, column #{ex.column}\n"
        status = 1
      rescue Exception => ex
        $stderr.print "YAML_SYNTAX:#{filename}:ERROR:0:0:Unknown error: #{ex.message}\n"
  end

  unless status == 1 or r.is_a?(Hash)
    $stderr.print "YAML_SYNTAX:#{filename}:ERROR:0:0:YAML file does not contain a hash\n"
    status = 1
  end
end

def yaml_files(branch)
  file_list = %x(git diff --name-only --diff-filter=AMCR #{branch}).split("\n").grep(/\.(yaml|yml)$/)
  return file_list
end


branch = ARGV[0] || "origin/develop"
files = yaml_files(branch)
files.each do |file|
  if File.directory?(file)
    $stdout.print "YAML_SYNTAX:#{file}:INFO:Is a directory. Scanning for *.yaml\n"
    Dir.glob("#{file}/**/*.yaml").each do |f|
      s = check_file(f)
      status = s unless s == 0

    end
  else
    s = check_file(file)
    status = s unless s == 0
  end
end
