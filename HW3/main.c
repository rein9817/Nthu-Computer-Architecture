#include <stdio.h>
#include <string.h>

void mat_mul(unsigned a[2][2], unsigned b[2][2], unsigned res[2][2]) {
    unsigned tmp[2][2] = {0};
    for (unsigned i = 0; i < 2; ++i) {
        for (unsigned j = 0; j < 2; ++j) {
            for (unsigned k = 0; k < 2; ++k) {
                tmp[i][j] += a[i][k] * b[k][j];
            }
        }
    }
    memcpy(res, tmp, sizeof(tmp));
}

void mat_fast_power_recursive(unsigned base[2][2], unsigned exp, unsigned res[2][2]) {
    if (exp == 0) {
        // Base case: return identity matrix
        res[0][0] = res[1][1] = 1;
        res[0][1] = res[1][0] = 0;
        return;
    }
    if (exp == 1) {
        // Base case: return the base matrix
        memcpy(res, base, sizeof(unsigned) * 4);
        return;
    }
    unsigned temp[2][2];
    mat_fast_power_recursive(base, exp / 2, temp);
    mat_mul(temp, temp, res);
    if (exp % 2 == 1) {
        unsigned temp2[2][2];
        memcpy(temp2, res, sizeof(temp2));
        mat_mul(temp2, base, res);
    }
}

// Function to count the number of 1s in the binary representation
unsigned count_bits(unsigned n) {
    if(n==0)return 0;
    return count_bits(n>>1)+(n&1);
}

int main() {
    unsigned trans[2][2] = {{1, 1}, {1, 0}};
    int n;  // Changed to int to handle -1
    
    printf("Enter n values (enter -1 to exit):\n");
    
    while (1) {
        printf("Input n: ");
        scanf("%d", &n);
        
        // Check for exit condition
        if (n == -1) {
            printf("Program terminated.\n");
            break;
        }
        
        // Check for valid input
        if (n < 0) {
            printf("Invalid input! Please enter a non-negative integer or -1 to exit.\n");
            continue;
        }
        
        unsigned result[2][2];
        mat_fast_power_recursive(trans, (unsigned)n, result);
        
        unsigned fib_n = result[0][1];
        unsigned bit_count = count_bits(fib_n);
        
        printf("fib[%d] = %u\n", n, fib_n);
        printf("1s count in 32 LSBs of fib[%d]: %u\n\n", n, bit_count);
    }
    
    return 0;
}