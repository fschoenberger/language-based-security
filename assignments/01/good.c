int printf();

square(int a) { return a * a; }

main(int argc, void** argv)
{
    int ret;
    ret = square(7);

    printf("%d\n", ret);

    return 0;
}