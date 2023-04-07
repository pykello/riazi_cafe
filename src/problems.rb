require 'fileutils'
require 'github/markup'
require_relative 'common'

def problems_dir
    File.join(".", "problems")
end

def generate_problem_list_page(problems)
    data = {
        "problems": problems,
    }
    output_html =
        render_with_master_layout(
            tmpl('problem-list.html.erb'),
            data)
    File.write(File.join(output_dir, 'problem-list.html'), output_html)
end

def generate_problem_pages
    generate_problem = lambda {|input_root, output_root, subfolder, entry|
        entry_html = entry.gsub(".md", ".html")
        problem_path = File.join(input_root, subfolder, entry)
        output_path = File.join(output_root, subfolder, entry_html)
        structure = render_problem(problem_path, output_path)
        structure["path"] = File.join('problems', subfolder, entry_html)
        structure
    }

    output_root = File.join(output_dir, 'problems')
    walk_and_generate(problems_dir, output_root, generate_problem)
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
        render_with_master_layout(
            tmpl('problem.html.erb'),
            data)
    File.write(output_path, output_html)
    structure
end
