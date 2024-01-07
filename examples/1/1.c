#include <stdio.h>

int d = 5 + 1;

// Describes foo function.
int foo() {
    return d;
}

int main() {
    int g = foo();

    for(int i = g; i < 10; i++) {
        printf("Hello world");
    }

    if (12 == 12) {
        printf("It works");
    }

    int i = 10; 

    while (i < 20) {
        printf("Slava Ukraini!");

        i++;
    }

    return 1;
}