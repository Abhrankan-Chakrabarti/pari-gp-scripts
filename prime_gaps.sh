#!/bin/bash
# Title:        Prime Gap Explorer
# Description:  Computes gaps between consecutive primes up to the first n primes.
# Dependencies: pari-gp (Computer Algebra System)

# Check for Pari/GP
if ! command -v gp &> /dev/null; then
    echo "Error: Pari/GP is not installed. See README for install instructions."
    exit 1
fi

printf "This program computes prime gaps for the first n primes.\n\n"

# Accept argument or prompt
if [[ -n "$1" ]]; then
    n=$1
else
    printf "Enter the number of primes (n): "
    read n
fi

# Validate input
if ! [[ "$n" =~ ^[0-9]+$ ]] || (( n < 2 )); then
    echo "Error: Input must be an integer >= 2."
    exit 1
fi

# Run Pari/GP — wrapped in a single block so my() scoping is preserved
GP_SCRIPT="{my(n=$n, primes=vector(n,i,prime(i)), gaps=vector(n-1,i,primes[i+1]-primes[i])); gettime(); print(\"Primes: \",primes); print(\"Gaps:   \",gaps); printf(\"Max gap: %d\n\",vecmax(gaps)); printf(\"Time: %.3f s\n\",gettime()/1000.0);}"

echo "$GP_SCRIPT" | gp -q

