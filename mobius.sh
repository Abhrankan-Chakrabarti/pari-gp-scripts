#!/bin/bash
# Title:        Möbius Function Table (Ultra Sieve)
# Description:  Computes μ(n) using Pari-native vector strides.
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

GP_SCRIPT="
{
    my(N = $N);
    gettime();
    
    \\\\ State array: tracks the product of distinct prime factors processed
    \\\\ We use a small trick: use an integer array initialized to 1
    my(mu = vector(N, i, 1));
    my(sq = vector(N, i, 1));
    
    forprime(p = 2, N,
        \\\\ Mark all multiples of p^2 as 0 in a secondary mask
        my(p2 = p * p);
        if(p2 <= N,
            forstep(j = p2, N, p2, sq[j] = 0)
        );
        
        \\\\ Multiply the tracker by -1 for each unique prime factor
        forstep(i = p, N, p, mu[i] = -mu[i]);
    );
    
    \\\\ Combine the square-free mask and the sign flips
    for(i = 1, N, 
        if(sq[i] == 0, mu[i] = 0)
    );
    
    my(calc_time = gettime() / 1000.0);
    
    if(N <= 1000,
        for(n = 1, N, printf(\"%-5d %d\n\", n, mu[n])),
        printf(\"Skipping full table print for large N (%d values).\n\", N)
    );
    
    printf(\"Calculation Time: %.3f s\n\", calc_time);
}"

echo "$GP_SCRIPT" | gp -q


