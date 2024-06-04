#pragma once

#include "parser.hpp"
#include "lexer.hpp"
#include "location.hpp"


class Driver
{
public:
	Driver() {}
	int parse(const char* filename);
};