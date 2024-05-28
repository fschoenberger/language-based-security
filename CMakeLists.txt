# Specify the minimum CMake version
cmake_minimum_required(VERSION 3.15)

# Define the project
project(QBE
  VERSION 1.0
  DESCRIPTION "A small compiler for the TUM language-based security course."
  LANGUAGES C CXX)

# Set C standards
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED True)
set(CMAKE_C_EXTENSIONS OFF)

# Set C++ standards
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED True)


set(COMM_SRC main.c util.c parse.c abi.c cfg.c mem.c ssa.c alias.c load.c copy.c fold.c simpl.c live.c spill.c rega.c emit.c)
set(AMD64_SRC amd64/targ.c amd64/sysv.c amd64/isel.c amd64/emit.c)
set(ARM64_SRC arm64/targ.c arm64/abi.c arm64/isel.c arm64/emit.c)
set(RV64_SRC rv64/targ.c rv64/abi.c rv64/isel.c rv64/emit.c)
set(SRC_ALL ${COMM_SRC} ${AMD64_SRC} ${ARM64_SRC} ${RV64_SRC})

# Add executable target
add_executable(qbe ${SRC_ALL})

add_subdirectory(minic)

# Add tests
#enable_testing()
#add_subdirectory(tests)

# Install targets
#install(TARGETS MyLib MyApp
#  RUNTIME DESTINATION bin
#  LIBRARY DESTINATION lib
#  ARCHIVE DESTINATION lib)

# Set CMake module path for custom Find scripts
set(CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake" ${CMAKE_MODULE_PATH})
