#!/bin/bash
# Title:        Möbius Function Table (Linear Sieve)
# Description:  Computes μ(n) up to N in strict O(N) time and memory.
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

# Optimized GP Script: Strict Linear Sieve
GP_SCRIPT="
{
    my(N = $N);
    gettime();
    
    my(mu = vector(N, i, 0));
    my(primes = vector(N));
    my(spf = vector(N, i, 0)); \\\\ Smallest Prime Factor array
    my(prime_cnt = 0);
    
    mu[1] = 1;
    
    for(i = 2, N,
        if(spf[i] == 0,
            spf[i] = i;
            prime_cnt++;
            primes[prime_cnt] = i;
            mu[i] = -1;
        );
        
        for(j = 1, prime_cnt,
            my(p = primes[j]);
            my(comp = i * p);
            if(comp > N || p > spf[i], break);
            
            spf[comp] = p;
            if(i % p == 0,
                mu[comp] = 0,
                mu[comp] = -mu[i]
            );
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


