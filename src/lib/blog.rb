require 'fileutils'
require 'github/markup'
require 'date'
require_relative 'common'

def render_blogpost(blogpost_info, output_path)
    data = {
        "blogpost": blogpost_info,
        "title": blogpost_info.title
    }
    output_html =
        render_with_master_layout(
            tmpl('blogpost.html.erb'),
            data)
    File.write(output_path, output_html)
    File.write(output_path.gsub(".html", ".json"), blogpost_info.metadata.to_json)
end

def parse_blogpost(path, url)
    contents = File.readlines(path).map { _1.strip }
    contents.append("# end")
    info = BlogpostInfo.new
    info.url = url

    def process_section(name, contents, info)
        case name
        when 'title' then
            info.title = contents.join(" ")
        when 'tags' then
            info.tags = contents
        when 'twitter' then
            info.twitter = contents[0].strip
        when 'authorname' then
            info.author_name = contents[0].strip
        when 'authorlink' then
            info.author_link = contents[0].strip
        when 'timestamp' then
            begin
                info.timestamp = DateTime.parse(contents[0].strip)
            rescue
                # no changes
            end
        when 'intro' then
            info.intro =
                GitHub::Markup.render_s(
                    GitHub::Markups::MARKUP_MARKDOWN,
                    contents.join("\n"))
        when 'body' then
            info.body =
                GitHub::Markup.render_s(
                    GitHub::Markups::MARKUP_MARKDOWN,
                    contents.join("\n"))
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
    info
end

class BlogpostInfo
    attr_accessor :title, :timestamp, :twitter, :intro,
                  :body, :tags, :url, :author_name, :author_link
    def initialize
        @title = nil
        @timestamp = nil
        @twitter = nil
        @author_name = nil
        @author_link = nil
        @intro = nil
        @body = nil
        @tags = []
        @url = nil
    end

    def metadata
        {
            "title" => @title,
            "tags" => @tags,
            "url" => @url,
            "timestamp" => @timestamp.to_s,
            "author_name" => @author_name,
            "author_link" => @author_link,
            "twitter" => @twitter
        }
    end
end
