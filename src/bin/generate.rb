#!/usr/bin/env ruby

require_relative "../lib/blog.rb"
require_relative "../lib/pages.rb"
require_relative "../lib/problems.rb"
require "json"

def main
    unless (output_path = ARGV.shift)
        puts "expected input_path as argument"
        exit 1
    end

    input_paths = ARGV
    unless (input_paths.length > 0)
        puts "expected input_paths as argument"
        exit 1
    end

    metadata = read_metadata(input_paths.first)
    language = metadata["language"]

    path_parts = output_path.split("/")
    url = "/" + path_parts[1..].join("/")

    case metadata["type"]
    when "blogpost"
        blogpost = parse_blogpost(input_paths.first, url)
        render_blogpost(blogpost, output_path)
    when "problem"
        problem = parse_problem(input_paths, url)
        render_problem(problem, output_path, language)
    when "page"
        generate_page(output_path, input_paths.first, language)
    end
end

main
