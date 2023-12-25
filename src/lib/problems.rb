require 'fileutils'
require 'github/markup'
require 'date'
require 'json'
require 'pandoc-ruby'
require_relative 'common'

def render_problem(problem_info, output_path, language)
    data = {
        "problem": problem_info,
        "title": problem_info.web_title
    }
    output_html =
        render_with_master_layout(
            tmpl('problem.html.erb'),
            data, language)
    File.write(output_path, output_html)
    File.write(output_path.gsub(".html", ".json"), problem_info.metadata.to_json)
end

def parse_problem(input_paths, url)
    problem = ProblemInfo.new
    problem.url = url
    problem.timestamp = input_paths.first
    problem.id = "Problem #{input_paths.first.scan(/\d/).join.to_i}"
    input_paths.each { |path|
        if path.end_with? ".md"
            parse_problem_md(path, problem)
        elsif path.end_with? ".tex"
            parse_problem_tex(path, problem)
        else
            raise "Unsupported format: #{path}"
        end
    }
    problem
end

def parse_problem_md(path, info)
    contents = File.readlines(path).map { _1.strip }
    contents.append("# end")

    def process_section(name, contents, info, path)
        case name
        when 'title' then
            info.title = contents.join(" ")
        when 'id' then
            info.id = contents[0]
        when 'image' then
            if not contents.empty? and contents[0].length > 0
                info.image = contents[0]
            end
        when 'tags' then
            info.tags = contents.first.split(",")
        when 'timestamp' then
            begin
                info.timestamp = DateTime.parse(contents[0].strip)
            rescue
                # no changes
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
                process_section(current_section, current_content, info, path)
            end
            current_section = line.downcase[2..]
            current_content = []
        else
            current_content.append(line)
        end
    }
    info
end

def parse_problem_tex(path, info)
    contents = File.readlines(path).map { _1.strip }
    contents.append("# end")

    def process_section(name, contents, info, path, section_params)
        case name
        when "problem"
            info.image = section_params[0] if !section_params[0].empty?
            info.title = section_params[1]
            info.statement = render_tex_s(contents.join("\n"))
        when "solution"
            info.solutions.append(render_tex_s(contents.join("\n")))
        when "hint"
            info.hints.append(render_tex_s(contents.join("\n")))
        end
    end

    current_section = nil
    section_params = []
    current_content = []
    contents.each { |line|
        if current_section.nil? && line.start_with?("\\begin{")
            v = line.strip.split(/}{|{|}/)[1..]
            current_section = v[0]
            section_params = v[1..]
            current_content = []
            next
        elsif !current_section.nil? && line.start_with?("\\end{#{current_section}}")
            process_section(current_section, current_content, info, path, section_params)
            current_section = nil
        else
            current_content.append(line)
        end
    }
end


def render_tex_path(path)
    tex_content = File.read(path)
    render_tex_s(tex_content)
end

def render_tex_s(tex_content)
    converter = PandocRuby.new(tex_content, from: :latex)

    html_content = suppress_stdout do
        converter.to_html(standalone: false, mathjax: false)
    end

    html_content
end

class ProblemInfo
    attr_accessor :title, :tags, :statement,
                  :hints, :solutions, :url,
                  :timestamp, :image, :id
    def initialize
        @title = nil
        @id = ""
        @tags = []
        @statement = nil
        @hints = []
        @solutions = []
        @url = nil
        @timestamp = nil
        @image = nil
    end

    def web_title
        if @id.empty?
            @title
        else
            "#{@id}. #{@title}"
        end
    end

    def metadata
        {
            "title" => @title,
            "tags" => @tags,
            "url" => @url,
            "timestamp" => @timestamp.to_s,
            "id" => @id
        }
    end
end
