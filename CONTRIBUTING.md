# Contributing to PARI/GP Scripts

Contributions are welcome. This guide explains how to add new scripts in a style consistent with the existing ones.

---

## How to Contribute

1. **Fork the repository** and clone your fork:
   ```bash
   git clone https://github.com/your-username/pari-gp-scripts.git
   cd pari-gp-scripts
   ```

2. **Create a new branch:**
   ```bash
   git checkout -b feature/new-script
   ```

3. **Add your script** to the root directory (e.g. `prime_gaps.sh`) following the conventions below.

4. **Test your script** on at least one platform. Confirm inputs are validated and outputs are clear.

5. **Commit and push:**
   ```bash
   git add prime_gaps.sh
   git commit -m "Add prime gaps explorer script"
   git push origin feature/new-script
   ```

6. **Open a Pull Request** describing the purpose of your script, with usage examples and sample output.

---

## Script Conventions

### Header block
Every script should begin with a comment block:
```bash
#!/bin/bash
# Title:        Script Name
# Description:  What it does.
# Dependencies: pari-gp (Computer Algebra System)
```

### Check for `gp` availability
```bash
if ! command -v gp &> /dev/null; then
    echo "Error: Pari/GP is not installed. See README for install instructions."
    exit 1
fi
```

### Argument mode with interactive fallback
Use explicit `if/else` — avoid subshell-based prompt patterns which break in some environments (e.g. Termux):
```bash
if [[ -n "$1" ]]; then
    n=$1
else
    printf "Enter n: "; read n
fi
```

### Input validation
Validate all inputs before passing to GP:
```bash
if ! [[ "$n" =~ ^[0-9]+$ ]] || (( n < 1 )); then
    echo "Error: Input must be a positive integer."
    exit 1
fi
```

### Passing variables to GP
Use `echo "$GP_SCRIPT" | gp -q` with a bash variable for the GP code. Heredoc variable expansion can be unreliable across environments:
```bash
GP_SCRIPT="my(n = $n); ..."
echo "$GP_SCRIPT" | gp -q
```

### GP block scoping
Wrap all GP statements in a single `{ }` block to preserve `my()` variable scoping. Without this, each `my()` declaration goes out of scope immediately when piped line by line:
```bash
GP_SCRIPT="{my(n=$n, row=primes(n)); ... }"
echo "$GP_SCRIPT" | gp -q
```
Avoid `$(cat <<EOF ... EOF)` — command substitution suppresses variable expansion just like a subshell.

### Unicode in output
Print Unicode headers from bash rather than passing them through GP strings, which can mangle multibyte characters:
```bash
printf "n     μ(n)\n"   # bash handles UTF-8 correctly
GP_SCRIPT="{...}"        # GP handles numbers only
echo "$GP_SCRIPT" | gp -q
```

### Timing
For computationally intensive scripts, report timing via `gettime()`. Call it once before the main computation to start the clock:
```gp
gettime();
\\ ... computation ...
printf("Time: %.3f s\n", gettime()/1000.0);
```

### Output formatting
Use aligned, labelled output. See `riemann_zeros.sh` and `gilbreath.sh` for reference.

---

## Ideas for New Scripts

- Goldbach partition checker
- Dirichlet L-function zeros
- Euler product approximations of π

---

## Code Style

- Bash 4+ syntax
- `printf` over `echo` for formatted output
- Keep scripts self-contained and lightweight
- Document usage and examples in the README

---

## Community Guidelines

- Be respectful and constructive
- Keep contributions focused on number theory and PARI/GP
- Ensure scripts are original work

