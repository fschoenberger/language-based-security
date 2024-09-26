#pragma once

#include <stdint.h>

#ifdef __cplusplus
// For name mangling
extern "C" {
#endif

uint8_t get_random_u8();
uint8_t get_random_u8_from_interval(uint8_t min, uint8_t max);
uint16_t get_random_u16();
uint32_t get_random_u32();
uint64_t get_random_u64();

const char* get_random_nop_instruction_sequence();

#ifdef __cplusplus
}
#endif