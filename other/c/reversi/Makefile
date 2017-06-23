OUTDIR := build

# Write default C program up to one here,
# if you want to resolve dependencies.
CPROGRAM   := 
CSOURCES   := $(wildcard *.c)
COBJS      := $(CSOURCES:%.c=$(OUTDIR)/%.o)
CDEPENDS   := $(CSOURCES:%.c=$(OUTDIR)/%.depend)
CC         := gcc
CFLAGS     := -Wall -O2

# Write default C++ program up to one here,
# if you want to resolve dependencies.
CXXPROGRAM := reversi
CXXSOURCES := $(wildcard *.cpp)
CXXOBJS    := $(CXXSOURCES:%.cpp=$(OUTDIR)/%.o)
CXXDEPENDS := $(CXXSOURCES:%.cpp=$(OUTDIR)/%.depend)
CXX        := g++
CXXFLAGS   := -Wall -O2 -std=c++11

.PHONY: outdir
outdir:
	mkdir -p $(OUTDIR)

.PHONY: all
all: outdir $(CPROGRAM) $(CXXPROGRAM)

$(CPROGRAM): $(COBJS) 
	$(CC) -o $(CPROGRAM) $(CFLAGS) $^

$(CXXPROGRAM): $(CXXOBJS) 
	$(CXX) -o $(CXXPROGRAM) $(CXXFLAGS) $^

$(OUTDIR)/%.o: %.c
	$(CC) -c -o $@ $(CFLAGS) $(@:$(OUTDIR)/%.o=%.c)

$(OUTDIR)/%.o: %.cpp
	$(CXX) -c -o $@ $(CXXFLAGS) $(@:$(OUTDIR)/%.o=%.cpp)

$(OUTDIR)/%.depend: %.c
	@echo generating $@
	@$(SHELL) -ec '$(CC) -MM $(CFLAGS) $< | sed "s!\($*\)\.o[ :]*!$(OUTDIR)/\1.o $@ : !g" > $@; [ -s $@ ] || rm -f $@'

$(OUTDIR)/%.depend: %.cpp
	@echo generating $@
	@$(SHELL) -ec '$(CXX) -MM $(CXXFLAGS) $< | sed "s!\($*\)\.o[ :]*!$(OUTDIR)/\1.o $@ : !g" > $@; [ -s $@ ] || rm -f $@'

ifneq "$(MAKECMDGOALS)" "clean"
-include $(CDEPENDS)
-include $(CXXDEPENDS)
endif

.PHONY : clean
clean:
	rm -f $(CPROGRAM) $(CXXPROGRAM) $(CSOURCES:%.c=%) $(CXXSOURCES:%.cpp=%)
	rm -fr $(COBJS) $(CXXOBJS)
	rm -fr $(CDEPENDS) $(CXXDEPENDS)
