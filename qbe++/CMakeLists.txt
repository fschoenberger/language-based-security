find_package (FLEX REQUIRED)
find_package (BISON REQUIRED)

set (_scanner_cpp "${CMAKE_CURRENT_LIST_DIR}/lexer.cpp")
set (_parser_cpp  "${CMAKE_CURRENT_BINARY_DIR}/parser.cpp")
set (_parser_hpp  "${CMAKE_CURRENT_BINARY_DIR}/parser.hpp")

set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fsanitize=address")

flex_target (lexer lexer.ll "${_scanner_cpp}" DEFINES_FILE)
bison_target (parser parser.yy "${_parser_cpp}"  DEFINES_FILE "${_parser_hpp}" COMPILE_FLAGS "-Wcounterexamples")

add_flex_bison_dependency (lexer parser)

add_executable (
	qbe++

	driver.cpp

	"${BISON_parser_OUTPUTS}"
	"${FLEX_lexer_OUTPUTS}"

	driver.hpp
 "main.cpp")

set_property(TARGET qbe++ PROPERTY CXX_STANDARD 23)
set_property(TARGET qbe++ PROPERTY CXX_STANDARD_REQUIRED True)
set_property(TARGET qbe++ PROPERTY CXX_EXTENSIONS OFF)
set_property(TARGET qbe++ PROPERTY C_STANDARD 11)
set_property(TARGET qbe++ PROPERTY C_STANDARD_REQUIRED True)
set_property(TARGET qbe++ PROPERTY C_EXTENSIONS OFF)

target_include_directories (qbe++ PUBLIC "${CMAKE_CURRENT_LIST_DIR}" "${CMAKE_CURRENT_BINARY_DIR}")
