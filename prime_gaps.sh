#!/bin/bash
# Title:        Prime Gap Explorer (Cross-Platform)
# Description:  Computes max prime gaps using continuous streaming.
# Dependencies: pari-gp (Linux) or gp.exe (Windows)

# 1. CROSS-PLATFORM DETECTOR: Find gp or gp.exe anywhere in the system PATH
if command -v gp &> /dev/null; then
    GP_CMD="gp"
elif command -v gp.exe &> /dev/null; then
    GP_CMD="gp.exe"
else
    echo "Error: Pari/GP (gp or gp.exe) is not installed or not in your PATH."
    exit 1
fi

printf "This program computes prime gaps for the first n primes.\n\n"

if [[ -n "$1" ]]; then
    n=$1
else
    printf "Enter the number of primes (n): "
    read n
fi

if ! [[ "$n" =~ ^[0-9]+$ ]] || (( n < 2 )); then
    echo "Error: Input must be an integer >= 2."
    exit 1
fi

INTERVAL=$(( n / 100 ))
(( INTERVAL < 1000 )) && INTERVAL=1000
(( INTERVAL > n ))    && INTERVAL=n

GP_SCRIPT="{
    my(n = $n, interval = $INTERVAL);
    my(p_prev = 2, p_curr, gap, max_gap = 0);
    gettime();

    for(i = 2, n,
        p_curr = nextprime(p_prev + 1);
        gap = p_curr - p_prev;
        if(gap > max_gap, max_gap = gap);
        p_prev = p_curr;

        if(i % interval == 0 || i == n,
            printf(\"PROGRESS:%d:%d\n\", i, n);
        );
    );

    printf(\"DONE:%d:%d:%d:%.3f\n\", n, p_prev, max_gap, gettime()/1000.0);
}"

draw_bar() {
    local pct=$1 cur=$2 total=$3
    local filled=$(( pct * 40 / 100 ))
    local empty=$(( 40 - filled ))
    local bar space
    bar=$(printf '%0.s#' $(seq 1 $filled) 2>/dev/null)
    space=$( (( empty > 0 )) && printf '%0.s-' $(seq 1 $empty) 2>/dev/null || true)
    printf "\r  [%s%s] %d%% (%d / %d)" "$bar" "$space" "$pct" "$cur" "$total"
}

# 2. CROSS-PLATFORM PIPELINE: Strip \r per-line inside the loop to preserve streaming
echo "$GP_SCRIPT" | "$GP_CMD" -q | while IFS=: read -r tag a b c d; do
    tag="${tag//$'\r'/}"
    a="${a//$'\r'/}"
    b="${b//$'\r'/}"
    c="${c//$'\r'/}"
    d="${d//$'\r'/}"
    case "$tag" in
        PROGRESS)
            pct=$(( a * 100 / b ))
            draw_bar "$pct" "$a" "$b"
            ;;
        DONE)
            draw_bar 100 "$a" "$a"
            printf "\n\n"
            printf "Total Primes Processed: %s\n" "$a"
            printf "Last Prime Reached:     %s\n" "$b"
            printf "Max gap found:          %s\n" "$c"
            printf "Time elapsed:           %s s\n" "$d"
            ;;
    esac
done


