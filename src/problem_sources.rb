require 'fileutils'
require_relative 'common'
require_relative 'pages'

def generate_problem_sources
    data = generate_pages_generic(
            File.join(".", "problem-sources"),
            File.join(output_dir, "fa", "problems", "sources"))
    ProblemSourcesInfo.new(data)
end

class ProblemSourcesInfo
    def initialize(data)
        @data = data
    end

    def url(source)
        entry = find_entry(source)
        if entry.nil?
            "#"
        else
            File.join(
                "", "fa", "problems", "sources",
                entry[:subfolder],
                entry[:output_filename])
        end
    end

    def title(source)
        entry = find_entry(source)
        if entry.nil?
            source
        else
            entry[:title]
        end
    end

    def find_entry(source)
        @data.find { _1[:entry].gsub(/\..*/, "") == source }
    end
end
