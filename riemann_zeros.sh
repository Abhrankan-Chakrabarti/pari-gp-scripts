#!/bin/bash
# Riemann Zeta Zero Generator

if ! command -v gp &> /dev/null; then
    echo "Error: Pari/GP not installed."
    exit 1
fi

# Accept arguments or prompt
n1=${1:-$(read -p "Enter n1 : " val; echo $val)}
n2=${2:-$(read -p "Enter n2 : " val; echo $val)}
p=${3:-$(read -p "Enter precision : " val; echo $val)}

# Validate
if ! [[ "$n1" =~ ^[0-9]+$ && "$n2" =~ ^[0-9]+$ && "$p" =~ ^[0-9]+$ ]]; then
    echo "Error: Inputs must be positive integers."
    exit 1
fi
if (( n1 > n2 )); then
    echo "Error: n1 must be <= n2."
    exit 1
fi

# Run Pari/GP
gp -q <<EOF
\p $p
L = lfuncreate(1);
v = lfunzeros(L, [$n1, $n2]);
for(i=1, #v, printf("%3d: 0.5 +/- %s*I\n", i, v[i]))
EOF
