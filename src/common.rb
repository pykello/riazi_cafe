require 'fileutils'
require 'erubis'
require 'github/markup'

def tmpl(path)
    File.join(File.join(".", "templates"), path)
end

def output_dir
    File.join(".", "docs")
end

def render_with_layout(layout_path, template_path, data)
    layout_template = File.read(layout_path)
    content_template = File.read(template_path)

    content_erb = Erubis::Eruby.new(content_template)
    content_html = content_erb.result(data)

    layout_erb = Erubis::Eruby.new(layout_template)
    layout_html = layout_erb.result(data.merge({content: content_html}))

    layout_html
end

def render_with_master_layout(template_path, data)
    render_with_layout(tmpl("layout.html.erb"), template_path, data)
end

#
# Walks recursively in input_root, and for each file calls
# generate_lambda(input_root, output_root, subfolder, filename).
# Returns results of all function calls in an array.
#
def walk_and_generate(input_root, output_root, generate_lambda)
    worker = lambda do |subfolder, recurse|
        input_files_path = File.join(input_root, subfolder)
        output_files_path = File.join(output_root, subfolder)

        FileUtils.mkdir_p(output_files_path)

        entries = Dir.entries(input_files_path)

        files = entries.filter { |entry|
                    File.file? File.join(input_files_path, entry)
                }

        subfolders = entries.filter { |entry|
                        entry != '.' && entry != '..' &&
                        (File.directory? File.join(input_files_path, entry))
                    }
        
        results = []

        subfolders.each do |entry|
            results = results + recurse.call(File.join(subfolder, entry), recurse)
        end

        files.each do |entry|
            results.append(generate_lambda.call(input_root, output_root, subfolder, entry))
        end

        return results
    end

    worker.call('', worker)
end
