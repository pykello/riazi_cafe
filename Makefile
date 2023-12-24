# Define the shell to use
SHELL := /bin/bash

PROBLEM_FILES := $(shell find problems/ -type f \( -name '*.md' -o -name '*.tex' \))
PROBLEM_TARGETS := $(PROBLEM_FILES:problems/fa/%.md=docs/fa/problems/%.html)
PROBLEM_TARGETS := $(PROBLEM_TARGETS:problems/fa/%.tex=docs/fa/problems/%.html)
PROBLEM_TARGETS := $(PROBLEM_TARGETS:problems/en/%.md=docs/en/problems/%.html)
PROBLEM_TARGETS := $(PROBLEM_TARGETS:problems/en/%.tex=docs/en/problems/%.html)

PROBLEM_LIST_TARGETS := docs/fa/problem-list.html docs/en/problem-list.html

all: generate

generate: $(PROBLEM_TARGETS) $(PROBLEM_LIST_TARGETS)
	@mkdir -p docs/images docs/css
	@cp -R static/images/* docs/images/
	@cp -R static/css/* docs/css/
	@cp static/CNAME docs/
	@src/bin/generate-rest.rb

http:
	ruby -run -e httpd ./docs -p 8000

docs/fa/problems/%.html: problems/fa/%.* templates/layout.html.erb templates/problem.html.erb
	@mkdir -p $(@D)
	src/bin/generate-problem.rb $< $@

docs/en/problems/%.html: problems/en/%.* templates/layout.html.erb templates/problem.html.erb
	@mkdir -p $(@D)
	src/bin/generate-problem.rb $< $@

docs/%/problem-list.html: $(PROBLEM_FILES)
	src/bin/generate-problem-list.rb

clean:
	rm -rf docs

# Phony targets
.PHONY: all
