require 'fileutils'
require 'github/markup'
require 'date'
require 'pandoc-ruby'
require_relative 'common'

def problems_dir(language)
    File.join(".", "problems", language)
end

def generate_problem_list_page(problems, language)
    data = {
        "problems": problems.sort_by { _1.timestamp }.reverse,
        "title": "لیست مساله‌ها"
    }
    output_html =
        render_with_master_layout(
            tmpl('problem-list.html.erb'),
            data, language)
    File.write(File.join(output_dir, language, 'problem-list.html'), output_html)
end

def generate_problem_pages(source_info, language)
    generate_problem = lambda {|input_root, output_root, subfolder, entry|
        return nil unless entry.match? /.tex$|.md$/
        entry_html = entry.gsub(/.tex|.md/, ".html")
        problem_path = File.join(input_root, subfolder, entry)
        output_path = File.join(output_root, subfolder, entry_html)
        problem_info = parse_problem(problem_path, source_info)
        render_problem(problem_info, output_path, language)
        problem_info.url = File.join('', language, 'problems', subfolder, entry_html)
        problem_info
    }

    output_root = File.join(output_dir, language, 'problems')
    walk_and_generate(problems_dir(language), output_root, generate_problem)
end

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
end

def parse_problem(path, source_info)
    if path.end_with? ".md"
        parse_problem_md(path, source_info)
    elsif path.end_with? ".tex"
        parse_problem_tex(path, source_info)
    else
        raise "Unsupported format: #{path}"
    end
end

def parse_problem_md(path, source_info)
    contents = File.readlines(path).map { _1.strip }
    contents.append("# end")
    info = ProblemInfo.new

    def process_section(name, contents, info, path)
        case name
        when 'title' then
            info.title = contents.join(" ")
        when 'id' then
            info.id = contents[0]
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
        when 'solution-tex' then
            dirname = File.dirname(path)
            tex_path = File.join(dirname, contents.join("\n").strip)
            info.solutions.append(
                render_tex_path(tex_path)
            )

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
    if (source = info.source)
        info.source_title = source_info.title(source)
        info.source_url = source_info.url(source)
    end
    info
end

def parse_problem_tex(path, source_info)
    puts path
    contents = File.readlines(path).map { _1.strip }
    contents.append("# end")
    info = ProblemInfo.new

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

    fa_problem_filename = path.gsub('en', 'fa').gsub('tex', 'md')
    begin
        fa_p = parse_problem_md(fa_problem_filename, source_info)
        info.timestamp = fa_p.timestamp
        info.image = fa_p.image
        info.id = "Problem #{path.scan(/\d/).join.to_i}"
    rescue
        puts "Couldn't open #{fa_problem_filename}"
    end

    info
end


def render_tex_path(path)
    tex_content = File.read(path)
    render_tex_s(tex_content)
end

def render_tex_s(tex_content)
    converter = PandocRuby.new(tex_content, from: :latex)
    html_content = converter.to_html(standalone: false, mathjax: false)

    html_content
end

class ProblemInfo
    attr_accessor :title, :source, :tags, :statement,
                  :hints, :solutions, :source, :source_title, :source_url,
                  :url, :difficulty, :timestamp, :image, :id
    def initialize
        @title = nil
        @id = ""
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

    def web_title
        if @id.empty?
            @title
        else
            "#{@id}. #{@title}"
        end
    end
end
