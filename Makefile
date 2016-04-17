NORM_TARGET=normalize
NORM_SOURCE=normalize.cpp

BIN = bin/
SRC = src/
INCLUDE = lib/vcglib/

CC=/usr/local/bin/gcc-5
CXX=/usr/local/bin/g++-5
MD=mkdir

NORM_OBJECTS=$(addprefix $(BIN), $(addsuffix .o, $(basename $(NORM_SOURCE))))

all: $(BIN)
all: $(BIN)$(NORM_TARGET)

clean:
	rm -f $(BIN)$(NORM_TARGET)
	rm -f $(NORM_OBJECTS)

$(BIN):
	$(MD) -p $(BIN)

$(BIN)$(NORM_TARGET): $(NORM_OBJECTS)
	$(CXX) -o $@ $(NORM_OBJECTS)

$(BIN)%.o: $(SRC)%.cpp
	mkdir -p $(BIN)
	$(CXX) -c -o $@ $(CFLAGS) -I$(INCLUDE) $<

