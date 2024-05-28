find_package(BISON REQUIRED)

bison_target(parser minic.y "${CMAKE_CURRENT_BINARY_DIR}/y.tab.c")

add_executable(minic y.tab.c)