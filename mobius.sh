#!/bin/bash
# Title:        Möbius Function Table (Optimized Ultra Sieve)
# Description:  Computes μ(n) natively with half the memory footprint.
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
    
    \\\\ Use only one vector instead of two to save RAM on Termux
    my(mu = vector(N, i, 1));
    
    forprime(p = 2, N,
        \\\\ 1. Strike out squares permanently by setting them to 0
        my(p2 = p * p);
        if(p2 <= N,
            forstep(j = p2, N, p2, mu[j] = 0)
        );
        
        \\\\ 2. Flip signs for all multiples (only if they aren't already zeroed out)
        forstep(i = p, N, p,
            if(mu[i] != 0, mu[i] = -mu[i])
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


