
CP       = cp -f
MV       = mv -f
RM       = rm -f
MKDIR    = mkdir -p

vpath %.c src
vpath %.c tests
vpath %.c examples
vpath %.h include

PREFIX   = /usr/local
LIBDIR   = ${exec_prefix}/lib
ROOTDAT  = ${prefix}/share
INCDIR   = ${prefix}/include
OLDINCDIR= /usr/include

ACTIVFN  = 

# If $(ACTIVFN) is not empy, check to see which of the activation functions
# the user configured. Only set the variable if there is an exact match to 
# prevent erroneous execution.
ifneq ($(strip $(ACTIVFN)), " ")
    ifeq ($(ACTIVFN),SIGMOID)
        ACTFNFLAG=-Dgenann_act=genann_act_sigmoid_cached
    endif

    ifeq ($(ACTIVFN),THRESHOLD)
        ACTFNFLAG=-Dgenann_act=genann_act_threshold
    endif

    ifeq ($(ACTIVFN),LINEAR)
        ACTFNFLAG=-Dgenann_act=genann_act_linear
    endif
endif

CC       = gcc
CFLAGS   = -g -O2
CPPFLAGS = 
LDFLAGS  = 

COMPILER = $(CC)
COMPFLAGS= $(CFLAGS) -fPIC
PREPFLAGS= $(CPPFLAGS) -DHAVE_CONFIG_H $(ACTFNFLAG) -I include
LINKFLAGS= $(LDFLAGS) -lm   

TARNAME  = genann
TARGET   = lib$(TARNAME).so

all: $(TARGET)

$(TARGET): genann.o
	$(COMPILER) $(COMPFLAGS) -shared -o $@ $^ $(LINKFLAGS)

genann.o: genann.c
	$(COMPILER) $(COMPFLAGS) $(PREPFLAGS) -c -o $@ $^

.PHONY: check
check: test

.PHONY: test
test: $(TARGET) $(TARNAME)-test
	./genann-test

$(TARNAME)-test: test.o
	$(COMPILER) $(COMPFLAGS) $(PREPFLAGS) -o $@ $^ $(LINKFLAGS) -Wl,-R -Wl,. -lgenann

test.o: test.c
	$(COMPILER) $(COMPFLAGS) $(PREPFLAGS) -c -o $@ $^

.PHONY: examples
examples: example1 example2 example3 example4

example1: example1.c
	$(COMPILER) $(COMPFLAGS) $(PREPFLAGS) -o $@ $^ $(LINKFLAGS) -Wl,-R -Wl,. -lgenann

example2: example2.c
	$(COMPILER) $(COMPFLAGS) $(PREPFLAGS) -o $@ $^ $(LINKFLAGS) -Wl,-R -Wl,. -lgenann

example3: example3.c
	$(COMPILER) $(COMPFLAGS) $(PREPFLAGS) -o $@ $^ $(LINKFLAGS) -Wl,-R -Wl,. -lgenann

example4: example4.c
	$(COMPILER) $(COMPFLAGS) $(PREPFLAGS) -o $@ $^ $(LINKFLAGS) -Wl,-R -Wl,. -lgenann

.PHONY: clean
clean:
	$(RM) *.o $(TARGET)
	$(RM) persist.txt

.PHONY: clean-tests
clean-tests:
	$(RM) test.o $(TARNAME)-test

.PHONY: clean-examples
clean-examples:
	$(RM) ./example{1,2,3,4}

.PHONY: distclean
distclean: clean clean-tests clean-examples
	$(RM) include/config.h
	$(RM) ./config.log ./config.status
	$(RM) -r ./autom4te.cache/

.PHONY: install
install:
	$(CP) -u include/genann.h $(PREFIX)$(INCDIR)
	$(CP) -u $(TARGET) $(PREFIX)$(LIBDIR)

.PHONY: uninstall
uninstall:
	$(RM) $(PREFIX)$(INCDIR)/genann.h
	$(RM) $(PREFIX)$(LIBDIR)/$(TARGET)
