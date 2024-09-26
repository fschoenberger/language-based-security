int printf();

square(int a) {
    int buf;

    *(&buf + 1) = 42;
    *(&buf - 1) = 64;

    return a * a;
}

main(int argc, void** argv) {
    int ret;
    ret = square(7);

    printf("%d\n", ret);

    return 0;
}