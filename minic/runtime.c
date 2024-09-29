#include <stdio.h>
#include <stdlib.h>
#include <time.h>

__attribute__((noreturn)) void report_canary_violation() {
    printf("Stack smashing attempt detected!\n");
    exit(-2);
}

int variant_selector() {
    return 1;
}