# Flags
CC        :=  gcc
DEBUG     :=  -ggdb
WARNINGS  :=  -Wall #-Wextra
TEST	  :=  -lcunit

CFLAGS    += $(DEBUG) $(WARNINGS) -std=c99

LDFLAGS   += # Libraries

# Directories
SRCDIR   :=  src
OBJDIR   :=  obj
BINDIR   :=  bin
TESTDIR  :=  tests

## Add paths and suffixes
FILES     := $(patsubst %,$(SRCDIR)/%,$(addsuffix .c, $(_FILES)))
OBJFILES  := $(patsubst %,$(OBJDIR)/%,$(addsuffix .o, $(_FILES)))

## Final output name
OUT	  := myprog

###################################################################
# OS Detection in Makefile, taken from stackoverflow:
# http://stackoverflow.com/questions/714100/os-detecting-makefile
#
# Modded to work with target systems
###################################################################
ifeq ($(OS),Windows_NT)
    # NOT SUPPORTED
else
    # Get OS
    UNAME_S := $(shell uname -s)
    # Get architecture
    UNAME_P := $(shell uname -p)
    ifeq ($(UNAME_S),Linux)
        ifeq ($(UNAME_P),x86_64)
            CFLAGS += -D LINUX_64
        endif
        ifeq ($(UNAME_P),sparc)
            CFLAGS += -D LINUX_SPARC
        endif
        ifneq ($(filter %86,$(UNAME_P)),)
            CFLAGS += -D LINUX_32
        endif
    endif
    ifeq ($(UNAME_S), SunOS)
        ifeq ($(UNAME_P),sparc)
            CFLAGS += -D SPARC
        endif
        ifneq ($(filter %86,$(UNAME_P)),)
            CFLAGS += -D SOLARIS_32
        endif
    endif
    ifeq ($(UNAME_S),Darwin) # OS X
        CFLAGS += -D LINUX_64
    endif
endif

# Text formatting for Linux & OSX
# skip on SunOS
ifeq ($(UNAME_S), SunOS)
    TEXT_RED     := 
    TEXT_GREEN   := 
    TEXT_YELLOW  := 
    TEXT_BLUE    := 
    TEXT_BOLD    := 
    TEXT_RESET   := 
else
    TEXT_RED     := $$(tput setaf 1)
    TEXT_GREEN   := $$(tput setaf 2)
    TEXT_YELLOW  := $$(tput setaf 3)
    TEXT_BLUE    := $$(tput setaf 4)
    TEXT_BOLD    := $$(tput bold)
    TEXT_RESET   := $$(tput sgr0)
endif

# PHONY
.PHONY: all obj outtest clean

# Compilation to library
all: out

out: obj
	@$(CC) $(CFLAGS) -o $(BINDIR)/$(OUT) $(OBJFILES) $(LDFLAGS)

# OBJECT COMPILATION
obj: $(OBJFILES)

$(OBJDIR)/%.o: $(SRCDIR)/%.c $(SRCDIR)/%.h
	@echo "Compiling $(TEXT_BOLD)$@$(TEXT_RESET)"
	@$(CC) $(CFLAGS) -c -o $@ $<
	@echo "$(TEXT_GREEN)OK$(TEXT_RESET)"

# TEST
test: test_mymodule

test_%: $(TESTDIR)/test_%.c $(OBJDIR)/%.o
	@echo "$(TEXT_BOLD)$(patsubst test_%, %, $@) tests$(TEXT_RESET)"
	@$(CC) $(CFLAGS) -o $(BINDIR)/$@ $^ $(TEST)
	@$(BINDIR)/$@

# DOCUMENTATION


# Cleaning rules
clean:
	@rm -rf $(OBJDIR)/*.o
	@find $(BINDIR) -type f -not -name '.gitignore' | xargs rm -rf
