
http:
	ruby -run -e httpd ./docs -p 8000

generate:
	ruby src/generate.rb
