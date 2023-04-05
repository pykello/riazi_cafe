require 'fileutils'
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

def pages_dir
    File.join(".", "pages")
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
    data = {}
    output_html =
        render_with_layout(
            tmpl('layout.html.erb'),
            tmpl('index.html.erb'),
            data)
    File.write(outp('index.html'), output_html)
end

def generate_problem_list(problems)
    data = {
        "problems": problems,
    }
    output_html =
        render_with_layout(
            tmpl('layout.html.erb'),
            tmpl('problem-list.html.erb'),
            data)
    File.write(outp('problem-list.html'), output_html)
end

def parse_problem(path)
    contents = File.readlines(path).map { _1.strip }
    contents.append("# end")
    structure = {
        "title" => nil,
        "source" => nil,
        "tags" => [],
        "difficulty" => nil,
        "statement" => nil,
        "hints" => [],
        "solutions" => []
    }

    def process_section(name, contents, structure)
        case name
        when 'title' then
            structure["title"] = contents.join(" ")
        when 'source' then
            if not contents.empty? and contents[0].length > 0
                structure["source"] = contents[0]
            end
        when 'tags' then
            structure["tags"] = contents
        when 'difficulty' then
            if not contents.empty? and contents[0].length > 0
                structure["difficulty"] = contents[0]
            end
        when 'statement' then
            structure["statement"] =
                GitHub::Markup.render_s(
                    GitHub::Markups::MARKUP_MARKDOWN,
                    contents.join("\n"))
        when 'hint' then
            structure["hints"].append(
                GitHub::Markup.render_s(
                    GitHub::Markups::MARKUP_MARKDOWN,
                    contents.join("\n")))
        when 'solution' then
            structure["solutions"].append(
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
    structure
end

def render_problem(problem_path, output_path)
    structure = parse_problem(problem_path)
    data = {
        "problem": structure
    }
    output_html =
        render_with_layout(
            tmpl('layout.html.erb'),
            tmpl('problem.html.erb'),
            data)
    File.write(output_path, output_html)
    structure
end

def walk_and_generate(input_root, output_root, subfolder, process_f)
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
        results =
        results +
            walk_and_generate(
                input_root,
                output_root,
                File.join(subfolder, entry),
                process_f)
    end

    files.each do |entry|
        results.append(process_f.call(input_root, output_root, subfolder, entry))
    end

    return results
end

def generate_problems
    generate_problem = lambda {|input_root, output_root, subfolder, entry|
        entry_html = entry.gsub(".md", ".html")
        problem_path = File.join(input_root, subfolder, entry)
        output_path = File.join(output_root, subfolder, entry_html)
        structure = render_problem(problem_path, output_path)
        structure["path"] = File.join('problems', subfolder, entry_html)
        structure
    }

    output_root = File.join(output_dir, 'problems')
    walk_and_generate(problems_dir, output_root, '', generate_problem)
end

def generate_pages
    generate_page = lambda {|input_root, output_root, subfolder, entry|
        input_path = File.join(input_root, subfolder, entry)
        if entry.match? /html.erb$/
            output_html = render_with_layout(tmpl('layout.html.erb'), input_path, {})
            output_filename = entry.gsub(".html.erb", ".html")
            output_path = File.join(output_root, subfolder, output_filename)
            File.write(output_path, output_html)
        end
        ""
    }

    walk_and_generate(pages_dir, output_dir, '', generate_page)
end

problems = generate_problems
generate_problem_list(problems)
generate_pages
generate_index
