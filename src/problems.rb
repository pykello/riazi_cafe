require 'fileutils'
require 'github/markup'
require 'date'
require_relative 'common'

def problems_dir
    File.join(".", "problems")
end

def generate_problem_list_page(problems)
    data = {
        "problems": problems.sort_by { _1.timestamp }.reverse,
        "title": "لیست مساله‌ها"
    }
    output_html =
        render_with_master_layout(
            tmpl('problem-list.html.erb'),
            data)
    File.write(File.join(output_dir, "fa", 'problem-list.html'), output_html)
end

def generate_problem_pages(source_info)
    generate_problem = lambda {|input_root, output_root, subfolder, entry|
        entry_html = entry.gsub(".md", ".html")
        problem_path = File.join(input_root, subfolder, entry)
        output_path = File.join(output_root, subfolder, entry_html)
        problem_info = parse_problem(problem_path, source_info)
        render_problem(problem_info, output_path)
        problem_info.url = File.join('', 'fa', 'problems', subfolder, entry_html)
        problem_info
    }

    output_root = File.join(output_dir, 'fa', 'problems')
    walk_and_generate(problems_dir, output_root, generate_problem)
end

def render_problem(problem_info, output_path)
    data = {
        "problem": problem_info,
        "title": problem_info.title
    }
    output_html =
        render_with_master_layout(
            tmpl('problem.html.erb'),
            data)
    File.write(output_path, output_html)
end

def parse_problem(path, source_info)
    contents = File.readlines(path).map { _1.strip }
    contents.append("# end")
    info = ProblemInfo.new

    def process_section(name, contents, info)
        case name
        when 'title' then
            info.title = contents.join(" ")
        when 'source' then
            if not contents.empty? and contents[0].length > 0
                info.source = contents[0]
            end
        when 'image' then
            if not contents.empty? and contents[0].length > 0
                info.image = contents[0]
            end
        when 'tags' then
            info.tags = contents
        when 'timestamp' then
            begin
                info.timestamp = DateTime.parse(contents[0].strip)
            rescue
                # no changes
            end
        when 'difficulty' then
            if not contents.empty? and contents[0].length > 0
                info.difficulty = contents[0]
            end
        when 'statement' then
            info.statement =
                GitHub::Markup.render_s(
                    GitHub::Markups::MARKUP_MARKDOWN,
                    contents.join("\n"))
        when 'hint' then
            info.hints.append(
                GitHub::Markup.render_s(
                    GitHub::Markups::MARKUP_MARKDOWN,
                    contents.join("\n")))
        when 'solution' then
            info.solutions.append(
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
                process_section(current_section, current_content, info)
            end
            current_section = line.downcase[2..]
            current_content = []
        else
            current_content.append(line)
        end
    }
    if (source = info.source)
        info.source_title = source_info.title(source)
        info.source_url = source_info.url(source)
    end
    info
end

class ProblemInfo
    attr_accessor :title, :source, :tags, :statement,
                  :hints, :solutions, :source, :source_title, :source_url,
                  :url, :difficulty, :timestamp, :image
    def initialize
        @title = nil
        @source = nil
        @tags = []
        @difficulty = 0
        @statement = nil
        @hints = []
        @solutions = []
        @source = nil
        @source_title = nil
        @source_url = nil
        @url = nil
        @timestamp = nil
        @image = nil
    end
end
