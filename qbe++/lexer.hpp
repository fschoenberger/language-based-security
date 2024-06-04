#pragma once

#ifndef __FLEX_LEXER_H
#include "FlexLexer.h"
#endif

#define	YY_DECL	\
	yy::Parser::token_type Lexer::lex( \
			yy::Parser::semantic_type* yylval, yy::Parser::location_type* yylloc \
	)

#include "driver.hpp"
#include "parser.hpp"
#include "location.hpp"

#include <string_view>


class Lexer : public yyFlexLexer
{
public:
	Lexer() {}

	bool setBuffer(std::string_view src) noexcept;

	virtual yy::Parser::token_type lex(yy::Parser::semantic_type* yylval, yy::Parser::location_type* yylloc);
};