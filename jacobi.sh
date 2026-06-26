#!/bin/bash
# Title:        Jacobi Symbol
# Description:  Computes the Jacobi symbol (a/n) for a given a across all odd
#               integers n up to N, or for a fixed pair (a, n).
# Dependencies: pari-gp (Computer Algebra System)

# Check for Pari/GP
if ! command -v gp &> /dev/null; then
    echo "Error: Pari/GP is not installed. See README for install instructions."
    exit 1
fi

printf "This program computes the Jacobi symbol (a/n).\n\n"

# Accept arguments or prompt
if [[ -n "$1" ]]; then
    a=$1
else
    printf "Enter a: "
    read a
fi

if [[ -n "$2" ]]; then
    N=$2
else
    printf "Enter N (upper bound for odd n): "
    read N
fi

outfile=$3

# Validate input
if ! [[ "$a" =~ ^-?[0-9]+$ ]]; then
    echo "Error: a must be an integer."
    exit 1
fi

if ! [[ "$N" =~ ^[0-9]+$ ]] || (( N < 1 )); then
    echo "Error: N must be a positive integer."
    exit 1
fi

# Run Pari/GP
if [[ -n "$outfile" ]]; then
    # TSV export mode — tagged stream pipeline
    GP_SCRIPT="{
        my(a=$a, N=$N, j);
        gettime();
        print(\"DATA_START\");
        forstep(n=1, N, 2,
            j = kronecker(a, n);
            print(n, \"\t\", j)
        );
        print(\"DATA_END\");
        printf(\"Calculation Time: %.3f s\n\", gettime()/1000.0);
    }"

    test -e "$outfile" || echo -e "n\tjacobi($a,n)" > "$outfile"
    echo "$GP_SCRIPT" | gp -q 2>/dev/null | tee >(grep -v "^DATA" >&2) | sed -n '/DATA_START/,/DATA_END/p' | grep -v DATA_START | grep -v DATA_END >> "$outfile"
    echo "Successfully exported values to $outfile" >&2
else
    # Terminal display mode
    printf "n     (%d/n)\n" "$a"
    echo "------------"

    GP_SCRIPT="{
        my(a=$a, N=$N, j);
        gettime();
        forstep(n=1, N, 2,
            j = kronecker(a, n);
            printf(\"%d\t%d\n\", n, j)
        );
        printf(\"Calculation Time: %.3f s\n\", gettime()/1000.0);
    }"

    echo "$GP_SCRIPT" | gp -q
fi

