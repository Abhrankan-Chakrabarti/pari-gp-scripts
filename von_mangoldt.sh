#!/bin/bash
# Title:        Von Mangoldt Function
# Description:  Computes the von Mangoldt function Λ(n) for all integers up to N,
#               with running Chebyshev psi function ψ(N) and optional TSV export.
# Dependencies: pari-gp (Computer Algebra System)

# Check for Pari/GP
if ! command -v gp &> /dev/null; then
    echo "Error: Pari/GP is not installed. See README for install instructions."
    exit 1
fi

printf "This program computes the von Mangoldt function Λ(n) for integers up to N.\n\n"

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
        my(n=$N, f, p, lam, psi=0.0);
        gettime();
        print(\"DATA_START\");
        for(k=1, n,
            f = factor(k);
            if(#f[,1] == 1 && f[1,2] >= 1,
                p = f[1,1];
                lam = log(p);
                psi += lam;
                print(k, \"\t\", p, \"\t\", f[1,2], \"\t\", lam)
            ,
                print(k, \"\t0\t0\t0\")
            )
        );
        print(\"DATA_END\");
        printf(\"Chebyshev psi(%.0f) = %.6f\n\", n*1.0, psi);
        printf(\"Calculation Time: %.3f s\n\", gettime()/1000.0);
    }"

    test -e "$outfile" || echo -e "n\tp\tk\tLambda(n)" > "$outfile"
    echo "$GP_SCRIPT" | gp -q 2>/dev/null | tee >(grep -v "^DATA" >&2) | sed -n '/DATA_START/,/DATA_END/p' | grep -v DATA_START | grep -v DATA_END >> "$outfile"
    echo "Successfully exported $N values to $outfile" >&2
else
    # Terminal display mode
    printf "n     Λ(n)          note\n"
    echo "--------------------------------"

    GP_SCRIPT="{
        my(n=$N, f, p, lam, psi=0.0);
        gettime();
        for(k=1, n,
            f = factor(k);
            if(#f[,1] == 1 && f[1,2] >= 1,
                p = f[1,1];
                lam = log(p);
                psi += lam;
                printf(\"%-6d%-14.6f p=%d^%d\n\", k, lam, p, f[1,2])
            ,
                printf(\"%-6d0\n\", k)
            )
        );
        printf(\"Chebyshev psi(%d) = %.6f\n\", n, psi);
        printf(\"Calculation Time: %.3f s\n\", gettime()/1000.0);
    }"

    echo "$GP_SCRIPT" | gp -q
fi

