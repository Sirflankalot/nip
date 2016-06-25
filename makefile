CC        := gcc
CXX       := g++

WARNINGS  := -Wall -Wextra 
FULLWARN  := -Wall -Wextra -Wpedantic
STD       := -std=c++1y
OPTIMIZE  := -O3
DEBUG     := 
INCLUDES  := 
LINK      := 

MODULES   := Error
SRC_DIR   := src $(addprefix src/,$(MODULES))
BUILD_DIR := bin $(addprefix bin/,$(MODULES))

SRC       := $(foreach sdir,$(SRC_DIR),$(wildcard $(sdir)/*.cpp))
OBJ       := $(patsubst src/%.cpp,bin/%.o,$(SRC))
#INCLUDES  := $(addprefix -I,$(SRC_DIR))

#ifeq ($(CXX), g++)
#	OPTIMIZE += -flto -fwhole-program
#endif


.PHONY: all checkdirs clean

all: checkdirs nip

debug: DEBUG = -g
debug: OPTIMIZE = -O0
debug: checkdirs nip

profile: DEBUG = -pg
profile: checkdirs nip

warn: WARNINGS = $(FULLWARN)
warn: checkdirs nip



vpath %.cpp $(SRC_DIR)

define make-goal
$1/%.o: %.cpp
	@echo $(CXX) $$<
	@$$(CXX) $$(WARNINGS) $$(STD) $$(OPTIMIZE) $$(DEBUG) $$(INCLUDES) -c $$< -o $$@

$1/%-sse.o: %-sse.cpp
	@echo $(CXX) $$< -msse4.1
	@$$(CXX) $$(WARNINGS) $$(STD) $$(OPTIMIZE) -msse4.1 $$(DEBUG) $$(INCLUDES) -c $$< -o $$@

$1/%-sse2.o: %-sse2.cpp
	@echo $(CXX) $$< -msse2
	@$$(CXX) $$(WARNINGS) $$(STD) $$(OPTIMIZE) -msse2 $$(DEBUG) $$(INCLUDES) -c $$< -o $$@

$1/%-sse3.o: %-sse3.cpp
	@echo $(CXX) $$< -mssse3
	@$$(CXX) $$(WARNINGS) $$(STD) $$(OPTIMIZE) -mssse3 $$(DEBUG) $$(INCLUDES) -c $$< -o $$@

$1/%-sse4.o: %-sse4.cpp
	@echo $(CXX) $$< -msse4.1
	@$$(CXX) $$(WARNINGS) $$(STD) $$(OPTIMIZE) -msse4.1 $$(DEBUG) $$(INCLUDES) -c $$< -o $$@

$1/%-sse42.o: %-sse42.cpp
	@echo $(CXX) $$< -msse4.2
	@$$(CXX) $$(WARNINGS) $$(STD) $$(OPTIMIZE) -msse4.2 $$(DEBUG) $$(INCLUDES) -c $$< -o $$@

$1/%-avx.o: %-avx.cpp
	@echo $(CXX) $$< -mavx
	@$$(CXX) $$(WARNINGS) $$(STD) $$(OPTIMIZE) -mavx $$(DEBUG) $$(INCLUDES) -c $$< -o $$@

$1/%-avx2.o: %-avx2.cpp
	@echo $(CXX) $$< -mavx2
	@$$(CXX) $$(WARNINGS) $$(STD) $$(OPTIMIZE) -mavx2 $$(DEBUG) $$(INCLUDES) -c $$< -o $$@
endef



nip: $(OBJ)
	@echo Linking $@
	@$(CXX) $(DEBUG) $(OPTIMIZE) $^ -o $@ $(LINK)

checkdirs: $(BUILD_DIR)

$(BUILD_DIR):
	@mkdir -p $@

clean:
	@rm -rf bin/*
	@rm -f nip

$(foreach bdir,$(BUILD_DIR),$(eval $(call make-goal,$(bdir))))