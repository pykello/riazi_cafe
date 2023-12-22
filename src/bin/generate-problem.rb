#!/usr/bin/env ruby

require_relative "../lib/problems.rb"
require_relative "../lib/problem_sources.rb"

unless (input_path = ARGV.shift)
    puts "expected input_path as argument"
    exit 1
end

unless (output_path = ARGV.shift)
    puts "expected output_path as argument"
    exit 1
end

match = input_path.match(/problems\/(.*?)\//)
language = match[1] if match

source_info = generate_problem_sources
problem_info = parse_problem(input_path, source_info, true)
render_problem(problem_info, output_path, language)
