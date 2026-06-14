#!/bin/bash
# Title:        Möbius Function Table (Verified 2-Vector Sieve)
# Description:  Computes μ(n) and Mertens sum cleanly with parallel arrays.
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
    
    \\\\ Your original clean parallel tracks
    my(mu = vector(N, i, 1));
    my(sq = vector(N, i, 1));
    
    forprime(p = 2, N,
        my(p2 = p * p);
        if(p2 <= N,
            forstep(j = p2, N, p2, sq[j] = 0)
        );
        
        forstep(i = p, N, p, mu[i] = -mu[i]);
    );
    
    \\\\ Safe, non-interfering final combination pass with O(0) overhead Mertens math
    my(mertens = 1); \\\\ Starts with mu[1] = 1
    for(i = 1, N, 
        if(sq[i] == 0, mu[i] = 0);
        if(i > 1, mertens += mu[i]);
    );
    
    my(calc_time = gettime() / 1000.0);
    
    if(N <= 1000,
        for(n = 1, N, printf(\"%-5d %d\n\", n, mu[n])),
        printf(\"Skipping full table print for large N (%d values).\n\", N)
    );
    
    printf(\"Mertens M(%d) = %d\n\", N, mertens);
    printf(\"Calculation Time: %.3f s\n\", calc_time);
}"

echo "$GP_SCRIPT" | gp -q


