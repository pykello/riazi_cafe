require 'erubis'

def templates_dir
    File.join(".", "templates")
end

def tmpl(path)
    File.join(templates_dir, path)
end

def output_dir
    File.join(".", "docs")
end

def outp(path)
    File.join(output_dir, path)
end

def layout_path
    File.join(templates_dir, "layout.html.erb")
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

def generate_index
    output_html = render_with_layout(tmpl('layout.html.erb'), tmpl('index.html.erb'), {})
    File.write(outp('index.html'), output_html)
end

generate_index
