%start root

%language "C++"
/* %skeleton "lalr1.cc" */
%require "3.8"

%locations

%defines "parser.hpp"	// Emit a header file with tokens etc
%output  "parser.cpp"	// Name of the parser source

%define api.location.file	"location.hpp"

%define api.parser.class    {Parser}

%define api.token.raw
/* %define api.token.constructor */
%define api.value.type variant

%define parse.assert /* Tell the parser to assert if it gets into a bad state */
%define parse.trace
%define parse.error detailed /* "unexpected" is unhelpful. "unexpected IDENTIFIER, expected NUMBER or STRING_LITERAL" is better. */
%define parse.lac full /* Try and do lookahead correction so it can say "did you mean 'response?'" */

%code requires
{
	#include <string>
    #include <cstdint>
    #include <stdexcept>

    #include "ast.hpp"

    class Driver;
    class Lexer;
    
    struct StoreToken {
        enum class Size : int8_t {
            kD, kS, kL, kW, kH, kB, kNone = -1      
        } size = Size::kNone;

        StoreToken() noexcept = default;

        StoreToken(char c): size([](char c) -> Size {
            switch (c) {
                case 'd': return Size::kD;
                case 's': return Size::kS;
                case 'l': return Size::kL;
                case 'w': return Size::kW;
                case 'h': return Size::kH;
                case 'b': return Size::kB;
                default: throw std::runtime_error("Invalid store token");
            }
        }(c)) {}
    };

    struct LoadToken {
        enum class Size : int8_t  {kD, kS, kL, kH, kB, kSW, kUW, kSH, kUH, kSB, kUB, kNone = -1} size = Size::kNone;

        LoadToken() noexcept = default;

        LoadToken(const std::string& token) : size([](const std::string& token) -> Size {
            if (token == "d") return Size::kD;
            if (token == "s") return Size::kS;
            if (token == "l") return Size::kL;
            if (token == "h") return Size::kH;
            if (token == "b") return Size::kB;
            if (token == "w" || token == "sw") return Size::kSW;
            if (token == "uw") return Size::kUW;
            if (token == "sh") return Size::kSH;
            if (token == "uh") return Size::kUH;
            if (token == "sb") return Size::kSB;
            if (token == "ub") return Size::kUB;

            throw std::runtime_error("Invalid load token");
        }(token)) {}
    };

    struct AllocToken {
        int8_t size = -1;
    };

    struct CompareToken {
        enum class Operation : int8_t { 
            kEQ, kNE, kSLE, kSLT, kSGE, kSGT, kULE, kULT, kUGE, kUGT, // Integers
            kLE, kLT, kGE, kGT, kO, kUO,  //Floats
            kNone = -1 } operation = Operation::kNone;

        enum class Type : int8_t { kD, kS, kL, kW, kH, kB, kNone = -1 } type = Type::kNone;

        CompareToken() noexcept = default;

        CompareToken(const std::string& operation, const std::string& type)
            : operation([](const std::string& operation) -> Operation {
                if (operation == "eq") return Operation::kEQ;
                if (operation == "ne") return Operation::kNE;
                if (operation == "sle") return Operation::kSLE;
                if (operation == "slt") return Operation::kSLT;
                if (operation == "sge") return Operation::kSGE;
                if (operation == "sgt") return Operation::kSGT;
                if (operation == "ule") return Operation::kULE;
                if (operation == "ult") return Operation::kULT;
                if (operation == "uge") return Operation::kUGE;
                if (operation == "ugt") return Operation::kUGT;
                if (operation == "le") return Operation::kLE;
                if (operation == "lt") return Operation::kLT;
                if (operation == "ge") return Operation::kGE;
                if (operation == "gt") return Operation::kGT;
                if (operation == "o") return Operation::kO;
                if (operation == "uo") return Operation::kUO;

                throw std::runtime_error("Invalid compare operation: " + operation);
            }(operation)),
            type([](const std::string& type) -> Type {
                if (type == "d") return Type::kD;
                if (type == "s") return Type::kS;
                if (type == "l") return Type::kL;
                if (type == "w") return Type::kW;
                if (type == "h") return Type::kH;
                if (type == "b") return Type::kB;

                throw std::runtime_error("Invalid compare type: " + type);
            }(type)) {}
    };

    struct ConversionToken {

    };

    struct BinaryToken {
        enum class Operation {
            kAdd, kAnd, kDiv, kMul, kNeg, kOr, KRem, kSar, kShl, kShr, kSub, kUdiv, kUrem, KXor, kNone = -1
        } op = Operation::kNone;
    };

    struct IdentifierToken {
        std::string name;
    };

}

%parse-param { Lexer& lexer }
%parse-param { Driver& driver }

%code
{

	#include "driver.hpp"
	#include "lexer.hpp"

	#define yylex lexer.lex
}

%token YYEOF 0 "end of file" 
%token <IdentifierToken> IDENTIFIER
%token <uint64_t> NUMBER
%token <double> FLOAT
%token <std::string> STRING_LITERAL

// Instructions
%token <AllocToken> ALLOC "ALLOC"
%token <StoreToken> STORE "STORE"
%token <LoadToken> LOAD "LOAD"
%token <CompareToken> COMPARE "COMPARE"
%token <ConversionToken> CONVERSION "CONVERSION"
%token <BinaryToken> BINARY "BINARY"

%token 
    EXPORT "export"
    THREAD "thread"
    SECTION "section"
//------------------------
    ENV "env" 
//------------------------
    DOLLAR "$"
    COMMA ","
    ELLIPSIS "..."
    AT "@"
    PERCENT "%" 
    FUNCTION "function" 
    LPAREN "("
    RPAREN ")"
    LBRACE "{"
    RBRACE "}" 
    PLUS "+"
    COLON ":"
    EQUALS "="
// Basic types
    SB "sb"
    UB "ub" 
    SH "sh"
    UH "uh" 
// Jump instructions
    JMP "jmp"
    JNZ "jnz"
    HLT "hlt"
    RET "ret"
    CALL "call"
    CAST "cast"
    COPY "copy"
    BLIT "BLIT"
//------------------------
    W "w"
    L "l"
    S "s"
    D "d"
    B "b"
    H "h"
    Z "z"
//------------------------
    TYPE "type"
    ALIGN "align"
    DATA "data"
    PHI "phi"
//------------------------
    VASTART "vastart"
    VAARG "vaarg"

/* %nterm <ast::Root> root */

%%
root: YYEOF | definition_list YYEOF;

base_type: W | L | S | D; // Base types
extended_type: base_type | B | H;    // Extended types 
sub_type: extended_type | COLON IDENTIFIER;

const: NUMBER | FLOAT | DOLLAR IDENTIFIER;
dynconst: const | THREAD DOLLAR IDENTIFIER;
val: dynconst | PERCENT IDENTIFIER;

definition_list: definition_list definition | definition;

definition: funcdef | typedef | datadef;

sub_word_type: SB | UB | SH | UH;  // Sub-word types
abi_type: base_type | sub_word_type | COLON IDENTIFIER; // ABI types

linkage_list: linkage | linkage_list linkage;
linkage: linkages;
linkages: EXPORT | THREAD | SECTION sec_name | SECTION sec_name sec_flags;
sec_name: STRING_LITERAL;
sec_flags: STRING_LITERAL;

/****************************************************************************************
 * Function definitions
 ****************************************************************************************/
funcdef: funcdef2 | linkage_list funcdef2;

funcdef2: FUNCTION abi_type DOLLAR IDENTIFIER LPAREN param_list RPAREN LBRACE block_list RBRACE
    | FUNCTION /*abi_types*/ DOLLAR IDENTIFIER LPAREN param_list RPAREN LBRACE block_list RBRACE;

param_list: %empty | param_list COMMA param | param; 
param: abi_type PERCENT IDENTIFIER | ENV PERCENT IDENTIFIER | ELLIPSIS;

block_list: block_list block | block;

call: CALL val LPAREN arg_list RPAREN;
arg_list: %empty | arg_list COMMA arg | arg;
arg: abi_type val | ENV val | ELLIPSIS;

instruction_list: instruction_list instruction | instruction;
instruction: PERCENT IDENTIFIER EQUALS abi_type expression
    | STORE val COMMA val
    | call
    | BLIT val COMMA val COMMA NUMBER
    | VASTART val;

expression: LOAD val
    | ALLOC NUMBER
    | COMPARE val COMMA val
    | COPY val 
    | CAST val
    | CONVERSION val
    | BINARY val COMMA val
    | call
    | PHI phi_varlist
    | VAARG val;

phi_varlist: phi_var | phi_var COMMA phi_varlist;
phi_var: AT IDENTIFIER val;

block: AT IDENTIFIER instruction_list jump;
    | AT IDENTIFIER instruction_list
    | AT IDENTIFIER jump
    | AT IDENTIFIER;
    
jump: JMP AT IDENTIFIER | JNZ val COMMA AT IDENTIFIER COMMA AT IDENTIFIER | HLT | RET val | RET;

/****************************************************************************************
 * Typedefs
 ****************************************************************************************/
typedef: TYPE COLON IDENTIFIER EQUALS ALIGN NUMBER LBRACE type_block RBRACE
    | TYPE COLON IDENTIFIER EQUALS LBRACE type_block RBRACE
    | TYPE COLON IDENTIFIER EQUALS ALIGN NUMBER LBRACE NUMBER RBRACE; // Opaque types

type_block: type_list | union_type_list;
type_list: type_block_item | type_block COMMA type_block_item;

union_type_list: union_type | union_type_list union_type;
union_type: LBRACE type_list RBRACE; 

type_block_item: sub_type NUMBER | sub_type;

/****************************************************************************************
 * Data defs
 ****************************************************************************************/
datadef: linkage_list DATA DOLLAR IDENTIFIER EQUALS ALIGN NUMBER LBRACE data_block RBRACE
    | /*linkage_list*/ DATA DOLLAR IDENTIFIER EQUALS /*ALIGN NUMBER*/ LBRACE data_block RBRACE
    | /* linkage_list */ DATA DOLLAR IDENTIFIER EQUALS ALIGN NUMBER LBRACE data_block RBRACE
    | linkage_list DATA DOLLAR IDENTIFIER EQUALS /*ALIGN NUMBER*/ LBRACE data_block RBRACE;

data_block: data_block_item | data_block COMMA data_block_item;
data_block_item: extended_type data_item_list | Z NUMBER;
data_item_list: data_item | data_item_list data_item;
data_item: DOLLAR IDENTIFIER | DOLLAR IDENTIFIER PLUS NUMBER | STRING_LITERAL | /*const*/ NUMBER | FLOAT;
%%

#include <iostream>

void yy::Parser::error(const location_type& l, const std::string& m)
{
	std::cerr << l << ": " << m << "\n";
}