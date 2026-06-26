#!/bin/bash
# Title:        Euler Totient Function
# Description:  Computes Euler's totient function φ(n) for all integers up to N,
#               with running totient sum and optional TSV export.
# Dependencies: pari-gp (Computer Algebra System)

# Check for Pari/GP
if ! command -v gp &> /dev/null; then
    echo "Error: Pari/GP is not installed. See README for install instructions."
    exit 1
fi

printf "This program computes Euler's totient function φ(n) for integers up to N.\n\n"

# Accept arguments or prompt
if [[ -n "$1" ]]; then
    N=$1
else
    printf "Enter N: "
    read N
fi

outfile=$2

# Validate input
if ! [[ "$N" =~ ^[0-9]+$ ]] || (( N < 1 )); then
    echo "Error: N must be a positive integer."
    exit 1
fi

# Run Pari/GP
if [[ -n "$outfile" ]]; then
    # TSV export mode — tagged stream pipeline
    GP_SCRIPT="{
        my(n=$N, phi, S=0);
        gettime();
        print(\"DATA_START\");
        for(k=1, n,
            phi = eulerphi(k);
            S += phi;
            print(k, \"\t\", phi)
        );
        print(\"DATA_END\");
        printf(\"Totient sum Φ(%d) = %d\n\", n, S);
        printf(\"Calculation Time: %.3f s\n\", gettime()/1000.0);
    }"

    test -e "$outfile" || echo -e "n\tphi(n)" > "$outfile"
    echo "$GP_SCRIPT" | gp -q 2>/dev/null | tee >(grep -v "^DATA" >&2) | sed -n '/DATA_START/,/DATA_END/p' | grep -v DATA_START | grep -v DATA_END >> "$outfile"
    echo "Successfully exported $N values to $outfile" >&2
else
    # Terminal display mode
    printf "n     φ(n)\n"
    echo "------------"

    GP_SCRIPT="{
        my(n=$N, phi, S=0);
        gettime();
        for(k=1, n,
            phi = eulerphi(k);
            S += phi;
            printf(\"%d\t%d\n\", k, phi)
        );
        printf(\"Totient sum Φ(%d) = %d\n\", n, S);
        printf(\"Calculation Time: %.3f s\n\", gettime()/1000.0);
    }"

    echo "$GP_SCRIPT" | gp -q
fi

