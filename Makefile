ELM_FILES = $(shell find src -iname "*.elm")
EXAMPLE_FILES = $(shell find examples/src)

.PHONY: all
all: docs documentation.json

.PHONY: clean
clean:
	rm -fr node_modules elm-stuff dist

.PHONY: build
build: node_modules elm.json $(ELM_FILES)
	npx elm make src/Typewriter.elm

node_modules: package.json
	npm install

docs: node_modules $(ELM_FILES) $(EXAMPLE_FILES)
	cd examples; npx elm make --optimize --output=../$@/index.html src/Main.elm

documentation.json: $(ELM_Files)
	npx elm make --docs=$@
