# Define the shell to use
SHELL := /bin/bash

PROBLEM_FILES := $(shell find problems/ -type f \( -name '*.md' -o -name '*.tex' \))
PROBLEM_TARGETS := $(PROBLEM_FILES:problems/fa/%.md=docs/fa/problems/%.html)
PROBLEM_TARGETS := $(PROBLEM_TARGETS:problems/fa/%.tex=docs/fa/problems/%.html)
PROBLEM_TARGETS := $(PROBLEM_TARGETS:problems/en/%.md=docs/en/problems/%.html)
PROBLEM_TARGETS := $(PROBLEM_TARGETS:problems/en/%.tex=docs/en/problems/%.html)

PROBLEM_LIST_TARGETS := docs/fa/problem-list.html docs/en/problem-list.html

STATIC_FILES := $(shell find static/ -type f)
STATIC_TARGETS := $(STATIC_FILES:static/%=docs/%)

all: generate

generate: $(PROBLEM_TARGETS) $(PROBLEM_LIST_TARGETS) static
	@mkdir -p docs/images docs/css
	@src/bin/generate-rest.rb

docs/fa/problems/%.html: problems/fa/%.* templates/layout.html.erb templates/problem.html.erb
	@echo "Generate FA problem: $<"
	@mkdir -p $(@D)
	@src/bin/generate-problem.rb $< $@

docs/en/problems/%.html: problems/en/%.* templates/layout.html.erb templates/problem.html.erb
	@echo "Generate EN problem: $<"
	@mkdir -p $(@D)
	@src/bin/generate-problem.rb $< $@

docs/%/problem-list.html: $(PROBLEM_FILES)
	@echo "Generating problem lists ..."
	@src/bin/generate-problem-list.rb

static: $(STATIC_TARGETS)
	@echo "Copying static files ..."

docs/images/%: static/images/%
	@mkdir -p $(@D)
	@cp $< $@

docs/css/%: static/css/%
	@mkdir -p $(@D)
	@cp $< $@

docs/CNAME: static/CNAME
	@mkdir -p $(@D)
	@cp $< $@

clean:
	rm -rf docs

http:
	ruby -run -e httpd ./docs -p 8000

# Phony targets
.PHONY: all
