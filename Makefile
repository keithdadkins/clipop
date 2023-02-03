GO_VERSION := 1.19.5
GORELEASER_VERSION := 1.15.0

# Use one shell for all targets
SHELL := /bin/bash
.ONE_SHELL:
.DEFAULT_GOAL := help

# Init
init:
	@echo "Initializing project..."
	@cp .env.example .env
	@go mod tidy
.PHONY: init

# Check requirements
reqs: init
	@echo "Checking Go version..."
	@go version | grep $(GO_VERSION) || (echo "Go $(GO_VERSION) is required but not found."; exit 1)
	@echo "Checking Goreleaser version..."
	@goreleaser --version | grep $(GORELEASER_VERSION) || (echo "Goreleaser $(GORELEASER_VERSION) is required but not found."; exit 1)
.PHONY: reqs

# Check code and config
check:
	@echo "Checking code..."
	@gofmt -l -w .
	@echo "Checking config"
	@goreleaser check
.PHONY: check

# Compile the project
build: reqs
	@echo "Building project..."
	@mkdir -p dist && \
	go build -o dist/$(PROJECT_NAME) .
.PHONY: build

# Test
test:
	@echo "Running tests..."
	@go test -v
.PHONY: test

# Generate a release (tag first)
release: check
	@read -p "Enter release version: " version; \
	git tag -a $$version -m "Release $$version"; \
	git push origin $$version; \
	echo "Generating release..."; \
	goreleaser release --rm-dist
.PHONY: release

# Generate a local release using latest snapshot (no tags, no push)
local: check
	@echo "Generating local release..."
	@goreleaser release --snapshot --clean
.PHONY: local

# Clean target
clean:
	@echo "Cleaning local build artifacts..."
	@rm -rf dist
.PHONY: clean

# Help target
help:
	@echo "Available targets:"
	@echo "  init      - initialize the project"
	@echo "  reqs 	   - check if Go and goreleaser are installed"
	@echo "  build     - build the project"
	@echo "  check     - lint and validate"
	@echo "  test      - run tests"
	@echo "  release   - tag and release the project using goreleaser"
	@echo "  local     - release the project using goreleaser locally"
	@echo "  clean     - clean build artifacts"
	@echo "  help      - show this message"
.PHONY: help