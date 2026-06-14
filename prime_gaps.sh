#!/bin/bash
# Title:        Prime Gap Explorer (Optimized)
# Description:  Computes max prime gaps efficiently using continuous streaming.
# Dependencies: pari-gp

if ! command -v gp &> /dev/null; then
    echo "Error: Pari/GP is not installed."
    exit 1
fi

printf "This program computes prime gaps for the first n primes.\n\n"

if [[ -n "$1" ]]; then
    n=$1
else
    printf "Enter the number of primes (n): "
    read n
fi

if ! [[ "$n" =~ ^[0-9]+$ ]] || (( n < 2 )); then
    echo "Error: Input must be an integer >= 2."
    exit 1
fi

# Optimized GP script: Uses a simple loop to keep memory usage at virtually zero.
GP_SCRIPT="
{
    my(n = $n, p_prev = 2, p_curr, gap, max_gap = 0);
    gettime();
    
    for(i = 2, n,
        p_curr = prime(i);
        gap = p_curr - p_prev;
        if(gap > max_gap, max_gap = gap);
        p_prev = p_curr;
    );
    
    printf(\"Total Primes Processed: %d\n\", n);
    printf(\"Last Prime Reached:     %d\n\", p_prev);
    printf(\"Max gap found:          %d\n\", max_gap);
    printf(\"Time elapsed:           %.3f s\n\", gettime()/1000.0);
}"

echo "$GP_SCRIPT" | gp -q


