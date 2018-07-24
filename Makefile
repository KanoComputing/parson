# Makefile
#
# Copyright (C) 2018 Kano Computing Ltd.
# License: http://www.gnu.org/licenses/gpl-2.0.txt GNU GPL v2
#
# Copyright (C) 2018 Krzysztof Gabis (kgabis@gmail.com)
# License: MIT


PLATFORM := $(shell uname)

ifeq ($(PLATFORM), Linux)
	SONAME_FLAG=-soname
	SONAME=libparson.so
	LD_TYPE=-shared
else ifeq ($(PLATFORM), Darwin)
	SONAME_FLAG=-install_name
	SONAME=libparson.dylib
	LD_TYPE=-dynamiclib
endif

CFLAGS+=-Wall -Wextra -g -fPIC -c
TEST_CFLAGS=-O0 -g -Wall -Wextra -std=c89 -pedantic-errors
LDFLAGS+=$(LD_TYPE) -Wl,$(SONAME_FLAG),$(SONAME)
INCLUDES+=-I./
OBJS=parson.so

OUTDIR=release
DEBUG_OUTDIR=debug

all: ensure-dir $(SONAME)

debug: CFLAGS += -DDEBUG -g
debug: OUTDIR=$(DEBUG_OUTDIR)
debug: $(SONAME)

ensure-dir:
	mkdir -p $(OUTDIR)
	mkdir -p $(DEBUG_OUTDIR)

$(SONAME): $(OBJS)
	$(CC) $(LDFLAGS) $(addprefix $(OUTDIR)/, $?) -o $(OUTDIR)/$@

%.so: %.c
	$(CC) $(CFLAGS) $(INCLUDES) $< -o $(OUTDIR)/$@

clean-release:
	@rm -f $(OUTDIR)/$(OBJS)
	@rm -f $(OUTDIR)/$(SONAME)

clean-debug:
	@rm -f $(DEBUG_OUTDIR)/$(OBJS)
	@rm -f $(DEBUG_OUTDIR)/$(SONAME)

clean: clean-release clean-debug
	rm -f test *.o

check: test

test: tests.c parson.c
	$(CC) $(TEST_CFLAGS) -o $@ tests.c parson.c
	./$@


.PHONY: all debug ensure-dir clean-release clean-debug clean check test
