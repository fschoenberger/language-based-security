#include "driver.hpp"
#include "parser.hpp"

#include <fstream>
#include <iostream>
#include <sstream>
#include <string_view>


int Driver::parse(const char* filename)
{

    std::ifstream file(filename);
    if (!file)
    {
        std::cerr << "Failed to open file: " << filename << '\n';
        return -1;
    }

    Lexer scanner{};
    scanner.switch_streams(&file, nullptr);

    yy::Parser parse(scanner, *this);
    int res = parse();

    return res;
}