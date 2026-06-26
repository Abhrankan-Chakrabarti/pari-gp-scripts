#!/bin/bash
# Title:        Dirichlet L-function Zeros
# Description:  Computes non-trivial zeros of a Dirichlet L-function
#               for a given modulus and character index.
# Dependencies: pari-gp (Computer Algebra System)

# Check for Pari/GP
if ! command -v gp &> /dev/null; then
    echo "Error: Pari/GP is not installed. See README for install instructions."
    exit 1
fi

printf "This program computes zeros of a Dirichlet L-function.\n\n"

# Accept arguments or prompt
if [[ -n "$1" ]]; then
    modulus=$1
else
    printf "Enter modulus (q): "
    read modulus
fi

if [[ -n "$2" ]]; then
    chi=$2
else
    printf "Enter character index (chi): "
    read chi
fi

if [[ -n "$3" ]]; then
    n1=$3
else
    printf "Enter lower bound (n1): "
    read n1
fi

if [[ -n "$4" ]]; then
    n2=$4
else
    printf "Enter upper bound (n2): "
    read n2
fi

if [[ -n "$5" ]]; then
    p=$5
else
    printf "Enter precision: "
    read p
fi

outfile=$6

# Validate input
if ! [[ "$modulus" =~ ^[0-9]+$ && "$chi" =~ ^[0-9]+$ && "$n1" =~ ^[0-9]+$ && "$n2" =~ ^[0-9]+$ && "$p" =~ ^[0-9]+$ ]]; then
    echo "Error: All inputs must be positive integers."
    exit 1
fi

if (( n1 > n2 )); then
    echo "Error: n1 must be <= n2."
    exit 1
fi

# Run Pari/GP
GP_SCRIPT="{
    \\\p $p;
    my(L, v);
    L = lfuncreate(Mod($chi, $modulus));
    v = lfunzeros(L, [$n1, $n2]);
    if(\"$outfile\" != \"\",
        print(\"DATA_START\");
	for(i=1, #v, print(i, \"\\t\", v[i]));
        print(\"DATA_END\")
    );
    for(i=1, #v, printf(\"%3d: 0.5 +/- %s*I\n\", i, v[i]));
}"

if [[ -n "$outfile" ]]; then
    test -e "$outfile" || echo -e "index\timaginary_part" > "$outfile"
    echo "$GP_SCRIPT" | gp -q | sed -n '/DATA_START/,/DATA_END/p' | grep -v DATA_START | grep -v DATA_END >> "$outfile"
    echo "Exported result to $outfile"
else
    echo "$GP_SCRIPT" | gp -q
fi


