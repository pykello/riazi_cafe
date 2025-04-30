#!/usr/bin/env ruby
# Export problems from riazi_cafe format to riazi_cafe_rs format

require 'fileutils'
require 'yaml'
require 'json'
require 'optparse'
require 'date'
require 'pathname'

# Add lib directory to load path
$LOAD_PATH.unshift(File.expand_path('../src/lib', __dir__))
require 'problems'

class ProblemExporter
  attr_reader :options

  def initialize
    @options = {
      input_dir: nil,
      output_dir: nil,
      static_root: nil,
      force: false,
      verbose: false
    }
    parse_options
  end

  def run
    validate_options

    # Find all problem files
    problem_files = find_problem_files(@options[:input_dir])
    puts "Found #{problem_files.size} problem files to process"
    puts "static_root: #{@options[:static_root]}" if @options[:static_root]

    # Process each problem
    success_count = 0
    problem_files.each do |file_path|
      if process_problem(file_path)
        success_count += 1
      end
    end

    puts "Conversion complete. Successfully converted #{success_count} of #{problem_files.size} problems."
  end

  private

  def parse_options
    parser = OptionParser.new do |opts|
      opts.banner = "Usage: ruby export_to_rs.rb [options]"

      opts.on("--input INPUT_DIR", "Input directory containing riazi_cafe problems") do |dir|
        @options[:input_dir] = dir
      end

      opts.on("--output OUTPUT_DIR", "Output directory for riazi_cafe_rs problems") do |dir|
        @options[:output_dir] = dir
      end
      
      opts.on("--static-root STATIC_ROOT", "Root directory containing static assets like images") do |dir|
        @options[:static_root] = dir
      end

      opts.on("--force", "Overwrite existing files in output directory") do
        @options[:force] = true
      end

      opts.on("--verbose", "Print detailed information during conversion") do
        @options[:verbose] = true
      end

      opts.on("-h", "--help", "Display this help message") do
        puts opts
        exit
      end
    end

    begin
      parser.parse!
    rescue OptionParser::InvalidOption => e
      puts e
      puts parser
      exit 1
    end
  end

  def validate_options
    unless @options[:input_dir] && @options[:output_dir]
      puts "Error: Both --input and --output directories are required"
      exit 1
    end

    unless Dir.exist?(@options[:input_dir])
      puts "Error: Input directory '#{@options[:input_dir]}' does not exist!"
      exit 1
    end

    # Check if static root exists if provided
    if @options[:static_root] && !Dir.exist?(@options[:static_root])
      puts "Error: Static root directory '#{@options[:static_root]}' does not exist!"
      exit 1
    end

    # Create output directory if it doesn't exist
    FileUtils.mkdir_p(@options[:output_dir]) unless Dir.exist?(@options[:output_dir])
  end

  def find_problem_files(dir)
    files = []
    Dir.glob(File.join(dir, "**", "*.{md,tex}")).each do |file|
      files << file
    end
    files
  end

  def process_problem(file_path)
    # Extract problem ID from the filename or path
    file_name = File.basename(file_path)
    problem_id = File.basename(file_name, ".*")
    
    if @options[:verbose]
      puts "Processing problem: #{problem_id} from #{file_path}"
    end
    
    # Determine the output directory for this problem
    problem_output_dir = File.join(@options[:output_dir], problem_id)
    
    # Check if problem already exists in output and respect force flag
    if Dir.exist?(problem_output_dir) && !@options[:force]
      puts "Skipping #{problem_id} - already exists (use --force to overwrite)"
      return false
    end
    
    # Use the existing riazi_cafe infrastructure to parse the problem
    problem_info = parse_problem([file_path], problem_id)
    
    # Create output directory
    FileUtils.mkdir_p(problem_output_dir)
    
    # Write in riazi_cafe_rs format
    write_rs_problem(problem_output_dir, problem_info, problem_id)
    
    # Copy any images referenced in the problem
    copy_images(File.dirname(file_path), problem_output_dir, problem_info)
    
    if @options[:verbose]
      puts "Successfully converted #{problem_id}"
    end
    
    true
  end

  def write_rs_problem(output_dir, problem_info, problem_id)
    # Process the main problem image if it exists
    if problem_info.image
      # Make sure we copy and update the image path
      problem_info.image = process_image_path(problem_info.image, File.dirname(output_dir), output_dir)
    end
    
    # Format the timestamp properly regardless of its type
    formatted_timestamp = format_timestamp(problem_info.timestamp)
    
    # Write metadata.yaml
    metadata = {
      'type' => 'problem',
      'title' => problem_info.title || 'Untitled Problem',
      'id' => problem_id,
      'tags' => problem_info.tags || [],
      'timestamp' => formatted_timestamp,
      'image' => problem_info.image
    }
    
    File.open(File.join(output_dir, 'metadata.yaml'), 'w') do |file|
      file.write(metadata.to_yaml)
    end
    
    # Write problem statement - Use original markdown or tex
    write_problem_content(output_dir, problem_info)
    
    # Write hints
    problem_info.hints.each_with_index do |hint, index|
      write_hint_content(output_dir, problem_info, index)
    end
    
    # Write solutions
    problem_info.solutions.each_with_index do |solution, index|
      write_solution_content(output_dir, problem_info, index)
    end
  end
  
  # Write problem content using original markdown or tex
  def write_problem_content(dir, problem_info)
    if problem_info.statement_md
      File.open(File.join(dir, 'problem.md'), 'w') do |file|
        file.write(problem_info.statement_md)
      end
    elsif problem_info.statement_tex
      File.open(File.join(dir, 'problem.tex'), 'w') do |file|
        file.write(problem_info.statement_tex)
      end
    else
      # Fallback to HTML if neither markdown nor tex is available
      File.open(File.join(dir, 'problem.html'), 'w') do |file|
        file.write(problem_info.statement.to_s)
      end
      puts "Warning: No original markdown or tex found for problem statement, saved as HTML"
    end
  end
  
  # Write hint content using original markdown or tex
  def write_hint_content(dir, problem_info, index)
    suffix = ".#{index+1}"
    
    if index < problem_info.hints_md.length && problem_info.hints_md[index]
      File.open(File.join(dir, "hint#{suffix}.md"), 'w') do |file|
        file.write(problem_info.hints_md[index])
      end
    elsif index < problem_info.hints_tex.length && problem_info.hints_tex[index]
      File.open(File.join(dir, "hint#{suffix}.tex"), 'w') do |file|
        file.write(problem_info.hints_tex[index])
      end
    else
      # Fallback to HTML
      File.open(File.join(dir, "hint#{suffix}.html"), 'w') do |file|
        file.write(problem_info.hints[index].to_s)
      end
      puts "Warning: No original markdown or tex found for hint #{index+1}, saved as HTML"
    end
  end
  
  # Write solution content using original markdown or tex
  def write_solution_content(dir, problem_info, index)
    file_suffix = index > 0 ? ".#{index+1}" : ""
    
    if index < problem_info.solutions_md.length && problem_info.solutions_md[index]
      File.open(File.join(dir, "solution#{file_suffix}.md"), 'w') do |file|
        file.write(problem_info.solutions_md[index])
      end
    elsif index < problem_info.solutions_tex.length && problem_info.solutions_tex[index]
      File.open(File.join(dir, "solution#{file_suffix}.tex"), 'w') do |file|
        file.write(problem_info.solutions_tex[index])
      end
    else
      # Fallback to HTML
      File.open(File.join(dir, "solution#{file_suffix}.html"), 'w') do |file|
        file.write(problem_info.solutions[index].to_s)
      end
      puts "Warning: No original markdown or tex found for solution #{index+1}, saved as HTML"
    end
  end
  
  # Fallback method for when neither markdown nor tex is available
  def fallback_to_html(html_content)
    puts "Warning: No original markdown or tex found, preserving HTML content."
    html_content.to_s
  end

  def copy_images(source_dir, dest_dir, problem_info)
    # Extract image paths from problem statement, hints, and solutions
    content = problem_info.statement_md.to_s
    problem_info.hints_md.each { |hint| content += hint.to_s } if problem_info.hints_md
    problem_info.solutions_md.each { |solution| content += solution.to_s } if problem_info.solutions_md
    
    # Also check HTML content for images
    html_content = problem_info.statement.to_s
    problem_info.hints.each { |hint| html_content += hint.to_s }
    problem_info.solutions.each { |solution| html_content += solution.to_s }
    
    # Extract image paths from content
    image_paths = []
    
    # Match markdown image syntax: ![alt](path)
    content.scan(/!\[.*?\]\((.*?)\)/).flatten.each do |path|
      image_paths << path unless path.start_with?('http')
    end
    
    # Match HTML image tags: <img src="path">
    html_content.scan(/<img[^>]*src=['"](.*?)['"][^>]*>/).flatten.each do |path|
      image_paths << path unless path.start_with?('http')
    end
    
    # Copy each image to destination
    image_paths.uniq.each do |img_path|
      # First try to find the image in the static root if provided
      if @options[:static_root] && img_path.start_with?('/')
        # For paths starting with /, look in static_root
        static_img_path = File.join(@options[:static_root], img_path)

        puts "Looking for static image: #{static_img_path}" if @options[:verbose]
        
        if File.exist?(static_img_path)
          # Create destination directory structure
          dest_img_dir = File.dirname(File.join(dest_dir, File.basename(img_path)))
          FileUtils.mkdir_p(dest_img_dir) unless Dir.exist?(dest_img_dir)
          
          # Copy the image
          dest_img_path = File.join(dest_dir, File.basename(img_path))
          FileUtils.copy_file(static_img_path, dest_img_path)
          puts "Copied static image: #{img_path} to #{dest_img_path}" if @options[:verbose]
          
          # Update image references in markdown content if available
          if problem_info.statement_md
            problem_info.statement_md.gsub!(img_path, File.basename(img_path))
          end
          
          problem_info.hints_md&.each_with_index do |hint, i|
            if hint
              problem_info.hints_md[i] = hint.gsub(img_path, File.basename(img_path))
            end
          end
          
          problem_info.solutions_md&.each_with_index do |solution, i|
            if solution
              problem_info.solutions_md[i] = solution.gsub(img_path, File.basename(img_path))
            end
          end
          
          next
        else
          puts "Warning: Static image not found: #{static_img_path}" if @options[:verbose]
        end
      end
      
      # If not found in static_root or it's a relative path, try the source directory
      source_img_path = File.join(source_dir, img_path)
      
      if File.exist?(source_img_path)
        # Create destination directory structure
        dest_img_dir = File.dirname(File.join(dest_dir, img_path))
        FileUtils.mkdir_p(dest_img_dir) unless Dir.exist?(dest_img_dir)
        
        # Copy the image
        dest_img_path = File.join(dest_dir, img_path)
        FileUtils.copy_file(source_img_path, dest_img_path)
        puts "Copied image: #{img_path}" if @options[:verbose]
      else
        puts "Warning: Image not found: #{source_img_path}"
      end
    end
    
    # Re-write content files since we may have updated image paths
    write_problem_content(dest_dir, problem_info)
    
    problem_info.hints.each_with_index do |_, index|
      write_hint_content(dest_dir, problem_info, index)
    end
    
    problem_info.solutions.each_with_index do |_, index|
      write_solution_content(dest_dir, problem_info, index)
    end
  end

  # Process an image path - copy the image and return the new path
  def process_image_path(image_path, source_dir, dest_dir)
    return nil if !image_path || image_path.empty?
    return image_path if image_path.start_with?('http') # Skip remote images
    
    if @options[:verbose]
      puts "Processing image path: #{image_path}"
    end
    
    # Handle absolute paths (starting with /)
    if image_path.start_with?('/') && @options[:static_root]
      static_img_path = File.join(@options[:static_root], image_path)
      
      if File.exist?(static_img_path)
        new_filename = File.basename(image_path)
        dest_img_path = File.join(dest_dir, new_filename)
        
        # Copy the image to the destination directory
        FileUtils.copy_file(static_img_path, dest_img_path)
        
        if @options[:verbose]
          puts "Copied main image from static root: #{static_img_path} to #{dest_img_path}"
        end
        
        # Return the new relative path
        return new_filename
      else
        puts "Warning: Main image not found in static root: #{static_img_path}"
      end
    end
    
    # If not found in static root or not an absolute path, try the source directory
    source_img_path = image_path.start_with?('/') ? 
      image_path : 
      File.join(source_dir, image_path)
    
    if File.exist?(source_img_path)
      new_filename = File.basename(image_path)
      dest_img_path = File.join(dest_dir, new_filename)
      
      # Copy the image
      FileUtils.copy_file(source_img_path, dest_img_path)
      
      if @options[:verbose]
        puts "Copied main image: #{source_img_path} to #{dest_img_path}"
      end
      
      # Return the new relative path
      return new_filename
    else
      puts "Warning: Main image not found: #{source_img_path}"
      return image_path # Keep the original path as a fallback
    end
  end

  # Helper method to format timestamp in ISO8601 format regardless of input type
  def format_timestamp(timestamp)
    if timestamp.nil?
      return Time.now.strftime('%Y-%m-%dT%H:%M:%SZ')
    end
    
    begin
      case timestamp
      when DateTime
        return timestamp.strftime('%Y-%m-%dT%H:%M:%SZ')
      when Time
        return timestamp.strftime('%Y-%m-%dT%H:%M:%SZ')
      when String
        # Try to parse the string as a date
        parsed = DateTime.parse(timestamp)
        return parsed.strftime('%Y-%m-%dT%H:%M:%SZ')
      else
        # For any other type, convert to string and try to parse
        return DateTime.parse(timestamp.to_s).strftime('%Y-%m-%dT%H:%M:%SZ')
      end
    rescue => e
      puts "Warning: Failed to format timestamp '#{timestamp}' (#{e.message}), using current time instead"
      return Time.now.strftime('%Y-%m-%dT%H:%M:%SZ')
    end
  end
end

# Run the exporter when script is executed
if __FILE__ == $0
  exporter = ProblemExporter.new
  exporter.run
end
