#include <filesystem>
#include <iostream>

#include "driver.hpp"

int main(int argc, char** argv)
{
    std::cout << "CWD: " << std::filesystem::current_path() << '\n';

    Driver drv {};
    int n = drv.parse(argc >= 2 ? argv[1] : "test/isel1.ssa");

    if (n != 0)
        std::cout << "fail\n";
    else
        std::cout << "ok\n";

    return n;
}