#!/usr/bin/env ruby

require_relative "../lib/pages.rb"
require_relative "../lib/blog.rb"

blogposts = generate_blogposts('blog')
generate_blog_index(blogposts, 'blog')
generate_pages
