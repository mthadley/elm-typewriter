ELM_FILES = $(wildcard src/**/*.elm)
EXAMPLE_FILES = $(wildcard examples/**/*)
PUBLIC_URL = "/"

.PHONY: all
all: build examples

.PHONY: build
build: $(ELM_FILES) node_modules
	npx elm make src/Typewriter.elm

node_modules: package.json
	npm install

# Examples

.PHONY: examples
examples: $(EXAMPLE_FILES) $(ELM_FILES)
	npx parcel build src/Examples/index.html --public-url $(PUBLIC_URL)

.PHONY: serve
serve:
	npx parcel src/Examples/index.html
