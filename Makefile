# This makefile is designed to be run by gnu make.
# - Windows: you may download a prebuilt zipped .exe from https://github.com/dlang/dmd/releases/download/nightly/gnumake-4.4-win64.zip.
#   You also need a Git for Windows installation, for bash and common GNU tools like cp,mkdir,mv,rm,touch,which.
# - FreeBSD: the default make program on FreeBSD is not gnu make; to install gnu make:
#     pkg install gmake
#   and then run as gmake rather than make.
#
# make => makes release build of the library
#
# make clean => removes all targets built by the makefile
#
# make zip => creates a zip file of all the sources (not targets)
# referred to by the makefile, including the makefile
#
# make BUILD=debug => makes debug build of the library
#
# make unittest => builds all unittests (for debug AND release) and runs them
# make std/somemodule.test => only builds and unittests std.somemodule
# make std/somepackage.test => only builds and unittests modules in std.somepackage
# make unittest/std/somemodule.run => run std.somemodule unittest
#
# make BUILD=debug unittest => builds all unittests (for debug) and runs them
#
# make DEBUGGER=ddd std/XXXXX.debug => builds the module XXXXX and executes it
#                                      in the debugger ddd
#
# make build-html => makes html documentation
#
# make install => copies library to /usr/lib
#
################################################################################
# Configurable stuff, usually from the command line
#
# OS can be linux, windows, win32wine, osx, freebsd, netbsd or dragonflybsd.
# The system will be determined by using uname

QUIET:=@

DEBUGGER=gdb
GIT_HOME=https://github.com/dlang
DMD_DIR=../dmd

include $(DMD_DIR)/compiler/src/osmodel.mak

ifeq (windows,$(OS))
    DOTEXE:=.exe
    DOTOBJ:=.obj
else
    DOTEXE:=
    DOTOBJ:=.o
endif

ifeq (osx,$(OS))
	export MACOSX_DEPLOYMENT_TARGET=10.9
endif

# Default to a release build, override with BUILD=debug
ifeq (,$(BUILD))
BUILD_WAS_SPECIFIED=0
BUILD=release
else
BUILD_WAS_SPECIFIED=1
endif

ifneq ($(BUILD),release)
    ifneq ($(BUILD),debug)
        $(error Unrecognized BUILD=$(BUILD), must be 'debug' or 'release')
    endif
endif

# default to PIC, use PIC=1/0 to en-/disable PIC.
# Note that shared libraries and C files are always compiled with PIC.
ifeq ($(PIC),)
    PIC:=$(if $(findstring win,$(OS)),,1)
endif
ifeq ($(PIC),1)
    override PIC:=-fPIC
else
    override PIC:=
endif

# default to compiling the C parts (zlib) with DMD via importC; override with USE_IMPORTC=1/0
USE_IMPORTC:=1

# FreeBSD 14 can't use importC for zlib thanks to asm in stdlib.h, which dmd can't handle.
# https://issues.dlang.org/show_bug.cgi?id=24389
ifeq (freebsd,$(OS))
	USE_IMPORTC=0
endif

# Configurable stuff that's rarely edited
INSTALL_DIR = ../install
DRUNTIME_PATH = $(DMD_DIR)/druntime
DLANG_ORG_DIR = ../dlang.org
ZIPFILE = phobos.zip
ROOT_OF_THEM_ALL = generated
ROOT = $(ROOT_OF_THEM_ALL)/$(OS)/$(BUILD)/$(MODEL)
DUB=dub
TOOLS_DIR=../tools
DSCANNER_HASH=5a53c538d0aa832f03840840271b6631fbbfc53d
DSCANNER_DIR=$(ROOT_OF_THEM_ALL)/dscanner-$(DSCANNER_HASH)

# Set DRUNTIME name and full path
ifneq (,$(DRUNTIME))
	CUSTOM_DRUNTIME=1
endif
ifeq (,$(findstring win,$(OS)))
	DRUNTIME = $(DRUNTIME_PATH)/../generated/$(OS)/$(BUILD)/$(MODEL)/libdruntime.a
	DRUNTIMESO = $(basename $(DRUNTIME)).so.a
else
	DRUNTIME = $(DRUNTIME_PATH)/../generated/$(OS)/$(BUILD)/$(MODEL)/druntime.lib
endif

# Set DMD
ifeq ($(OS),win32wine)
	DMD = wine dmd.exe
	RUN = wine
else
	DMD = $(DMD_DIR)/generated/$(OS)/$(BUILD)/$(MODEL)/dmd$(DOTEXE)
	RUN =
endif

# Set NODEFAULTLIB and CPPFLAGS (for the C preprocessor)
NODEFAULTLIB:=-defaultlib= -debuglib=
CPPFLAGS:=
ifeq (,$(findstring win,$(OS)))
	CPPFLAGS := -DHAVE_UNISTD_H
# Bundled with the system library on OSX, and doesn't work with >= MacOS 11
	ifneq (osx,$(OS))
		NODEFAULTLIB += -L-lpthread -L-lm
	endif
endif

# Set CC, CC_OUTFILEFLAG and CFLAGS unless using importC
ifneq ($(USE_IMPORTC),1)
	CC := cc
	CC_OUTFILEFLAG := -o

	ifeq ($(OS),win32wine)
		CC := wine dmc.exe
		CFLAGS := $(if $(findstring $(BUILD),debug),-g,-O)
	else ifeq ($(OS),windows)
		CC := cl
		CC_OUTFILEFLAG := /Fo
		CFLAGS := /nologo /Zl /GS- $(if $(findstring $(BUILD),debug),/Z7,/O2)
	else # Posix
		CFLAGS := $(MODEL_FLAG) -fPIC -std=c11 $(if $(findstring $(BUILD),debug),-g,-O3)
		ifeq (osx64,$(OS)$(MODEL))
			CFLAGS += --target=x86_64-darwin-apple  # ARM cpu is not supported by dmd
		endif
	endif
endif


# Set DFLAGS
DFLAGS=
override DFLAGS+=-conf= -I$(DRUNTIME_PATH)/import $(DMDEXTRAFLAGS) -w -preview=dip1000 -preview=dtorfields -preview=fieldwise $(MODEL_FLAG) $(PIC)
ifeq ($(BUILD),debug)
override DFLAGS += -g -debug
else
override DFLAGS += -O -release
endif

ifdef ENABLE_COVERAGE
override DFLAGS  += -cov=ctfe
endif

ifdef NO_BOUNDSCHECKS
override DFLAGS += -boundscheck=off
endif

ifdef NO_AUTODECODE
override DFLAGS += -version=NoAutodecodeStrings
endif

UDFLAGS=-unittest -version=StdUnittest

LINKDL:=$(if $(findstring $(OS),linux),-L-ldl,)

# use timelimit to avoid deadlocks if available
TIMELIMIT:=$(if $(shell which timelimit 2>/dev/null || true),timelimit -t 90 ,)

# Set VERSION, where the file is that contains the version string
VERSION=$(DMD_DIR)/VERSION

# Set LIB, the ultimate target
ifeq (,$(findstring win,$(OS)))
	LIB:=$(ROOT)/libphobos2.a
	# 2.064.2 => libphobos2.so.0.64.2
	# 2.065 => libphobos2.so.0.65.0
	# MAJOR version is 0 for now, which means the ABI is still unstable
	MAJOR:=0
	MINOR:=$(shell awk -F. '{ print int($$2) }' $(VERSION))
	PATCH:=$(shell awk -F. '{ print int($$3) }' $(VERSION))
	# SONAME doesn't use patch level (ABI compatible)
	SONAME:=libphobos2.so.$(MAJOR).$(MINOR)
	LIBSO:=$(ROOT)/$(SONAME).$(PATCH)
else
	ifeq ($(MODEL),32)
		LIB:=phobos32mscoff.lib
	else
		LIB:=phobos$(MODEL).lib
	endif
endif

################################################################################
MAIN = $(ROOT)/emptymain.d

# Given one or more packages, returns the modules they contain
P2MODULES=$(foreach P,$1,$(addprefix $P/,$(PACKAGE_$(subst /,_,$P))))

# Packages in std. Just mention the package name here. The contents of package
# xy/zz is in variable PACKAGE_xy_zz. This allows automation in iterating
# packages and their modules.
STD_PACKAGES = std $(addprefix std/,\
  algorithm container datetime digest experimental/allocator \
  experimental/allocator/building_blocks experimental/logger \
  format logger math net uni \
  experimental range regex windows)

# Modules broken down per package

PACKAGE_std = array ascii base64 bigint bitmanip checkedint compiler complex concurrency \
  conv csv demangle encoding exception file \
  functional getopt int128 json mathspecial meta mmfile numeric \
  outbuffer package parallelism path process random signals socket stdint \
  stdio string sumtype system traits typecons \
  uri utf uuid variant zip zlib
PACKAGE_std_experimental = checkedint
PACKAGE_std_algorithm = comparison iteration mutation package searching setops \
  sorting
PACKAGE_std_container = array binaryheap dlist package rbtree slist util
PACKAGE_std_datetime = date interval package stopwatch systime timezone
PACKAGE_std_digest = crc hmac md murmurhash package ripemd sha
PACKAGE_std_experimental_logger = core filelogger \
  nulllogger multilogger package
PACKAGE_std_experimental_allocator = \
  common gc_allocator mallocator mmap_allocator package showcase typed
PACKAGE_std_experimental_allocator_building_blocks = \
  affix_allocator aligned_block_list allocator_list ascending_page_allocator \
  bucketizer fallback_allocator free_list free_tree bitmapped_block \
  kernighan_ritchie null_allocator package quantizer \
  region scoped_allocator segregator stats_collector
PACKAGE_std_format = package read spec write $(addprefix internal/, floats read write)
PACKAGE_std_math = algebraic constants exponential hardware operations \
  package remainder rounding traits trigonometry
PACKAGE_std_net = curl isemail
PACKAGE_std_range = interfaces package primitives
PACKAGE_std_regex = package $(addprefix internal/,generator ir parser \
  backtracking tests tests2 thompson kickstart)
PACKAGE_std_uni = package
PACKAGE_std_windows = charset registry syserror
PACKAGE_std_logger = core filelogger \
  nulllogger multilogger package

# Modules in std (including those in packages)
STD_MODULES=$(call P2MODULES,$(STD_PACKAGES))

# NoAutodecode test modules.
# List all modules whose unittests are known to work without autodecode enabled.
NO_AUTODECODE_MODULES= std/utf

# Other D modules that aren't under std/
EXTRA_MODULES_COMMON := $(addprefix etc/c/,curl odbc/sql odbc/sqlext \
  odbc/sqltypes odbc/sqlucode sqlite3 zlib)

EXTRA_DOCUMENTABLES := $(EXTRA_MODULES_COMMON)

EXTRA_MODULES_INTERNAL := $(addprefix std/, \
	algorithm/internal \
	$(addprefix internal/, \
		cstring memory digest/sha_SSSE3 \
		$(addprefix math/, biguintcore biguintnoasm biguintx86	\
						   errorfunction gammafunction ) \
		scopebuffer test/dummyrange test/range \
		test/sumtype_example_overloads \
		$(addprefix unicode_, comp decomp grapheme norm tables) \
		windows/advapi32 \
	) \
	typetuple \
)

EXTRA_MODULES += $(EXTRA_DOCUMENTABLES) $(EXTRA_MODULES_INTERNAL)

# Aggregate all D modules relevant to this build
D_MODULES = $(STD_MODULES) $(EXTRA_MODULES)

# Add the .d suffix to the module names
D_FILES = $(addsuffix .d,$(D_MODULES))
# Aggregate all D modules over all OSs (this is for the zip file)
ALL_D_FILES = $(addsuffix .d, $(STD_MODULES) $(EXTRA_MODULES_COMMON) \
  $(EXTRA_MODULES_LINUX) $(EXTRA_MODULES_OSX) $(EXTRA_MODULES_FREEBSD) \
  $(EXTRA_MODULES_WIN32) $(EXTRA_MODULES_INTERNAL))

# C files to be part of the build
C_MODULES := $(addprefix etc/c/zlib/, adler32 compress crc32 deflate	\
	gzclose gzlib gzread gzwrite infback inffast inflate inftrees trees uncompr zutil)
C_FILES := $(addsuffix .c, $(C_MODULES))

ifeq ($(USE_IMPORTC),1)
    C_OBJS := $(ROOT)/zlib$(DOTOBJ)
else
    C_OBJS := $(addprefix $(ROOT)/, $(addsuffix $(DOTOBJ), $(C_MODULES)))
endif

# build with shared library support (defaults to true on supported platforms)
SHARED=$(if $(findstring $(OS),linux freebsd),1,)

TESTS_EXTRACTOR=$(ROOT)/tests_extractor$(DOTEXE)
PUBLICTESTS_DIR=$(ROOT)/publictests
BETTERCTESTS_DIR=$(ROOT)/betterctests

################################################################################
# Rules begin here
################################################################################

# Main target (builds the dll on linux, too)
ifeq (1,$(SHARED))
all : lib dll
else
all : lib
endif

ifneq (,$(findstring Darwin_64_32, $(PWD)))
install:
	echo "Darwin_64_32_disabled"
else
install :
	$(MAKE) OS=$(OS) MODEL=$(MODEL) BUILD=release INSTALL_DIR=$(INSTALL_DIR) \
		DMD=$(DMD) install2
endif

.PHONY : unittest
ifeq (1,$(BUILD_WAS_SPECIFIED))
unittest : $(addsuffix .run,$(addprefix unittest/,$(D_MODULES)))
else
unittest : unittest-debug unittest-release
unittest-%:
	$(MAKE) unittest OS=$(OS) MODEL=$(MODEL) DMD=$(DMD) BUILD=$*
	DMD=$(DMD) $(DMD) -run build_v3.d unittest-$*
endif

################################################################################
# Patterns begin here
################################################################################

.PHONY: lib dll
lib: $(LIB)
dll: $(ROOT)/libphobos2.so

ifeq ($(USE_IMPORTC),1)
# the druntime dependency makes sure DMD has been built
$(ROOT)/zlib$(DOTOBJ): $(C_FILES) $(DRUNTIME)
	$(DMD) -c $(DFLAGS) $(addprefix -P=,$(CPPFLAGS) -Ietc/c/zlib) -of$@ $(C_FILES)
else
$(ROOT)/%$(DOTOBJ): %.c
	@[ -d $(dir $@) ] || mkdir -p $(dir $@) || [ -d $(dir $@) ]
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< $(CC_OUTFILEFLAG)$@
endif

$(LIB): $(C_OBJS) $(ALL_D_FILES) $(DRUNTIME)
	$(DMD) $(DFLAGS) -lib -of$@ $(DRUNTIME) $(D_FILES) $(C_OBJS)

$(ROOT)/libphobos2.so: $(ROOT)/$(SONAME)
	ln -sf $(notdir $(LIBSO)) $@

$(ROOT)/$(SONAME): $(LIBSO)
	ln -sf $(notdir $(LIBSO)) $@

$(LIBSO): override PIC:=-fPIC
$(LIBSO): $(C_OBJS) $(ALL_D_FILES) $(DRUNTIMESO)
	$(DMD) $(DFLAGS) -shared $(NODEFAULTLIB) -of$@ -L-soname=$(SONAME) $(DRUNTIMESO) $(LINKDL) $(D_FILES) $(C_OBJS)

ifeq (osx,$(OS))
# Build fat library that combines the 32 bit and the 64 bit libraries
libphobos2.a: $(ROOT_OF_THEM_ALL)/osx/release/libphobos2.a
$(ROOT_OF_THEM_ALL)/osx/release/libphobos2.a:
	$(MAKE) OS=$(OS) MODEL=32 BUILD=release
	$(MAKE) OS=$(OS) MODEL=64 BUILD=release
	lipo $(ROOT_OF_THEM_ALL)/osx/release/32/libphobos2.a \
		$(ROOT_OF_THEM_ALL)/osx/release/64/libphobos2.a \
		-create -output $@
endif

################################################################################
# Unittests
################################################################################

DISABLED_TESTS =
ifeq ($(OS),freebsd)
    ifeq ($(MODEL),32)
    # Curl tests for FreeBSD 32-bit are temporarily disabled.
    # https://github.com/braddr/d-tester/issues/70
    # https://issues.dlang.org/show_bug.cgi?id=18519
    DISABLED_TESTS += std/net/curl
    endif
endif

$(addsuffix .run,$(addprefix unittest/,$(DISABLED_TESTS))) :
	@echo Testing $@ - disabled

UT_D_OBJS:=$(addprefix $(ROOT)/unittest/,$(addsuffix $(DOTOBJ),$(D_MODULES)))
# need to recompile all unittest objects whenever sth. changes
$(UT_D_OBJS): $(ALL_D_FILES)
$(UT_D_OBJS): $(ROOT)/unittest/%$(DOTOBJ): %.d
	@mkdir -p $(dir $@)
	$(DMD) $(DFLAGS) $(UDFLAGS) -c -of$@ $<

ifneq (1,$(SHARED))

$(UT_D_OBJS): $(DRUNTIME)

$(ROOT)/unittest/test_runner$(DOTEXE): $(DRUNTIME_PATH)/src/test_runner.d $(UT_D_OBJS) $(C_OBJS) $(DRUNTIME)
	$(DMD) $(DFLAGS) $(UDFLAGS) -of$@ $(DRUNTIME_PATH)/src/test_runner.d $(UT_D_OBJS) $(C_OBJS) $(DRUNTIME) $(LINKDL) $(NODEFAULTLIB)

else

UT_LIBSO:=$(ROOT)/unittest/libphobos2-ut.so

$(UT_D_OBJS): $(DRUNTIMESO)

$(UT_LIBSO): override PIC:=-fPIC
$(UT_LIBSO): $(UT_D_OBJS) $(C_OBJS) $(DRUNTIMESO)
	$(DMD) $(DFLAGS) -shared $(UDFLAGS) -of$@ $(UT_D_OBJS) $(C_OBJS) $(DRUNTIMESO) $(LINKDL) $(NODEFAULTLIB)

$(ROOT)/unittest/test_runner$(DOTEXE): $(DRUNTIME_PATH)/src/test_runner.d $(UT_LIBSO)
	$(DMD) $(DFLAGS) -of$@ $< -L$(UT_LIBSO) $(NODEFAULTLIB)

endif

# macro that returns the module name given the src path
moduleName=$(subst /,.,$(1))

# target for batch unittests (using shared phobos library and test_runner)
unittest/%.run : $(ROOT)/unittest/test_runner$(DOTEXE)
	$(QUIET)$(TIMELIMIT)$(RUN) $< $(call moduleName,$*)

# Target for quickly running a single unittest (using static phobos library).
# For example: "make std/algorithm/mutation.test"
# The mktemp business is needed so .o files don't clash in concurrent unittesting.
%.test : %.d $(LIB)
	T=`mktemp -d /tmp/.dmd-run-test.XXXXXX` &&                                                              \
	  (                                                                                                     \
	    $(DMD) -od$$T $(DFLAGS) -main $(UDFLAGS) $(LIB) $(NODEFAULTLIB) $(LINKDL) -cov=ctfe -run $< ;     \
	    RET=$$? ; rm -rf $$T ; exit $$RET                                                                   \
	  )

# Target for quickly unittesting all modules and packages within a package,
# transitively. For example: "make std/algorithm.test"
%.test : $(LIB)
	$(MAKE) $(addsuffix .test,$(patsubst %.d,%,$(wildcard $*/*)))

# Recursive target for %.debug
# It has to be recursive as %.debug depends on $(LIB) and we don't want to
# force the user to call make with BUILD=debug.
# Therefore we call %.debug_with_debugger and pass BUILD=debug from %.debug
# This forces all of phobos to have debug symbols, which we need as we don't
# know where debugging is leading us.
%.debug_with_debugger : %.d $(LIB)
	$(DMD) $(DFLAGS) -main $(UDFLAGS) $(LIB) $(NODEFAULTLIB) $(LINKDL) $<
	$(DEBUGGER) ./$(basename $(notdir $<))

# Target for quickly debugging a single module
# For example: make DEBUGGER=ddd std/format.debug
# ddd in this case is a graphical frontend to gdb
%.debug : %.d
	BUILD=debug $(MAKE) $(basename $<).debug_with_debugger

################################################################################
# More stuff
################################################################################

# Disable implicit rule
%$(DOTEXE) : %$(DOTOBJ)

%/.directory :
	mkdir -p $* || exists $*
	touch $@

clean :
	rm -rf $(ROOT_OF_THEM_ALL) $(ZIPFILE) $(LIB)

gitzip:
	git archive --format=zip HEAD > $(ZIPFILE)

zip :
	-rm -f $(ZIPFILE)
	zip -r $(ZIPFILE) . -x .git\* -x generated\*

install2 : all
	$(eval lib_dir=$(if $(filter $(OS),osx), lib, lib$(MODEL)))
	mkdir -p $(INSTALL_DIR)/$(OS)/$(lib_dir)
	cp $(LIB) $(INSTALL_DIR)/$(OS)/$(lib_dir)/
ifeq (1,$(SHARED))
	cp -P $(LIBSO) $(INSTALL_DIR)/$(OS)/$(lib_dir)/
	cp -P $(ROOT)/$(SONAME) $(INSTALL_DIR)/$(OS)/$(lib_dir)/
	cp -P $(ROOT)/libphobos2.so $(INSTALL_DIR)/$(OS)/$(lib_dir)/
endif
	mkdir -p $(INSTALL_DIR)/src/phobos/etc
	mkdir -p $(INSTALL_DIR)/src/phobos/std
	cp -r std/* $(INSTALL_DIR)/src/phobos/std/
	cp -r etc/* $(INSTALL_DIR)/src/phobos/etc/
	cp LICENSE_1_0.txt $(INSTALL_DIR)/phobos-LICENSE.txt

ifeq (1,$(CUSTOM_DRUNTIME))
# We consider a custom-set DRUNTIME a sign they build druntime themselves
else
# This rule additionally produces $(DRUNTIMESO). Add a fake dependency
# to always invoke druntime's make. Use FORCE instead of .PHONY to
# avoid rebuilding phobos when $(DRUNTIME) didn't change.
$(DRUNTIME): FORCE
	$(MAKE) -C $(DRUNTIME_PATH) MODEL=$(MODEL) DMD=$(abspath $(DMD)) OS=$(OS) BUILD=$(BUILD)

ifeq (,$(findstring win,$(OS)))
$(DRUNTIMESO): $(DRUNTIME)
endif

FORCE:

endif

JSON = phobos.json
json : $(JSON)
$(JSON) : $(ALL_D_FILES)
	$(DMD) $(DFLAGS) -o- -Xf$@ $^

###########################################################
# HTML documentation
# the following variables will be set by dlang.org:
#     DOC_OUTPUT_DIR, STDDOC
###########################################################
SRC_DOCUMENTABLES = index.dd $(addsuffix .d,$(STD_MODULES) $(EXTRA_DOCUMENTABLES))
# Set DDOC, the documentation generator
DDOC=$(DMD) -conf= $(MODEL_FLAG) -w -c -o- -version=StdDdoc \
	-I$(DRUNTIME_PATH)/import $(DMDEXTRAFLAGS)

# D file to html, e.g. std/conv.d -> std_conv.html
# But "package.d" is special cased: std/range/package.d -> std_range.html
D2HTML=$(foreach p,$1,$(if $(subst package.d,,$(notdir $p)),$(subst /,_,$(subst .d,.html,$(subst .dd,.html,$p))),$(subst /,_,$(subst /package.d,.html,$p))))

HTMLS=$(addprefix $(DOC_OUTPUT_DIR)/, \
	$(call D2HTML, $(SRC_DOCUMENTABLES)))

$(DOC_OUTPUT_DIR)/. :
	mkdir -p $@

# For each module, define a rule e.g.:
# ../web/phobos/std_conv.html : std/conv.d $(STDDOC) ; ...
$(foreach p,$(SRC_DOCUMENTABLES),$(eval \
$(DOC_OUTPUT_DIR)/$(call D2HTML,$p) : $p $(STDDOC) ;\
  $(DDOC) project.ddoc $(STDDOC) -Df$$@ $$<))

# this target is called by dlang.org
html : $(DOC_OUTPUT_DIR)/. $(HTMLS)

build-html:
	${MAKE} -C $(DLANG_ORG_DIR) -f posix.mak phobos-prerelease

################################################################################
# Automatically create dlang/tools repository if non-existent
################################################################################

${TOOLS_DIR}:
	git clone --depth=1 ${GIT_HOME}/$(@F) $@

$(TOOLS_DIR)/checkwhitespace.d: | $(TOOLS_DIR)
$(TOOLS_DIR)/tests_extractor.d: | $(TOOLS_DIR)

#################### test for undesired white spaces ##########################
CWS_TOCHECK = Makefile
CWS_TOCHECK += $(ALL_D_FILES) index.dd

checkwhitespace: $(LIB) $(TOOLS_DIR)/checkwhitespace.d
	$(DMD) $(DFLAGS) $(NODEFAULTLIB) $(LIB) -run $(TOOLS_DIR)/checkwhitespace.d $(CWS_TOCHECK)

#############################
# Submission to Phobos are required to conform to the DStyle
# The tests below automate some, but not all parts of the DStyle guidelines.
# See also: http://dlang.org/dstyle.html
#############################

$(DSCANNER_DIR):
	git clone https://github.com/dlang-community/Dscanner $@
	git -C $@ checkout $(DSCANNER_HASH)
	git -C $@ submodule update --init --recursive

$(DSCANNER_DIR)/dsc: | $(DSCANNER_DIR) $(DMD) $(LIB)
	# debug build is faster, but disable 'missing import' messages (missing core from druntime)
	sed 's/dparse_verbose/StdLoggerDisableWarning/' $(DSCANNER_DIR)/makefile > $(DSCANNER_DIR)/dscanner_makefile_tmp
	mv $(DSCANNER_DIR)/dscanner_makefile_tmp $(DSCANNER_DIR)/makefile
	DC=$(abspath $(DMD)) DFLAGS="$(DFLAGS) -defaultlib=$(LIB)" $(MAKE) -C $(DSCANNER_DIR) githash debug

style: style_lint publictests

# runs static code analysis with Dscanner
dscanner: $(LIB)
	@# The dscanner target is without dependencies to avoid constant rebuilds of Phobos (`make` always rebuilds order-only dependencies)
	@# However, we still need to ensure that the DScanner binary is built once
	@[ -f $(DSCANNER_DIR)/dsc ] || ${MAKE} $(DSCANNER_DIR)/dsc
	@echo "Running DScanner"
	$(DSCANNER_DIR)/dsc --config .dscanner.ini -I $(DRUNTIME_PATH)/src/ --styleCheck etc std -I.

style_lint_shellcmds:
	@echo "Check for trailing whitespace"
	grep -nr '[[:blank:]]$$' $$(find etc std -name '*.d'); test $$? -eq 1

	@echo "Enforce whitespace before opening parenthesis"
	grep -nrE "\<(for|foreach|foreach_reverse|if|while|switch|catch|version)\(" $$(find etc std -name '*.d') ; test $$? -eq 1

	@echo "Enforce no whitespace after opening parenthesis"
	grep -nrE "\<(version) \( " $$(find etc std -name '*.d') ; test $$? -eq 1

	@echo "Enforce whitespace between colon(:) for import statements (doesn't catch everything)"
	grep -nr 'import [^/,=]*:.*;' $$(find etc std -name '*.d') | grep -vE "import ([^ ]+) :\s"; test $$? -eq 1

	@echo "Check for package wide std.algorithm imports"
	grep -nr 'import std.algorithm : ' $$(find etc std -name '*.d') ; test $$? -eq 1

	@echo "Enforce Allman style"
	grep -nrE '(if|for|foreach|foreach_reverse|while|unittest|switch|else|version) .*{$$' $$(find etc std -name '*.d'); test $$? -eq 1

	@echo "Enforce do { to be in Allman style"
	grep -nr 'do *{$$' $$(find etc std -name '*.d') ; test $$? -eq 1

	@echo "Enforce no space between assert and the opening brace, i.e. assert("
	grep -nrE 'assert +\(' $$(find etc std -name '*.d') ; test $$? -eq 1

	@echo "Enforce space after cast(...)"
	grep -nrE '[^"]cast\([^)]*?\)[[:alnum:]]' $$(find etc std -name '*.d') ; test $$? -eq 1

	@echo "Enforce space between a .. b"
	grep -nrE '[[:alnum:]][.][.][[:alnum:]]|[[:alnum:]] [.][.][[:alnum:]]|[[:alnum:]][.][.] [[:alnum:]]' $$(find etc std -name '*.d' | grep -vE 'std/string.d|std/uni/package.d') ; test $$? -eq 1

	@echo "Enforce space between binary operators"
	grep -nrE "[[:alnum:]](==|!=|<=|<<|>>|>>>|^^)[[:alnum:]]|[[:alnum:]] (==|!=|<=|<<|>>|>>>|^^)[[:alnum:]]|[[:alnum:]](==|!=|<=|<<|>>|>>>|^^) [[:alnum:]]" $$(find etc std -name '*.d'); test $$? -eq 1

	@echo "Validate changelog files (Do _not_ use REF in the title!)"
	@for file in $$(find changelog -name '*.dd') ; do  \
		cat $$file | head -n1 | grep -nqE '\$$\((REF|LINK2|HTTP|MREF)' && \
		{ echo "$$file: The title line can't contain links - it's already a link" && exit 1; } ;\
		cat $$file | head -n2 | tail -n1 | grep -q '^$$' || \
		{ echo "$$file: After the title line an empty, separating line is expected" && exit 1; } ;\
		cat $$file | head -n3 | tail -n1 | grep -nqE '^.{1,}$$'  || \
		{ echo "$$file: The title is supposed to be followed by a long description" && exit 1; } ;\
	done

style_lint: style_lint_shellcmds dscanner
	@echo "Check that Ddoc runs without errors"
	$(DMD) $(DFLAGS) $(NODEFAULTLIB) $(LIB) -w -D -Df/dev/null -main -c -o- $$(find etc std -type f -name '*.d') 2>&1

################################################################################
# Build the test extractor.
# - extracts and runs public unittest examples to checks for missing imports
# - extracts and runs @betterC unittests
################################################################################

$(TESTS_EXTRACTOR): $(TOOLS_DIR)/tests_extractor.d | $(LIB)
	DFLAGS="$(DFLAGS) $(LIB) $(NODEFAULTLIB) $(LINKDL)" $(DUB) build --force --compiler=$(abspath $(DMD)) --single $<
	mv $(TOOLS_DIR)/tests_extractor$(DOTEXE) $@

test_extractor: $(TESTS_EXTRACTOR)

################################################################################
# Extract public tests of a module and test them in an separate file (i.e. without its module)
# This is done to check for potentially missing imports in the examples, e.g.
# make std/format.publictests
################################################################################

publictests: $(addsuffix .publictests,$(D_MODULES))

%.publictests: %.d $(LIB) $(TESTS_EXTRACTOR) | $(PUBLICTESTS_DIR)/.directory
	@$(TESTS_EXTRACTOR) --inputdir  $< --outputdir $(PUBLICTESTS_DIR)
	@$(DMD) $(DFLAGS) $(NODEFAULTLIB) $(LIB) -main -unittest -run $(PUBLICTESTS_DIR)/$(subst /,_,$<)

################################################################################
# Check and run @betterC tests
# ----------------------------
#
# Extract @betterC tests of a module and run them in -betterC
#
#   make std/format.betterc
################################################################################

betterc-phobos-tests: $(addsuffix .betterc,$(D_MODULES))
betterc: betterc-phobos-tests

%.betterc: %.d | $(BETTERCTESTS_DIR)/.directory
	@# Due to the FORCE rule on druntime, make will always try to rebuild Phobos (even as an order-only dependency)
	@# However, we still need to ensure that the test_extractor is built once
	@[ -f "$(TESTS_EXTRACTOR)" ] || ${MAKE} "$(TESTS_EXTRACTOR)"
	$(TESTS_EXTRACTOR) --betterC --attributes betterC \
		--inputdir  $< --outputdir $(BETTERCTESTS_DIR)
	$(DMD) $(DFLAGS) $(NODEFAULTLIB) -betterC -unittest -run $(BETTERCTESTS_DIR)/$(subst /,_,$<)


################################################################################
# Full-module BetterC tests
# -------------------------
#
# Test full modules with -betterC. Edit BETTERC_MODULES and
# test/betterc_module_tests.d to add new modules to the list.
#
#   make betterc-module-tests
################################################################################

BETTERC_MODULES=std/sumtype

betterc: betterc-module-tests

betterc-module-tests: $(ROOT)/betterctests/betterc_module_tests
	$(ROOT)/betterctests/betterc_module_tests

$(ROOT)/betterctests/betterc_module_tests: test/betterc_module_tests.d $(addsuffix .d,$(BETTERC_MODULES))
	$(DMD) $(DFLAGS) $(NODEFAULTLIB) -of=$(ROOT)/betterctests/betterc_module_tests -betterC -unittest test/betterc_module_tests.d $(addsuffix .d,$(BETTERC_MODULES))

################################################################################

.PHONY : auto-tester-build
auto-tester-build:
	echo "Auto-Tester has been disabled"

.PHONY : auto-tester-test
auto-tester-test:
	echo "Auto-Tester has been disabled"

.PHONY: buildkite-test
buildkite-test: unittest betterc

.PHONY: autodecode-test
autodecode-test: $(addsuffix .test,$(NO_AUTODECODE_MODULES))

.DELETE_ON_ERROR: # GNU Make directive (delete output files on error)
