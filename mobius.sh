#!/bin/bash
# Title:        Möbius Function Table
# Description:  Computes the Möbius function μ(n) for integers up to N.
# Dependencies: pari-gp (Computer Algebra System)

# Check for Pari/GP
if ! command -v gp &> /dev/null; then
    echo "Error: Pari/GP is not installed. See README for install instructions."
    exit 1
fi

printf "This program computes the Möbius function μ(n) for integers up to N.\n\n"

# Accept argument or prompt
if [[ -n "$1" ]]; then
    N=$1
else
    printf "Enter N (upper bound): "
    read N
fi

# Validate input
if ! [[ "$N" =~ ^[0-9]+$ ]] || (( N < 1 )); then
    echo "Error: Input must be a positive integer."
    exit 1
fi

# Run Pari/GP — wrapped in a single block to preserve my() scoping
printf "n     μ(n)\n"
GP_SCRIPT="{my(N=$N, values=vector(N,n,moebius(n))); gettime(); for(n=1,N, printf(\"%-5d %d\n\",n,values[n])); printf(\"Time: %.3f s\n\",gettime()/1000.0);}"

echo "$GP_SCRIPT" | gp -q

