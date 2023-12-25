require 'fileutils'
require 'github/markup'
require_relative 'common'

def generate_page(output_path, input_path, language)
    if input_path.match? /html$/
        title = ""
        output_html = render_with_master_layout(input_path, {"title": title}, language)
        File.write(output_path, output_html)
    elsif input_path.match? /.md$/
        contents = File.readlines(input_path)
        title = contents.length > 0 ? contents.first.gsub(/#+\s*/, "").strip : ""
        content_html =
            GitHub::Markup.render_s(
                GitHub::Markups::MARKUP_MARKDOWN,
                contents.join("\n"))
        output_html = render_with_master_layout_s(content_html, {"title": title}, language)
        File.write(output_path, output_html)
    end
end
