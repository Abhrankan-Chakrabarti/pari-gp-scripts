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
  - [mobius.sh](#mobiush)
  - [goldbach.sh](#goldbachsh)
  - [euler_pi.sh](#euler_pish)
    - [Plotting Convergence](#-plotting-convergence)
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
chmod +x riemann_zeros.sh gilbreath.sh prime_gaps.sh mobius.sh goldbach.sh euler_pi.sh
./riemann_zeros.sh 10 30 38
./gilbreath.sh 10000 1
./prime_gaps.sh 1000
./mobius.sh 50
./goldbach.sh 30 0 pairs.tsv freq.tsv count 5
./euler_pi.sh 10
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

### goldbach.sh

Verifies **Goldbach’s conjecture** for even numbers up to `N`. For each even number, it finds a prime pair `p1 + p2 = n` and reports the prime gap `(p2 - p1)`. Supports normalized gap frequency distribution with TSV export, sorting modes, and a top‑N filter.

**Usage:**
```bash
./goldbach.sh [N] [quiet] [pairs.tsv] [freq.tsv] [sortmode] [topN]
```

- `N` — upper bound (must be ≥ 4)
- `quiet` — optional: `0` (default, verbose) or `1` (suppress pair output)
- `pairs.tsv` — optional export file for prime pairs
- `freq.tsv` — optional export file for gap frequencies
- `sortmode` — optional: `gap` (ascending) or `count` (descending)
- `topN` — optional: limit output to top N gaps (only in `count` mode)

**Example:**
```text
$ ./goldbach.sh 30 0 pairs.tsv freq.tsv count 5

4 = 2 + 2 (gap 0)
6 = 3 + 3 (gap 0)
...
30 = 7 + 23 (gap 16)
Goldbach holds for even numbers up to 30
Total pairs found: 14
Average prime gap: 9.428571
Maximum prime gap observed: 20
Minimum prime gap observed: 0
Gap frequency distribution:
gap 16: 2 occurrence(s) (14.29%)
gap 14: 2 occurrence(s) (14.29%)
gap 8: 2 occurrence(s) (14.29%)
gap 2: 2 occurrence(s) (14.29%)
gap 0: 2 occurrence(s) (14.29%)
Time: 0.003 s
```

**How it works:**
1. Validates that `N` is an integer ≥ 4.
2. Iterates through even numbers up to `N`, checking for prime pairs `p1 + p2 = n`.
3. Reports each pair and its prime gap `(p2 - p1)` unless `quiet` mode is enabled.
4. Tracks statistics: total pairs, average gap, maximum and minimum gap.
5. Builds a frequency map of gaps, then exports it to TSV if `freq.tsv` is provided.
6. Supports sorting by gap ascending or count descending, with an optional top‑N filter to keep output concise.
7. Reports elapsed time using PARI/GP’s `gettime()`.

---

### euler_pi.sh

Approximates **π** using Euler’s product formula truncated at the first `n` primes. Euler showed that  
\[
\zeta(2) = \frac{\pi^2}{6} = \prod_{p \ \text{prime}} \frac{1}{1 - \frac{1}{p^2}}
\]  
so truncating the product at the first `n` primes gives a numerical approximation of π.

**Usage:**
```bash
./euler_pi.sh [n] [results.tsv]
```

- `n` — number of primes to include (must be ≥ 1)
- `results.tsv` — optional export file for approximation results

**Example (small n):**
```text
$ ./euler_pi.sh 10

This program approximates π using Euler's product formula with the first n primes.

Using first 10 primes:
Approximation of π = 3.1302432721714194784030970125274437412
Actual π = 3.1415926535897932384626433832795028842
Error = 0.01134938142
Time: 0.063 s
```

**Example (larger n):**
```text
$ ./euler_pi.sh 1000

This program approximates π using Euler's product formula with the first n primes.

Using first 1000 primes:
Approximation of π = 3.1415727030005293069469452637246253626
Actual π = 3.1415926535897932384626433832795028842
Error = 1.995058926 e-5
Time: 0.063 s
```

**How it works:**
1. Validates that `n` is a positive integer.  
2. Generates the first `n` primes using `vector(n, i, prime(i))`.  
3. Computes the truncated Euler product \(\prod_{i=1}^n \frac{1}{1 - 1/p_i^2}\).  
4. Approximates π as \(\sqrt{6 \cdot \text{product}}\).  
5. Prints the approximation, actual π, absolute error, and runtime via `gettime()`.  

**Note on convergence:**  
Euler’s product converges very slowly. With small `n` (like 10), the approximation can be off by a few hundredths. Accuracy improves gradually as more primes are included — by `n = 1000`, the error drops below \(2 \times 10^{-5}\). Thousands of primes are needed for high‑precision results.

**Plot suggestion:**  
To visualize convergence, run the script for increasing values of `n` (e.g. 10, 50, 100, 500, 1000, …) and redirect results into a TSV file. Plot the approximation error versus `n` using tools like **gnuplot**, **matplotlib**, or **Excel**. This produces a clear curve showing how the approximation approaches π as more primes are included.

---

#### 📈 Plotting Convergence

You can visualize how Euler’s product approximation of π improves as more primes are included:

1. **Export results to TSV**  
   Run the script with increasing values of `n` and provide an output file:
   ```bash
   ./euler_pi.sh 10 results.tsv
   ./euler_pi.sh 50 results.tsv
   ./euler_pi.sh 100 results.tsv
   ./euler_pi.sh 500 results.tsv
   ./euler_pi.sh 1000 results.tsv
   ```
   Each run appends a line to `results.tsv` containing:
   ```
   n    approx_pi    error
   ```

   **Sample dataset:**
   ```
   n    approx_pi    error
   10   3.1302432721714194784030970125274437412   0.011349381418373760059546370752059143046
   50   3.1405454588476039643105302880842350664   0.0010471947421892741521130951952678177569
   100  3.1411926604946985520569779666457541406   0.00039999309509468640566541663374874363247
   500  3.1415446230926483286891924066779625527   4.8030497144909773450976601540331480349e-5
   1000 3.1415727030005293069469452637246253626   1.9950589263931515698119554877521644878e-5
   ```

2. **Plot with gnuplot**  
   ```gnuplot
   set datafile separator "\t"
   set logscale x
   set xlabel "Number of primes (n)"
   set ylabel "Error |approx_pi - π|"
   plot "results.tsv" using 1:3 with linespoints title "Euler product convergence"
   ```

3. **Plot with matplotlib (Python)**  
   ```python
   import pandas as pd
   import matplotlib.pyplot as plt

   df = pd.read_csv("results.tsv", sep="\t")
   plt.loglog(df["n"], df["error"], marker="o")
   plt.xlabel("Number of primes (n)")
   plt.ylabel("Error |approx_pi - π|")
   plt.title("Euler Product Convergence to π")
   plt.show()
   ```

4. **Plot with Excel**  
   Import `results.tsv` into Excel, select the data, and insert a scatter plot. Use a logarithmic x‑axis to highlight convergence behavior.

**Tip:** The error decreases slowly — with 10 primes the error is ~0.011, but with 1000 primes it drops below \(2 \times 10^{-5}\). A log‑scale plot makes the convergence curve clearer.

---

## Contributing

Pull requests are welcome. Ideas for new scripts include:

- Dirichlet L-function zeros

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



