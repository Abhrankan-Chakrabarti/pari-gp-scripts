#!/bin/bash
# Title:        Möbius Function Table (True Sieve)
# Description:  Computes μ(n) up to N instantly using an O(N) array sieve.
# Dependencies: pari-gp

if ! command -v gp &> /dev/null; then
    echo "Error: Pari/GP is not installed. See README for install instructions."
    exit 1
fi

printf "This program computes the Möbius function μ(n) for integers up to N.\n\n"

if [[ -n "$1" ]]; then
    N=$1
else
    printf "Enter N (upper bound): "
    read N
fi

if ! [[ "$N" =~ ^[0-9]+$ ]] || (( N < 1 )); then
    echo "Error: Input must be a positive integer."
    exit 1
fi

if (( N <= 1000 )); then
    printf "n     μ(n)\n"
    echo "------------"
fi

# Optimized GP Script: True sieve logic
# 1. Initialize vector with 1s
# 2. Identify prime factors to flip the sign (mu = -mu)
# 3. Identify square prime factors to set mu = 0
GP_SCRIPT="
{
    my(N = $N);
    gettime();
    
    my(mu = vector(N, i, 1));
    
    forprime(p = 2, N,
        \\\\ Flip sign for all multiples of this prime
        forstep(i = p, N, p, mu[i] = -mu[i]);
        
        \\\\ Zero out all multiples of p^2
        my(p2 = p * p);
        if(p2 <= N,
            forstep(j = p2, N, p2, mu[j] = 0)
        );
    );
    
    my(calc_time = gettime() / 1000.0);
    
    if(N <= 1000,
        for(n = 1, N, printf(\"%-5d %d\n\", n, mu[n])),
        printf(\"Skipping full table print for large N (%d values).\n\", N)
    );
    
    printf(\"Calculation Time: %.3f s\n\", calc_time);
}"

echo "$GP_SCRIPT" | gp -q


