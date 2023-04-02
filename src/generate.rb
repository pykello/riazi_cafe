require 'erubis'
require 'github/markup'

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

def problems_dir
    File.join(".", "problems")
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

def parse_problem(path)
    contents = File.readlines(File.join(problems_dir, path)).map { _1.strip }
    contents.append("# end")
    structure = {
        :title => nil,
        :source => nil,
        :tags => [],
        :difficulty => nil,
        :statement => nil,
        :hints => [],
        :solutions => []
    }

    def process_section(name, contents, structure)
        case name
        when 'title' then
            structure[:title] = contents.join(" ")
        when 'source' then
            if not contents.empty? and contents[0].length > 0
                structure[:source] = contents[0]
            end
        when 'tags' then
            structure[:tags] = contents
        when 'difficulty' then
            if not contents.empty? and contents[0].length > 0
                structure[:difficulty] = contents[0]
            end
        when 'statement' then
            structure[:statement] =
                GitHub::Markup.render_s(
                    GitHub::Markups::MARKUP_MARKDOWN,
                    contents.join("\n"))
        when 'hint' then
            structure[:hints].append(
                GitHub::Markup.render_s(
                    GitHub::Markups::MARKUP_MARKDOWN,
                    contents.join("\n")))
        when 'solution' then
            structure[:solutions].append(
                GitHub::Markup.render_s(
                    GitHub::Markups::MARKUP_MARKDOWN,
                    contents.join("\n")))
        end
    end

    current_section = nil
    current_content = []
    contents.each { |line|
        if line.start_with? "# "
            if not current_section.nil?
                process_section(current_section, current_content, structure)
            end
            current_section = line.downcase[2..]
            current_content = []
        else
            current_content.append(line)
        end
    }
end

def render_problem(path)
    structure = parse_problem(path)
    print structure
end

def generate_problems(subfolder='')

end


generate_index
render_problem("stanford-problem-book/47.1.page-numbers.md")