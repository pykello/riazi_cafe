require_relative 'pages'
require_relative 'problems'
require_relative 'problem_sources'
require_relative 'blog'

problem_source_info = generate_problem_sources
problems = generate_problem_pages(problem_source_info)
generate_problem_list_page(problems)
blogposts = generate_blogposts('blog')
generate_blog_index(blogposts, 'blog')
generate_pages
