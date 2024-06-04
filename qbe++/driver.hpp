#pragma once

#include <string>

#include "parser.hpp"
#include "lexer.hpp"
#include "location.hpp"


class Driver
{
public:
    Driver() {}
    int parse(const std::string& filename);
};