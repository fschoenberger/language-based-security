int printf();

test_fn(int x) {
    int y;
    int z;

    y = x;
    y = y * 2;
    y = y * 4;
    y = y * 8;
    y = y * 16;

    z = x;
    z = z * 32;
    z = z * 64;
    z = z * 128;

    return y - z;
}

main(int argc, void** argv)
{
    int ret;
    ret = test_fn(1);

    printf("%d (expected: -261120)\n", ret);

    return 0;
}