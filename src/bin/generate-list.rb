#!/usr/bin/env ruby

require_relative "../lib/pages.rb"
require "json"

def main
    unless (output_path = ARGV.shift)
        puts "expected output_path as argument"
        exit 1
    end

    unless (input_path = ARGV.shift)
        puts "expected input_path as argument"
        exit 1
    end

    metadata = read_metadata(input_path)
    language = metadata["language"]

    if input_path.match? /html$/
        generate_page(output_path, input_path, language)
    elsif input_path.match? /list$/
        generate_list(output_path, input_path, ARGV, language)
    end
end

def generate_list(output_path, input_path, post_paths, language)
    metadata = JSON.parse(File.read(input_path))
    posts = post_paths.map { |file|
        JSON.parse(File.read(file))
    }.sort_by { |v| v["timestamp"] }.reverse

    data = {
        "posts": posts,
        "title": metadata["title"]
    }

    output_html =
        render_with_master_layout(
            tmpl('list.html.erb'),
            data, language)
    File.write(output_path, output_html)
end

main
