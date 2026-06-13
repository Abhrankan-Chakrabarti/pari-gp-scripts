#!/bin/bash
# Title: Gilbreath Triangle Generator
# Description: Generates a Gilbreath Triangle for the first n primes
#              and verifies Gilbreath's conjecture at each row.
# Dependencies: pari-gp (Computer Algebra System)

# Check for Pari/GP
if ! command -v gp &> /dev/null; then
    echo "Error: Pari/GP is not installed. See README for install instructions."
    exit 1
fi

printf "This program generates a Gilbreath Triangle.\n\n"

# Accept arguments or prompt
if [[ -n "$1" ]]; then
    n=$1
else
    printf "Enter the number of primes (n): "; read n
fi

if [[ -n "$2" ]]; then
    quiet=$2
else
    quiet=0
fi

# Validate input
if ! [[ "$n" =~ ^[0-9]+$ ]] || (( n < 1 )); then
    echo "Error: Input must be a positive integer."
    exit 1
fi

if ! [[ "$quiet" =~ ^[01]$ ]]; then
    echo "Error: Second argument must be 0 or 1 for quiet mode."
    exit 1
fi

# Build GP script and pipe to gp
GP_SCRIPT="my(n = $n); my(quiet = $quiet); my(row = primes(n)); if(!quiet, print(\"Row 0: \", row)); my(failed = 0); gettime(); for(r = 1, n - 1, row = vector(#row - 1, i, abs(row[i] - row[i+1])); if(!quiet, print(\"Row \", r, \": \", row)); if(row[1] != 1, print(\"Gilbreath condition failed at row \", r); failed = 1; break())); if(!failed, print(\"Gilbreath holds for first \", n, \" primes\")); printf(\"Time: %.3f s\\n\", gettime()/1000.0);"
echo "$GP_SCRIPT" | gp -q

