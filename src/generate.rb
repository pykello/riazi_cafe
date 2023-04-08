require_relative 'pages'
require_relative 'problems'
require_relative 'problem_sources'

problem_source_info = generate_problem_sources
problems = generate_problem_pages(problem_source_info)
generate_problem_list_page(problems)
generate_pages
