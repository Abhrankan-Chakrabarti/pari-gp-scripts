# PARI/GP Scripts

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![Shell: Bash](https://img.shields.io/badge/Shell-Bash-4EAA25.svg)
![PARI/GP](https://img.shields.io/badge/PARI%2FGP-required-blue.svg)

A collection of lightweight Bash wrappers for **PARI/GP** exploring classical problems in number theory.

---

## 🌱 Project Inspiration

This project directly inspired the creation of [Remote Exec Server & Client](https://github.com/foxhackerzdevs/remote-exec-server).

While building these Bash wrappers for **PARI/GP**, I explored:
- **Symlink wrappers** — one script acting as multiple commands, BusyBox‑style.  
- **Lightweight execution** — keeping dependencies minimal and relying on the standard library.  
- **Command forwarding** — piping input into `gp` for quick number theory computations.  

These experiments sparked the idea of generalizing the mechanism: instead of wrapping `gp` locally, design a framework where a single client script can forward commands to a server over HTTP.  

Thus, **Remote Exec Server & Client** was born — a minimal, dependency‑free system for remote command execution, inspired by the simplicity and flexibility of these PARI/GP scripting workflows.

---

## Table of Contents
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Scripts](#scripts)
  - [riemann_zeros.sh](#riemann_zerossh)
  - [gilbreath.sh](#gilbreathsh)
  - [prime_gaps.sh](#prime_gapssh)
  - [mobius.sh](#mobiussh)
- [Contributing](#contributing)
- [License](#license)

---

## Prerequisites

All scripts require **PARI/GP** (a computer algebra system specialized in number theory).

---

## Installation

* **Ubuntu / Debian:**
  ```bash
  sudo apt-get update
  sudo apt-get install pari-gp
  ```
* **macOS (via Homebrew):**
  ```bash
  brew install pari
  ```
* **Fedora / RHEL:**
  ```bash
  sudo dnf install pari-gp
  ```
* **Android (Termux):**
  ```bash
  pkg install pari
  ```
* **Windows:** Download the installer from [pari.math.u-bordeaux.fr](https://pari.math.u-bordeaux.fr/download.html)

---

## Quick Start

```bash
git clone https://github.com/Abhrankan-Chakrabarti/pari-gp-scripts.git
cd pari-gp-scripts
chmod +x riemann_zeros.sh gilbreath.sh prime_gaps.sh mobius.sh
./riemann_zeros.sh 10 30 38
./gilbreath.sh 10000 1
```

---

## Scripts

### riemann_zeros.sh

Computes the non-trivial zeros of the Riemann zeta function ζ(s) within a user-defined height range [n1, n2] on the critical line (Re(s) = 1/2).

Because non-trivial zeros always appear in complex conjugate pairs due to the symmetry of the zeta function (ζ(s̄) = ζ(s)‾), the output formats them using `0.5 +/- t*I` notation.

**Usage:**
```bash
./riemann_zeros.sh [n1] [n2] [precision]
```

**Example:**
```text
$ ./riemann_zeros.sh 10 30 38

1: 0.5 +/- 14.134725141734693790457251983562470271*I
2: 0.5 +/- 21.022039638771554992628479593896902777*I
3: 0.5 +/- 25.010857580145688763213790992562821819*I
```

**How it works:**
1. Validates that `n1`, `n2`, and `precision` are positive integers and that `n1 <= n2`
2. Passes the parameters to a `gp -q` session
3. Uses `lfuncreate(1)` and `lfunzeros()` to compute the imaginary parts of the zeros, then maps each `t` to `0.5 +/- t*I`

---

### gilbreath.sh

Generates a Gilbreath Triangle for the first `n` primes and verifies **Gilbreath's conjecture** at each row.

Starting from the sequence of the first `n` primes, each subsequent row is formed by taking the absolute differences of consecutive elements. Gilbreath's conjecture states that the first element of every row (after row 0) is always 1. It has been verified for millions of primes but remains unproven.

**Usage:**
```bash
./gilbreath.sh [n] [quiet]
```

`quiet` is optional: `0` (default) prints every row, `1` suppresses row output and only prints the result and timing.

**Example:**
```text
$ ./gilbreath.sh 6

Row 0: [2, 3, 5, 7, 11, 13]
Row 1: [1, 2, 2, 4, 2]
Row 2: [1, 0, 2, 2]
Row 3: [1, 2, 0]
Row 4: [1, 2]
Row 5: [1]
Gilbreath holds for first 6 primes
Time: 0.001 s
```

**Quiet mode** (useful for large `n`):
```text
$ ./gilbreath.sh 5000 1

Gilbreath holds for first 5000 primes
Time: 7.988 s
```

**How it works:**
1. Validates that `n` is a positive integer
2. Passes the parameters to `gp -q` via `echo | gp -q`
3. Uses `primes(n)` to generate the initial row, then iterates absolute differences via `vector(#row-1, i, abs(row[i]-row[i+1]))`
4. Reports computation time via PARI/GP's `gettime()`, formatted to 3 decimal places

---

### prime_gaps.sh

Computes the maximum gap between consecutive primes for the first `n` primes. Uses a streaming loop rather than allocating a vector, so memory usage is O(1) and it scales to very large `n`.

**Usage:**
```bash
./prime_gaps.sh [n]
```

**Example:**
```text
$ ./prime_gaps.sh 1000

Total Primes Processed: 1000
Last Prime Reached:     7919
Max gap found:          34
Time elapsed:           0.012 s
```

**How it works:**
1. Validates that `n` is an integer ≥ 2
2. Iterates through primes using `nextprime(p_prev + 1)` — avoids index lookup overhead of `prime(i)` by advancing directly to the next prime from the current position
3. Reports total primes processed, last prime reached, maximum gap found, and elapsed time

---

### mobius.sh

Computes the Möbius function μ(n) for all integers up to N.

μ(n) is defined as: 1 if n = 1; (−1)^k if n is a product of k distinct primes; 0 if n has a squared prime factor.

**Usage:**
```bash
./mobius.sh [N] [output.tsv]
```

The optional second argument exports values into a tab-separated data file. Execution statistics (Mertens sum, square-free density, runtime tracking) are systematically separated at the stream layer—flashing directly to the screen terminal while keeping data exports 100% clean.

**Example:**
```text
$ ./mobius.sh 10

n     μ(n)
------------
1     1
2     -1
3     -1
4     0
5     -1
6     1
7     -1
8     0
9     0
10    1
Mertens M(10) = -1
Square-free numbers:   7 / 10 (70.00%)
Theoretical limit:     ~60.79%
Calculation Time:      0.000 s
```

**TSV export:**
```text
\$ ./mobius.sh 105151 output.tsv

Successfully exported 105151 values to output.tsv
Mertens M(105151) = -24
Square-free numbers:   63928 / 105151 (60.80%)
Theoretical limit:     ~60.79%
Calculation Time:      1.152 s
```

**How it works:**
1. Validates that `N` is a positive integer.
2. Executes an optimized $O(N)$ two-vector sieve strategy inside PARI/GP (`mu[]` maps sign permutations, `sq[]` maps squared elements). The tracking profiles are merged in a single final pass that evaluates the **Mertens function** $M(N) = \sum \mu(k)$ and total **square-free elements** with zero added algorithmic complexity.
3. Decouples output layers via a stream isolation pipeline: target arrays are wrapped within runtime token tags (`DATA_START` / `DATA_END`). Shell utilities (`sed` and `grep`) intercept the stream to capture raw integer pairs into the TSV file, while structural diagnostic strings route cleanly to standard error (`stderr`).

---

## Contributing

Pull requests are welcome. Ideas for new scripts include:

- Goldbach partition checker
- Dirichlet L-function zeros
- Euler product approximations of π

Each script should follow the conventions of the existing ones:

- Bash wrapper with `gp` availability check
- Argument mode with interactive prompt fallback
- Input validation before passing to GP
- Consistent header comment block (Title, Description, Dependencies)

See [CONTRIBUTING.md](./CONTRIBUTING.md) for detailed guidelines on script conventions, GP scoping, timing, and the contribution flow.

---

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

## 🔗 See also

- [Remote Exec Server & Client](https://github.com/foxhackerzdevs/remote-exec-server) —  
  A lightweight Python-based remote command execution framework inspired by the scripting patterns developed here.


