#!/bin/bash
# Title:        Carmichael Function
# Description:  Computes the Carmichael function λ(n) for all integers up to N,
#               with comparison to Euler's totient φ(n) and optional TSV export.
# Dependencies: pari-gp (Computer Algebra System)

# Check for Pari/GP
if ! command -v gp &> /dev/null; then
    echo "Error: Pari/GP is not installed. See README for install instructions."
    exit 1
fi

printf "This program computes the Carmichael function λ(n) for integers up to N.\n\n"

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
        my(n=$N, lam, phi);
        gettime();
        print(\"DATA_START\");
        for(k=1, n,
            lam = lcm(znstar(k)[2]);
            phi = eulerphi(k);
            print(k, \"\t\", lam, \"\t\", phi)
        );
        print(\"DATA_END\");
        printf(\"Calculation Time: %.3f s\n\", gettime()/1000.0);
    }"

    test -e "$outfile" || echo -e "n\tlambda(n)\tphi(n)" > "$outfile"
    echo "$GP_SCRIPT" | gp -q 2>/dev/null | tee >(grep -v "^DATA" >&2) | sed -n '/DATA_START/,/DATA_END/p' | grep -v DATA_START | grep -v DATA_END >> "$outfile"
    echo "Successfully exported $N values to $outfile" >&2
else
    # Terminal display mode
    printf "n     λ(n)   φ(n)   λ=φ?\n"
    echo "----------------------------"

    GP_SCRIPT="{
        my(n=$N, lam, phi);
        gettime();
        for(k=1, n,
            lam = lcm(znstar(k)[2]);
            phi = eulerphi(k);
            printf(\"%d\t%d\t%d\t%s\n\", k, lam, phi, if(lam==phi, \"yes\", \"no\"))
        );
        printf(\"Calculation Time: %.3f s\n\", gettime()/1000.0);
    }"

    echo "$GP_SCRIPT" | gp -q
fi

