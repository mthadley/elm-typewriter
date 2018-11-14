ELM_FILES = $(shell find ../src -iname "*.elm")
EXAMPLE_FILES = $(shell find src)

.PHONY: all
all: dist

.PHONY: clean
clean:
	rm -fr elm-stuff .cache

dist: elm.json $(EXAMPLE_FILES) $(ELM_FILES)
	npx parcel build src/index.html --public-url $(PUBLIC_URL)

.PHONY: serve
serve:
	npx parcel src/index.html
