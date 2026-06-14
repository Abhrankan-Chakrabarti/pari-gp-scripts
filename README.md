# PARI/GP Scripts

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![Shell: Bash](https://img.shields.io/badge/Shell-Bash-4EAA25.svg)
![PARI/GP](https://img.shields.io/badge/PARI%2FGP-required-blue.svg)

A collection of lightweight Bash wrappers for **PARI/GP** exploring classical problems in number theory.

---

## Table of Contents
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Scripts](#scripts)
  - [riemann_zeros.sh](#riemann_zerossh)
  - [gilbreath.sh](#gilbreathsh)
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
  pkg install pari-gp
  ```
* **Windows:** Download the installer from [pari.math.u-bordeaux.fr](https://pari.math.u-bordeaux.fr/download.html)

---

## Quick Start

```bash
git clone https://github.com/Abhrankan-Chakrabarti/pari-gp-scripts.git
cd pari-gp-scripts
chmod +x riemann_zeros.sh gilbreath.sh
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

## Contributing

Pull requests are welcome. Ideas for new scripts include:

- Prime gap explorer
- Möbius function table
- Goldbach partition checker
- Dirichlet L-function zeros
- Euler product approximations of π

Each script should follow the conventions of the existing ones:

- Bash wrapper with `gp` availability check
- Argument mode with interactive prompt fallback
- Input validation before passing to GP
- Consistent header comment block (Title, Description, Dependencies)

---

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

