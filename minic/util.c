#include <stdio.h>
#include <stdlib.h>

__attribute__((noreturn)) void report_canary_violation() {
    printf("Stack smashing attempt detected!\n");
    exit(-2);
}