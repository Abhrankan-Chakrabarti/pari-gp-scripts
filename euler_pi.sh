#!/bin/bash
# Title:        Euler Product Approximation of π
# Description:  Approximates π using Euler's product formula truncated at the first n primes.
# Dependencies: pari-gp (Computer Algebra System)

# Check for Pari/GP
if ! command -v gp &> /dev/null; then
    echo "Error: Pari/GP is not installed. See README for install instructions."
    exit 1
fi

printf "This program approximates π using Euler's product formula with the first n primes.\n\n"

# Accept arguments
n=$1
outfile=$2

if [[ -z "$n" ]]; then
    printf "Enter the number of primes (n): "
    read n
fi

# Validate input
if ! [[ "$n" =~ ^[0-9]+$ ]] || (( n < 1 )); then
    echo "Error: Input must be a positive integer."
    exit 1
fi

# Run Pari/GP
GP_SCRIPT="{
    my(n=$n);
    my(primes = vector(n, i, prime(i)));
    my(product = 1.0);

    gettime();
    for(i=1, n,
        product *= 1.0 / (1.0 - 1.0/(primes[i]^2))
    );

    my(approx_pi = sqrt(6.0 * product));
    my(err = abs(approx_pi - Pi));

    if(\"$outfile\" != \"\",
        print(\"DATA_START\");
        print(n, \"\\t\", approx_pi, \"\\t\", err);
        print(\"DATA_END\")
    );

    print(\"Using first \", n, \" primes:\");
    print(\"Approximation of π = \", approx_pi);
    print(\"Actual π = \", Pi);
    printf(\"Error = %.10g\\n\", err);
    printf(\"Time: %.3f s\\n\", gettime()/1000.0);
}"

if [[ -n "$outfile" ]]; then
    test -e "$outfile" || echo -e "n\tapprox_pi\terror" > "$outfile"
    echo "$GP_SCRIPT" | gp -q | sed -n '/DATA_START/,/DATA_END/p' | grep -v DATA_START | grep -v DATA_END >> "$outfile"
    echo "Exported result to $outfile"
else
    echo "$GP_SCRIPT" | gp -q
fi

