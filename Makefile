# Define the shell to use
SHELL := /bin/bash

CONTENT_FILES := $(shell find content/ -type f \( -name '*.md' -o -name '*.tex' -o -name '*.html' \) ! -name 'index.html')
CONTENT_TARGETS := $(CONTENT_FILES:content/%.md=docs/%.html)
CONTENT_TARGETS := $(CONTENT_TARGETS:content/%.tex=docs/%.html)
CONTENT_TARGETS := $(CONTENT_TARGETS:content/%.html=docs/%.html)

LIST_FILES := $(shell find content/ -type f \( -name 'index.*' \))
LIST_TARGETS := $(LIST_FILES:content/%.list=docs/%.html)
LIST_TARGETS := $(LIST_TARGETS:content/%.html=docs/%.html)

STATIC_FILES := $(shell find static/ -type f)
STATIC_TARGETS := $(STATIC_FILES:static/%=docs/%)

all: generate

generate: $(CONTENT_TARGETS) $(LIST_TARGETS) static
	@mkdir -p docs/images docs/css

docs/%/index.html: content/%/index.* $(CONTENT_TARGETS)
	@echo "Generating $@ ..."
	@mkdir -p $(@D)
	@src/bin/generate-list.rb $@ $< $(shell find $(@D) -type f \( -name '*.json' \))

docs/%.html docs/%.json: content/%.*
	@echo "Generating $@ ..."
	@mkdir -p $(@D)
	@src/bin/generate.rb $@ `echo $^ | grep -oE '\b\S+\.(md|tex|html)\b'`

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
