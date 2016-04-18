NORM_TARGET=normalize
NORM_SOURCE=normalize.cpp plylib.cpp

PR_TARGET=PoissonRecon
ST_TARGET=SurfaceTrimmer
PR_SOURCE=CmdLineParser.cpp Factor.cpp Geometry.cpp MarchingCubes.cpp PlyFile.cpp PoissonRecon.cpp
ST_SOURCE=CmdLineParser.cpp Factor.cpp Geometry.cpp MarchingCubes.cpp PlyFile.cpp SurfaceTrimmer.cpp

NORM_CFLAGS += -std=c++11 -w
PR_CFLAGS += -fopenmp -Wno-deprecated
LFLAGS += -lgomp

CFLAGS_DEBUG = -DDEBUG -g3
LFLAGS_DEBUG =

CFLAGS_RELEASE = -O3 -DRELEASE -funroll-loops -ffast-math
LFLAGS_RELEASE = -O3 

BIN = bin/
SRC = src/
PR_SRC = lib/PoissonRecon/
INCLUDE = lib/vcglib/

CC=/usr/local/bin/gcc-5
CXX=/usr/local/bin/g++-5
MD=mkdir

NORM_OBJECTS=$(addprefix $(BIN), $(addsuffix .o, $(basename $(NORM_SOURCE))))
PR_OBJECTS=$(addprefix $(BIN), $(addsuffix .o, $(basename $(PR_SOURCE))))
ST_OBJECTS=$(addprefix $(BIN), $(addsuffix .o, $(basename $(ST_SOURCE))))

all: CFLAGS += $(CFLAGS_DEBUG)
all: LFLAGS += $(LFLAGS_DEBUG)
all: $(BIN)
all: $(BIN)$(NORM_TARGET)
all: $(BIN)$(PR_TARGET)
all: $(BIN)$(ST_TARGET)

release: CFLAGS += $(CFLAGS_RELEASE)
release: LFLAGS += $(LFLAGS_RELEASE)
release: $(BIN)
release: $(BIN)$(PR_TARGET)
release: $(BIN)$(ST_TARGET)

clean:
	rm -f $(BIN)$(PR_TARGET)
	rm -f $(BIN)$(ST_TARGET)
	rm -f $(PR_OBJECTS)
	rm -f $(ST_OBJECTS)
	rm -f $(BIN)$(NORM_TARGET)
	rm -f $(NORM_OBJECTS)

$(BIN):
	$(MD) -p $(BIN)


$(BIN)$(PR_TARGET): $(PR_OBJECTS)
	$(CXX) -o $@ $(PR_OBJECTS) $(LFLAGS)

$(BIN)$(ST_TARGET): $(ST_OBJECTS)
	$(CXX) -o $@ $(ST_OBJECTS) $(LFLAGS)

$(BIN)$(NORM_TARGET): $(NORM_OBJECTS)
	$(CXX) -o $@ $(NORM_OBJECTS)

$(BIN)%.o: $(SRC)%.cpp
	mkdir -p $(BIN)
	$(CXX) -c -o $@ $(NORM_CFLAGS) -I$(INCLUDE) $<

$(BIN)%.o: $(PR_SRC)%.cpp
	mkdir -p $(BIN)
	$(CXX) -c -o $@ $(PR_CFLAGS) -I$(INCLUDE) $<
