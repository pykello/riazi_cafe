require_relative 'pages'
require_relative 'problems'
require_relative 'problem_sources'
require_relative 'blog'

['fa', 'en'].each { |language|
    problem_source_info = generate_problem_sources
    problems = generate_problem_pages(problem_source_info, language)
    generate_problem_list_page(problems, language)
    blogposts = generate_blogposts('blog')
    generate_blog_index(blogposts, 'blog')
    generate_pages
}
