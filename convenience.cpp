#include "convenience.h"

#include <random>
#include <limits>

// Singleton so we don't recreate the thing every time we need a ranom number
auto& get_random_generator() {
    static std::random_device rd;
    static std::mt19937 mt(rd());
    return mt;
}

uint8_t get_random_u8() {
    std::uniform_int_distribution<uint8_t> dist(0, std::numeric_limits<uint8_t>::max());
    return dist(get_random_generator());
}

uint16_t get_random_u16() {
    std::uniform_int_distribution<uint16_t> dist(0, std::numeric_limits<uint16_t>::max());
    return dist(get_random_generator());
}

uint32_t get_random_u32() {
    std::uniform_int_distribution<uint32_t> dist(0, std::numeric_limits<uint32_t>::max());
    return dist(get_random_generator());
}

uint64_t get_random_u64() {
    std::uniform_int_distribution<uint64_t> dist(0, std::numeric_limits<uint64_t>::max());
    return dist(get_random_generator());
}