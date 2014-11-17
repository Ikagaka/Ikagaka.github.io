TEST_DIR = test

LIB_SOURCES = $(wildcard *.coffee)
LIB_TARGETS = $(LIB_SOURCES:.coffee=.js)
TEST_SOURCES_COFFEE = $(wildcard $(TEST_DIR)/*.coffee)
TEST_TARGETS_JS = $(TEST_SOURCES_COFFEE:.coffee=.js)
TEST_SOURCES_JADE = $(wildcard $(TEST_DIR)/*.jade)
TEST_TARGETS_HTML = $(TEST_SOURCES_JADE:.jade=.html)

all: $(LIB_TARGETS)

clean :
	rm $(LIB_TARGETS) $(TEST_TARGETS_JS) $(TEST_TARGETS_HTML)

$(LIB_TARGET): $(LIB_SOURCES)
ifneq ("$(LIB_SOURCES)", "")
	cat $^ | coffee -c --stdio > $@
endif

test: $(LIB_TARGETS) test_node test_browser

test_node: $(TEST_TARGETS_JS)
	mocha $(TEST_DIR)

test_browser: $(TEST_TARGETS_HTML) $(TEST_TARGETS_JS)
	mocha-phantomjs -R spec $(TEST_DIR)/*.html

cov: $(LIB_TARGETS) $(TEST_TARGETS_JS)
	istanbul cover node_modules/mocha/bin/_mocha

.PHONY: test doc

.SUFFIXES: .coffee .js .jade .html

.coffee.js:
	coffee -c $^

.jade.html:
	jade -P $^
