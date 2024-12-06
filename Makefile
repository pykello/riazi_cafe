# Define the shell to use
SHELL := /bin/bash

BUILD_DIR := build

CONTENT_FILES := $(shell find content -type f \( -name '*.md' -o -name '*.tex' -o -name '*.html' \) ! -name 'index.html')
CONTENT_TARGETS := $(CONTENT_FILES:content/%.md=$(BUILD_DIR)/%.html)
CONTENT_TARGETS := $(CONTENT_TARGETS:content/%.tex=$(BUILD_DIR)/%.html)
CONTENT_TARGETS := $(CONTENT_TARGETS:content/%.html=$(BUILD_DIR)/%.html)

LIST_FILES := $(shell find content -type f \( -name 'index.*' \))
LIST_TARGETS := $(LIST_FILES:content/%.list=$(BUILD_DIR)/%.html)
LIST_TARGETS := $(LIST_TARGETS:content/%.html=$(BUILD_DIR)/%.html)

STATIC_FILES := $(shell find static -type f)
STATIC_TARGETS := $(STATIC_FILES:static/%=$(BUILD_DIR)/%)

all: generate

generate: $(CONTENT_TARGETS) $(LIST_TARGETS) static
	@mkdir -p $(BUILD_DIR)/images $(BUILD_DIR)/css

$(BUILD_DIR)/%/index.html: content/%/index.* $(CONTENT_TARGETS)
	@echo "Generating $@ ..."
	@mkdir -p $(@D)
	src/bin/generate-list.rb $@ $< $(shell find $(@D) -type f \( -name '*.json' \))

$(BUILD_DIR)/%.html $(BUILD_DIR)/%.json: content/%.*
	@echo "Generating $@ ..."
	@mkdir -p $(@D)
	@src/bin/generate.rb $@ `echo $^ | grep -oE '\b\S+\.(md|tex|html)\b'`

static: $(STATIC_TARGETS)
	@echo "Copying static files ..."

$(BUILD_DIR)/images/%: static/images/%
	@mkdir -p $(@D)
	@cp $< $@

$(BUILD_DIR)/css/%: static/css/%
	@mkdir -p $(@D)
	@cp $< $@

$(BUILD_DIR)/html/%: static/html/%
	@mkdir -p $(@D)
	@cp $< $@

$(BUILD_DIR)/CNAME: static/CNAME
	@mkdir -p $(@D)
	@cp $< $@

clean:
	rm -rf $(BUILD_DIR)

http:
	ruby -run -e httpd ./$(BUILD_DIR) -p 8000

# Phony targets
.PHONY: all
