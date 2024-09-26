#include "convenience.h"

#include <algorithm>
#include <array>
#include <cassert>
#include <limits>
#include <memory>
#include <optional>
#include <random>
#include <string>

// Singleton so we don't recreate the thing every time we need a ranom number
auto& get_random_generator()
{
    static std::random_device rd;
    static std::mt19937 mt(rd());
    return mt;
}

uint8_t get_random_u8()
{
    std::uniform_int_distribution<uint8_t> dist(0, std::numeric_limits<uint8_t>::max());
    return dist(get_random_generator());
}

uint8_t get_random_u8_from_interval(uint8_t min, uint8_t max) {
    std::uniform_int_distribution<uint8_t> dist(min, max);
    return dist(get_random_generator());
}

uint16_t get_random_u16()
{
    std::uniform_int_distribution<uint16_t> dist(0, std::numeric_limits<uint16_t>::max());
    return dist(get_random_generator());
}

uint32_t get_random_u32()
{
    std::uniform_int_distribution<uint32_t> dist(0, std::numeric_limits<uint32_t>::max());
    return dist(get_random_generator());
}

uint64_t get_random_u64()
{
    std::uniform_int_distribution<uint64_t> dist(0, std::numeric_limits<uint64_t>::max());
    return dist(get_random_generator());
}

template <typename T>
class ProbabilityCollection final {
public:
    ProbabilityCollection() = default;

    ProbabilityCollection(std::initializer_list<std::pair<T, int>> init_list)
    {
        for (auto& [element, weight] : init_list) {
            add(element, weight);
        }
    }

    void add(T&& element, int weight = 1)
    {
        assert(weight > 0);

        elements_.emplace_back(std::forward<T>(element));
        weights_.push_back(weight);
        total_weight_ += weight;
    }

    void add(const T& element, int weight = 1)
    {
        elements_.push_back(element);
        weights_.push_back(weight);
        total_weight_ += weight;
    }

    T& draw() noexcept
    {
        auto& gen = get_random_generator();
        std::uniform_int_distribution<size_t> dist(0, total_weight_ - 1);

        auto random_weight = dist(gen);
        auto cumulative_weight = 0;

        for (size_t i = 0; i < elements_.size(); ++i) {
            cumulative_weight += weights_[i];
            if (random_weight < cumulative_weight) {
                return elements_[i];
            }
        }

        return elements_.back();
    }

private:
    std::vector<T> elements_;
    std::vector<int> weights_;
    int total_weight_ = 0;
};

auto& get_nops()
{
    static std::unique_ptr<ProbabilityCollection<std::string>> ret = nullptr;

    if (!ret) {
        ret = std::unique_ptr<ProbabilityCollection<std::string>>(new ProbabilityCollection<std::string> {
            { "# NOP omitted", 10},
            { "nop", 1 },
            { "nopl (%rax)", 1 },
            { "nopw 0x0(%rax)", 1 },
            { "nopw 0x0(%rax,%rax,1)", 1 },
            { "nopw 0x0(%rax,%rax,1)", 1 },
            { "nopl 0x0(%rax)", 1 },
            { "nopl 0x0(%rax,%rax,1)", 1 },
            { "nopw 0x0(%rax,%rax,1)", 1 },
            { "nopw 0x0(%rax,%rax,1)", 1 },
            
            { "movq %rax, %rax", 1 },
        });
    }

    return *ret;
}

const char* get_random_nop_instruction_sequence() { return get_nops().draw().c_str(); }