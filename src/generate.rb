require 'fileutils'
require_relative 'common'
require_relative 'problems'

def main
    problems = generate_problem_pages
    generate_problem_list_page(problems)
    generate_pages
end

def pages_dir
    File.join(".", "pages")
end

def generate_pages
    generate_page = lambda {|input_root, output_root, subfolder, entry|
        input_path = File.join(input_root, subfolder, entry)
        if entry.match? /html.erb$/
            output_html = render_with_master_layout(input_path, {})
            output_filename = entry.gsub(".html.erb", ".html")
            output_path = File.join(output_root, subfolder, output_filename)
            File.write(output_path, output_html)
        end
        ""
    }

    walk_and_generate(pages_dir, output_dir, generate_page)
end

main
