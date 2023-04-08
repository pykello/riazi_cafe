require 'fileutils'
require 'github/markup'
require_relative 'common'

def pages_dir
    File.join(".", "pages")
end

def generate_pages_generic(input_root, output_root)
    generate_page = lambda {|input_root, output_root, subfolder, entry|
        input_path = File.join(input_root, subfolder, entry)
        if entry.match? /html.erb$/
            title = ""
            output_html = render_with_master_layout(input_path, {"title": title})
            output_filename = entry.gsub(".html.erb", ".html")
            output_path = File.join(output_root, subfolder, output_filename)
            File.write(output_path, output_html)
        elsif entry.match? /.md$/
            contents = File.readlines(input_path)
            title = contents.length > 0 ? contents.first.gsub(/#+\s*/, "").strip : ""
            content_html =
                GitHub::Markup.render_s(
                    GitHub::Markups::MARKUP_MARKDOWN,
                    contents.join("\n"))
            output_html = render_with_master_layout_s(content_html, {"title": title})
            output_filename = entry.gsub(".md", ".html")
            output_path = File.join(output_root, subfolder, output_filename)
            File.write(output_path, output_html)
        end

        {
            :subfolder => subfolder,
            :entry => entry,
            :output_filename => output_filename,
            :title => title
        }
    }

    walk_and_generate(input_root, output_root, generate_page)
end

def generate_pages
    generate_pages_generic(pages_dir, output_dir)
end