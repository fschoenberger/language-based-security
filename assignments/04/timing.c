#include <unistd.h>
#include <stdio.h>

int main(int argc, char** argv) {
    const char real_password[] = "1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ";

    if(argc < 2) {
        return 5;
    }

    for(int i = 0; i < sizeof(real_password); ++i) {
        if(argv[1][i] != real_password[i]) {
            printf("Noooooo\n");
            return 1;
        }

        // Just so the python script is easier
        usleep(800);
    }

    printf("Yay!\n");
    return 0;
}