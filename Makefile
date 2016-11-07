# Copyright (C) 2012-2016. TomTom International BV (http://tomtom.com).
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

CXX?=g++
CCFLAGS?=

USE_BOOST?=0
USE_MMAP?=1
HAS_MEMRCHR?=1

ifeq ($(USE_BOOST),1)
CCFLAGS+=-DUSE_BOOST
LDFLAGS+=-lboost_filesystem -lboost_system
else
LDFLAGS+=-lstdc++fs
endif

ifeq ($(USE_MMAP),1)
CCFLAGS+=-DUSE_MMAP
endif

ifeq ($(HAS_MEMRCHR),1)
else
CCFLAGS+=-DNO_MEMRCHR
endif

OPTFLAGS?=-O3
STANDARD=c++11

SOURCES=Component.cpp Configuration.cpp generated.cpp Input.cpp Output.cpp CmakeRegen.cpp Analysis.cpp

TESTS=AnalysisCircularDependencies.cpp test.cpp

all: cpp-dependencies

obj/%.o: src/%.cpp
	@mkdir -p obj
	$(CXX) -c -Wall -Wextra -Wpedantic -o $@ $< -std=$(STANDARD) $(CCFLAGS) $(OPTFLAGS) -MMD

obj/%.coverage.o: src/%.cpp
	@mkdir -p obj
	$(CXX) -c -Wall -Wextra -Wpedantic -o $@ $< -std=$(STANDARD) $(CCFLAGS) -g -MMD --coverage

test/obj/%.coverage.o: test/%.cpp
	@mkdir -p test/obj
	$(CXX) -c -Wall -Wextra -Wpedantic -o $@ $< -std=$(STANDARD) $(CCFLAGS) -Isrc -g -MMD --coverage

cpp-dependencies: $(patsubst %.cpp,obj/%.o,$(SOURCES)) obj/main.o
	$(CXX) -o $@ $^ $(LDFLAGS) $(OPTFLAGS) 

cpp-dependencies-unittests: $(patsubst %.cpp,obj/%.coverage.o,$(SOURCES)) $(patsubst %.cpp,test/obj/%.coverage.o,$(TESTS))
	$(CXX) -o $@ $^ $(LDFLAGS) -g -pthread --coverage

unittest: cpp-dependencies-unittests
	./cpp-dependencies-unittests >unittest

clean:
	rm -rf obj cpp-dependencies

install:
	cp cpp-dependencies /usr/bin

-include $(patsubst %.cpp,obj/%.o.d,$(SOURCES)) $(patsubst %.cpp,test/obj/%.o.d,$(TESTS))

