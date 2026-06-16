#!/bin/bash
# Title:        Möbius Function Table (High-Speed Production Sieve)
# Description:  Computes μ(n), Mertens sum, and square-free density with pure TSV export.
# Dependencies: pari-gp

if ! command -v gp &> /dev/null; then
    echo "Error: Pari/GP is not installed. See README for install instructions." >&2
    exit 1
fi

printf "This program computes the Möbius function μ(n) for integers up to N.\n\n" >&2

N=$1
EXPORT_FILE=$2

if [[ -z "$N" ]]; then
    printf "Enter N (upper bound): " >&2
    read N
fi

if ! [[ "$N" =~ ^[0-9]+$ ]] || (( N < 1 )); then
    echo "Error: Input must be a positive integer." >&2
    exit 1
fi

EXPORT_FLAG=$([[ -n "$EXPORT_FILE" ]] && echo 1 || echo 0)

# Clean, standard GP script that only utilizes basic, undeniable print features
GP_SCRIPT="{
    my(N = $N);
    gettime();

    my(mu = vector(N, i, 1));
    my(sq = vector(N, i, 1));

    forprime(p = 2, N,
        my(p2 = p * p);
        if(p2 <= N, forstep(j = p2, N, p2, sq[j] = 0));
        forstep(i = p, N, p, mu[i] = -mu[i]);
    );

    my(mertens = 1);
    my(sq_free_count = 1);

    for(i = 2, N,
        if(sq[i] == 0, mu[i] = 0);
        mertens += mu[i];
        if(mu[i] != 0, sq_free_count++);
    );

    my(calc_time = gettime() / 1000.0);
    my(sq_free_pct = (sq_free_count * 100.0) / N);

    \\\\ Standard output formatting using reliable print statements
    if(N <= 1000 || $EXPORT_FLAG,
        printf(\"DATA_START\\n\");
        printf(\"n\\tmu(n)\\n\");
        for(n = 1, N, printf(\"%d\\t%d\\n\", n, mu[n]));
        printf(\"DATA_END\\n\");
    ,
        printf(\"METRIC_LOG: Skipping full table print for large N (%d values).\\n\", N);
    );

    printf(\"METRIC_LOG: Mertens M(%d) = %d\\n\", N, mertens);
    printf(\"METRIC_LOG: Square-free numbers:   %d / %d (%.2f%%)\\n\", sq_free_count, N, sq_free_pct);
    printf(\"METRIC_LOG: Theoretical limit:     ~60.79%%\\n\");
    printf(\"METRIC_LOG: Calculation Time:      %.3f s\\n\", calc_time);
}"

if [[ -n "$EXPORT_FILE" ]]; then
    # Execute and capture the whole unified stream
    RAW_STREAM=$(echo "$GP_SCRIPT" | gp -q)
    
    # 1. Filter out raw rows and save directly to file (pure data layer)
    echo "$RAW_STREAM" | sed -n '/DATA_START/,/DATA_END/p' | grep -vE 'DATA_START|DATA_END' > "$EXPORT_FILE"
    printf "Successfully exported %s values to %s\n" "$N" "$EXPORT_FILE" >&2
    
    # 2. Filter out metrics and display on the terminal (pure stderr layer)
    echo "$RAW_STREAM" | grep '^METRIC_LOG:' | sed 's/^METRIC_LOG: //' >&2
else
    RAW_STREAM=$(echo "$GP_SCRIPT" | gp -q)
    
    # Display plain table data to screen if N is small
    if (( N <= 1000 )); then
        echo "$RAW_STREAM" | sed -n '/DATA_START/,/DATA_END/p' | grep -vE 'DATA_START|DATA_END'
    fi
    
    # Send metrics directly to standard error
    echo "$RAW_STREAM" | grep '^METRIC_LOG:' | sed 's/^METRIC_LOG: //' >&2
fi


