#pragma once

#include <stdint.h>


#ifdef __cplusplus
// For name mangling
extern "C" {
#endif

// #include "all.h"

uint8_t get_random_u8();
uint8_t get_random_u8_from_interval(uint8_t min, uint8_t max);
uint16_t get_random_u16();
uint32_t get_random_u32();
uint64_t get_random_u64();

// This is a really poor wrapper for a std::unordered_map
// Let's not talk about lifetime here, because this is going to make me very sad.

void add_parsed_function(const char* name, void* function);
void* get_parsed_function(const char* name);

void for_each_parsed_function(void (*callback)(void*));


const char* get_random_nop_instruction_sequence();

#ifdef __cplusplus
}
#endif