# -*- mode: makefile-bsdmake; init-tabs-mode: t -*-
all:

install:
	@install -d $(HOME)/bin
	@install banblocks $(HOME)/bin/

test:
	@t/00tests.t

.PHONY: all install test
