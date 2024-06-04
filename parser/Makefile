# Compiler and tools
CXX = clang++
FLEX = flex++
BISON = bison

# Flags
CXXFLAGS = -Wall -Wextra -Wpedantic -std=c++2b -DYYDEBUG=1 -g  -fsanitize=address
LDFLAGS = #-lfl

# Sources
LEXER_SRC = lexer.ll
PARSER_SRC = parser.yy
PARSER_HPP = parser.hpp

# Generated files
LEXER_CXX = lexer.cpp
PARSER_CXX = parser.cpp
PARSER_OUTPUTS = parser.cpp parser.hpp parser.output location.hpp

# Executable
TARGET = parser

# All target
all: $(TARGET)

# Build the final executable
$(TARGET): $(LEXER_CXX) $(PARSER_CXX) driver.cpp
	$(CXX) $(CXXFLAGS) -o $(TARGET) $(LEXER_CXX) $(PARSER_CXX) driver.cpp $(LDFLAGS)

# Generate lexer from Flex
$(LEXER_CXX): $(LEXER_SRC) $(PARSER_CXX)
	$(FLEX) -d -o$(LEXER_CXX) $(LEXER_SRC)

# Generate parser from Bison
$(PARSER_CXX): $(PARSER_SRC)
	$(BISON) -Wcounterexamples -d $(PARSER_SRC)

# Clean up generated files
clean:
	rm -f $(TARGET) $(LEXER_CXX) $(PARSER_OUTPUTS)

# Test target
test: $(TARGET)
	@for file in ../test/*; do \
		basename=$$(basename $$file); \
		# if [ "$$basename" != "$${basename#_}" ]; then \
		#	continue; \
		# fi; \
		./$(TARGET) $$file; \
		if [ $$? -eq 0 ]; then \
			echo "\033[0;32mPass: $$file\033[0m"; \
		else \
			echo "\033[0;31mFail: $$file\n\033[0m"; \
		fi; \
	done

# Phony targets
.PHONY: all clean test
