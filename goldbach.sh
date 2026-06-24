#!/bin/bash
# Goldbach Partition Checker with normalized gap frequency TSV export, sorting modes, and top-N filter

if ! command -v gp &> /dev/null; then
    echo "Error: Pari/GP is not installed."
    exit 1
fi

printf "This program checks Goldbach's conjecture for even numbers up to N.\n\n"

N=$1
quiet=${2:-0}
outfile=$3
freqfile=$4          # optional TSV export filename for gap frequencies
sortmode=${5:-gap}   # "gap" (default) or "count"
topN=${6:-0}         # optional limit for top-N rows (only applies in count mode)

if [[ -z "$N" ]]; then
    printf "Enter N (upper bound): "
    read N
fi

if ! [[ "$N" =~ ^[0-9]+$ ]] || (( N < 4 )); then
    echo "Error: Input must be an integer >= 4."
    exit 1
fi

GP_SCRIPT="{
    my(N=$N, quiet=$quiet, outfile=\"$outfile\", freqfile=\"$freqfile\", sortmode=\"$sortmode\", topN=$topN);
    my(failed=0, t=gettime(), total_pairs=0, total_gap=0, max_gap=0, min_gap=-1);
    my(gap_freq=Map());

    if(outfile!=\"\", write(outfile,\"n\\tp1\\tp2\\tgap\"));

    for(n=4, N,
        if(n%2==0,
            my(found=0);
            forprime(p=2, n-2,
                if(isprime(n-p),
                    my(gap=(n-p)-p);
                    if(!quiet, print(n,\" = \",p,\" + \",n-p,\" (gap \",gap,\")\"));
                    if(outfile!=\"\", write(outfile,n,\"\\t\",p,\"\\t\",n-p,\"\\t\",gap));
                    total_pairs++; total_gap+=gap;
                    if(gap>max_gap, max_gap=gap);
                    if(min_gap==-1 || gap<min_gap, min_gap=gap);
                    if(mapisdefined(gap_freq,gap),
                        mapput(gap_freq,gap,mapget(gap_freq,gap)+1),
                        mapput(gap_freq,gap,1)
                    );
                    found=1; break;
                );
            );
            if(!found, print(\"Goldbach failed at \",n); failed=1; break);
            if(n%1000==0, print(\"Progress: checked up to \",n));
        );
    );

    if(!failed, print(\"Goldbach holds for even numbers up to \",N));

    if(total_pairs>0,
        print(\"Total pairs found: \",total_pairs);
        print(\"Average prime gap: \",total_gap/total_pairs,\" ≈ \",Strprintf(\"%.6f\",(total_gap*1.0)/total_pairs));
        print(\"Maximum prime gap observed: \",max_gap);
        print(\"Minimum prime gap observed: \",min_gap);
        print(\"Gap frequency distribution:\");

        /* Convert map to matrix: column 1 = gap, column 2 = count */
        my(M = Mat(gap_freq));

        if(sortmode==\"gap\",
            M = mattranspose(vecsort(mattranspose(M))),       /* sort by gap ascending */
            M = mattranspose(vecsort(mattranspose(M),2,4));   /* sort by count descending */
        );

        if(topN>0 && sortmode==\"count\",
            limit = min(topN,#M~),
            limit = #M~
        );

        for(i=1, limit,
            my(g=M[i,1], count=M[i,2]);
            my(percent = (count*100.0)/total_pairs);
            print(\"gap \",g,\": \",count,\" occurrence(s) (\",Strprintf(\"%.2f\",percent),\"%)\");
            if(freqfile!=\"\", write(freqfile,g,\"\\t\",count,\"\\t\",Strprintf(\"%.6f\",percent)));
        );
    );

    printf(\"Time: %.3f s\\n\",gettime()/1000.0);
}"

echo "$GP_SCRIPT" | gp -q

