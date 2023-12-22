#!/usr/bin/env ruby

require_relative "../lib/problems.rb"
require_relative "../lib/problem_sources.rb"

source_info = generate_problem_sources

['en', 'fa'].each {|language|
    problems = get_problems_info(source_info, language, render_content: false)
    generate_problem_list_page(problems, language)
}

puts Dir.pwd
