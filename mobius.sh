#!/bin/bash
# Title:        Möbius Function Table (Optimized)
# Description:  Computes μ(n) up to N efficiently using a sieve approach.
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

# Print Unicode header from bash to avoid GP encoding issues
if (( N <= 1000 )); then
    printf "n     μ(n)\n"
    echo "------------"
fi

GP_SCRIPT="{my(N=$N); gettime(); my(mu=vector(N,n,moebius(n))); my(calc_time=gettime()/1000.0); if(N<=1000, for(n=1,N, printf(\"%-5d %d\n\",n,mu[n])), printf(\"Skipping full table print for large N (%d values).\n\",N)); printf(\"Calculation Time: %.3f s\n\",calc_time);}"

echo "$GP_SCRIPT" | gp -q

