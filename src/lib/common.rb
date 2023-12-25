require 'fileutils'
require 'erubis'
require 'github/markup'
require_relative 'config.rb'

def suppress_stdout
    original_stdout = $stdout  # Preserve the original stdout
    $stdout = File.new('/dev/null', 'w')  # Redirect stdout to /dev/null
    yield
ensure
    $stdout = original_stdout  # Restore the original stdout
end

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

def read_metadata(input_path)
    path_parts = input_path.split('/')
    metadata = {}
    path_parts.size.times do |i|
        current_dir = path_parts[0...i].join('/')
        metadata_file = File.join(current_dir, 'metadata.json')
        if File.exist?(metadata_file)
            content = JSON.parse(File.read(metadata_file))
            metadata.update(content)
        end
    end
    metadata
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
