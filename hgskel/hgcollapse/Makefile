PYTHON=python
HG=`which hg`

help:
	@echo 'Commonly used make targets:'
	@echo '  test - run all tests in the automatic test suite'
	@echo '  test-all - also run blacklisted tests'

all: help

test:
	cd test && $(PYTHON) run-tests.py --blacklist=BLACKLIST --with-hg=$(HG) $(TESTFLAGS)	

test-all:
	cd test && $(PYTHON) run-tests.py --with-hg=$(HG) $(TESTFLAGS)	

.PHONY: all help test test-all