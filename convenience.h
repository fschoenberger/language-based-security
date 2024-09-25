#pragma once

#include <stdint.h>

#ifdef __cplusplus
// For name mangling
extern "C" {
#endif

uint8_t get_random_u8();
uint16_t get_random_u16();
uint32_t get_random_u32();
uint64_t get_random_u64();

#ifdef __cplusplus
}
#endif