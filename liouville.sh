#!/bin/bash
# Title:        Liouville Function
# Description:  Computes the Liouville function λ(n) for all integers up to N,
#               with running Liouville sum L(N) and optional TSV export.
# Dependencies: pari-gp (Computer Algebra System)

# Check for Pari/GP
if ! command -v gp &> /dev/null; then
    echo "Error: Pari/GP is not installed. See README for install instructions."
    exit 1
fi

printf "This program computes the Liouville function λ(n) = (-1)^Ω(n) for integers up to N.\n\n"

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
        my(n=$N, lam, L=0, sq=0);
        gettime();
        print(\"DATA_START\");
        for(k=1, n,
            lam = (-1)^bigomega(k);
            L += lam;
            if(lam != 0, sq++);
            print(k, \"\t\", lam, \"\t\", L)
        );
        print(\"DATA_END\");
        printf(\"Liouville sum L(%d) = %d\n\", n, L);
        printf(\"Calculation Time: %.3f s\n\", gettime()/1000.0);
    }"

    test -e "$outfile" || echo -e "n\tlambda(n)\tL(n)" > "$outfile"
    echo "$GP_SCRIPT" | gp -q 2>/dev/null | tee >(grep -v "^DATA" >&2) | sed -n '/DATA_START/,/DATA_END/p' | grep -v DATA_START | grep -v DATA_END >> "$outfile"
    echo "Successfully exported $N values to $outfile" >&2
else
    # Terminal display mode
    printf "n     λ(n)\n"
    echo "------------"

    GP_SCRIPT="{
        my(n=$N, lam, L=0);
        gettime();
        for(k=1, n,
            lam = (-1)^bigomega(k);
            L += lam;
            printf(\"%d\t%d\n\", k, lam)
        );
        printf(\"Liouville sum L(%d) = %d\n\", n, L);
        printf(\"Calculation Time: %.3f s\n\", gettime()/1000.0);
    }"

    echo "$GP_SCRIPT" | gp -q
fi

