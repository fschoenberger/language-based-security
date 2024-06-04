%{
#include <string>

#include "lexer.hpp"
using Token = yy::Parser::token;

#define yyterminate() return( Token::YYEOF )

#define YY_USER_ACTION yylloc->step(); yylloc->columns(yyleng);
#define YY_VERBOSE

%}

/* Target the C++ implementation */
%option c++
/* Leave buffer-switching to us */
%option	noyywrap 
/* Don't generate a default rule on our behalf */
%option nodefault
/* Don't try to #include unistd */
%option nounistd

/* Don't try to push tokens back into the input stream */
%option noinput 
%option nounput
%option stack
%option verbose
%option noyylineno
%option noyyget_lineno yyset_lineno yyget_out yyset_out yyget_in yyset_in
%option warn
%option noyymore
%option ecs
%option align
%option read
/* We're not writing an interpreter */
%option never-interactive batch 
/* Write a source file, but not a header file */
%option outfile="lexer.cpp"

%{

int yyFlexLexer::yylex() { abort(); }

bool Lexer::setBuffer(std::string_view str) noexcept
{
	yy_buffer_state* state = static_cast<yy_buffer_state*>(yyalloc(sizeof(yy_buffer_state)));
	if (!state)
	{
		return (false);
	}
	memset(state, 0, sizeof(yy_buffer_state));

	std::cout << "Buffer [" << static_cast<const void*>(str.data()) << ", " 
        << static_cast<const void*>(str.data() + str.size()) << "], size " 
        << str.size() << std::endl;

	state->yy_buf_size = (int) (str.size());
	state->yy_buf_pos = state->yy_ch_buf = const_cast<char*>(str.data());
	state->yy_is_our_buffer = 0;
	state->yy_input_file = NULL;
	state->yy_n_chars = state->yy_buf_size;
	state->yy_is_interactive = 0;
	state->yy_at_bol = 1;
	state->yy_fill_buffer = 0;
	state->yy_buffer_status = YY_BUFFER_NEW;

	yy_switch_to_buffer( state );

	return (true);
}

%}


/* ---- Named pattern fragments ------------------------------------------- */
newline		(\n)


%x POST_SIGIL

/* vvvv Comments not allowed beyond this point vvvvvvvvvvvvvvvvvvvvvvvvvvvv */
%%

%{
	//yylloc->step();
%}

<POST_SIGIL>[a-zA-Z\.][a-zA-Z0-9_\.]* {
		yylval->emplace<IdentifierToken>(/*yytext*/);
		BEGIN(INITIAL);
		return Token::IDENTIFIER;
	}

<POST_SIGIL>. { throw yy::Parser::syntax_error(*yylloc, "POST_SIGIL: invalid character: " + std::string(yytext)); }

<INITIAL>{
"export"	return Token::EXPORT;
"thread"	return Token::THREAD;
"section"	return Token::SECTION;

"env" 	return Token::ENV;
"phi" 	return Token::PHI;

"type"	return Token::TYPE;
"align"	return Token::ALIGN;

"data" 	return Token::DATA;

"$"			BEGIN(POST_SIGIL); return Token::DOLLAR;
","			return Token::COMMA;
"..."		return Token::ELLIPSIS;
"@"			BEGIN(POST_SIGIL); return Token::AT;
"%"			BEGIN(POST_SIGIL); return Token::PERCENT;
"function"	return Token::FUNCTION;
"("			return Token::LPAREN;
")"			return Token::RPAREN;
"{"			return Token::LBRACE;
"}"			return Token::RBRACE;
"\+"		return Token::PLUS;
":"			BEGIN(POST_SIGIL); return Token::COLON;

"sb" 		return Token::SB;
"ub" 		return Token::UB;
"sh" 		return Token::SH;
"uh" 		return Token::UH;

"jmp" 		return Token::JMP;
"jnz" 		return Token::JNZ;
"hlt" 		return Token::HLT;
"ret"		return Token::RET;
"call"		return Token::CALL;
"cast"		return Token::CAST;
"copy"		return Token::COPY;

"=" 		return Token::EQUALS;

"w" return Token::W;
"l" return Token::L;
"s" return Token::S;
"d" return Token::D;
"b" return Token::B;
"h" return Token::H;
"z" return Token::Z;

"vastart" return Token::VASTART;
"vaarg" return Token::VAARG;

store(d|s|l|w|h|b) {
	yylval->emplace<StoreToken>(/*yytext[5]*/);
	return Token::STORE; 
}

load {
	yylval->emplace<LoadToken>(/*"d"*/); //FIXME
	return Token::LOAD; 
}

load(d|s|l|w|h|b|sw|uw|sh|uh|sb|ub) { 
	yylval->emplace<LoadToken>(/*yytext + 4*/); 
	return Token::LOAD; 
}

"blit" return Token::BLIT;

alloc(4|8|16) { 
	yylval->emplace<AllocToken>(/*static_cast<int8_t>(std::stoi(yytext + 5))*/); 
	return Token::ALLOC; 
}

c(sle|slt|sge|sgt|ule|ult|uge|ugt)(w|l|s|d|q|t|h|f) {
	yylval->emplace<CompareToken>(/*std::string{yytext + 1, yytext + 4}, yytext + 4*/);
	return Token::COMPARE; 
}

c(eq|ne|le|lt|ge|gt|uo)(w|l|s|d|q|t|h|f) {
	yylval->emplace<CompareToken>(/*std::string{yytext + 1, yytext + 3}, yytext + 3*/);
	return Token::COMPARE; 
}

co(w|l|s|d|q|t|h|f) {
	yylval->emplace<CompareToken>(/*"o", yytext + 2*/);
	return Token::COMPARE; 
}

(extsw|extuw|extsh|extuh|extsb|extub|exts|truncd|stosi|stoui|dtosi|dtoui|swtof|uwtof|sltof|ultof) {
	yylval->emplace<ConversionToken>();
	return Token::CONVERSION;
}

(add|and|div|mul|neg|or|rem|sar|shl|shr|sub|udiv|urem|xor) {
	yylval->emplace<BinaryToken>();
	return Token::BINARY;
}

[-]?[0-9]+ {
	yylval->emplace<uint64_t>(/*std::stoll(yytext)*/);
	return Token::NUMBER;
}

(s_|d_)[-]?[0-9]*(\.[0-9]+)? {
	if(yytext[0] == 's' || yytext[0] == 'd')
		yylval->emplace<double>(/*std::stod(yytext + 2)*/);
	else
		yylval->emplace<double>(/*std::stod(yytext)*/);

	return Token::FLOAT;
}

\"[^\"]*\" {
	yylval->emplace<std::string>(/*yytext + 1, yyleng - 2*/);
	return Token::STRING_LITERAL;
}

"#"(.*)		yylloc->step();
[ \t]+		yylloc->step();
{newline}+	yylloc->lines (yyleng); yylloc->step();

<*>.|\n	{ throw yy::Parser::syntax_error(*yylloc, "INITIAL: invalid character: " + std::string(yytext)); }

<<EOF>>	return Token::YYEOF;
}
