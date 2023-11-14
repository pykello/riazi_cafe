require 'fileutils'
require 'erubis'
require 'github/markup'
require_relative 'config.rb'

def numfa(num)
    if num == 0
        return "۰"
    end
    result = ""
    while num > 0
        result = "۰۱۲۳۴۵۶۷۸۹"[num%10] + result
        num = num / 10
    end
    result
end

def tmpl(path)
    File.join(File.join(".", "templates"), path)
end

def output_dir
    File.join(".", "docs")
end

def render_with_layout_s(layout_path, content_html, data)
    layout_template = File.read(layout_path)
    layout_erb = Erubis::Eruby.new(layout_template)
    layout_html = layout_erb.result(data.merge({content: content_html}))

    layout_html
end

def render_with_layout(layout_path, template_path, data)
    content_template = File.read(template_path)
    content_erb = Erubis::Eruby.new(content_template)
    content_html = content_erb.result(data)

    render_with_layout_s(layout_path, content_html, data)
end

def render_with_master_layout(template_path, data, language="fa")
    render_with_layout(
        tmpl("layout.html.erb"),
        template_path,
        data.merge({
            'config' => config,
            'language' => language,
            'dir' => language == "fa" ? "rtl" : "ltr"
        }))
end

def render_with_master_layout_s(content, data, language="fa")
    render_with_layout_s(
        tmpl("layout.html.erb"),
        content,
        data.merge({
            'config' => config,
            'language' => language,
            'dir' => language == "fa" ? "rtl" : "ltr"
        }))
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
            result = generate_lambda.call(input_root, output_root, subfolder, entry)
            results.append(result) if result
        end

        return results
    end

    worker.call('', worker)
end

def translate(s, language)
    return s if language == "en"
    m = {
        "Home" => "صفحه اصلی",
        "Problems" => "لیست مساله‌ها",
        "Suggest A Problem" => "پیشنهاد مساله",
        "Blog" => "وبلاگ",
        "Riazi Cafe" => "کافه ریاضی",
        "Problem Statement" => "صورت مساله",
        "Hint" => "راهنمایی",
        "Solution" => "راه‌حل"
    }
    return m[s].nil? ? s : m[s]
end
