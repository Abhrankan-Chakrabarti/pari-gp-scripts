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
  - [Analytic Roadmap](#-analytic-roadmap)
  - [riemann_zeros.sh](#riemann_zerossh)
  - [gilbreath.sh](#gilbreathsh)
  - [prime_gaps.sh](#prime_gapssh)
  - [mobius.sh](#mobiush)
  - [goldbach.sh](#goldbachsh)
  - [euler_pi.sh](#euler_pish)
    - [Plotting Convergence](#-plotting-convergence)
  - [dirichlet_zeros.sh](#dirichlet_zerossh)
    - [Zero Spacing Analysis](#-zero-spacing-analysis)
  - [liouville.sh](#liouvillesh)
  - [von_mangoldt.sh](#von_mangoldtsh)
  - [euler_totient.sh](#euler_totientsh)
  - [carmichael.sh](#carmichaelsh)
  - [jacobi.sh](#jacobish)
- [Analytic Visualizations](#-analytic-visualizations)
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
chmod +x riemann_zeros.sh gilbreath.sh prime_gaps.sh mobius.sh goldbach.sh euler_pi.sh dirichlet_zeros.sh liouville.sh von_mangoldt.sh euler_totient.sh carmichael.sh jacobi.sh
./riemann_zeros.sh 10 30 38
./gilbreath.sh 10000 1
./prime_gaps.sh 1000
./mobius.sh 50
./goldbach.sh 30 0 pairs.tsv freq.tsv count 5
./euler_pi.sh 10
./dirichlet_zeros.sh 5 2 10 30 38
./liouville.sh 10
./von_mangoldt.sh 20
./euler_totient.sh 12
./carmichael.sh 12
./jacobi.sh 2 20
```

---

## Scripts

---

### 🔮 Analytic Roadmap

Among the scripts, two stand out for **analytic visualization**:
- **euler_pi.sh** — explores Euler’s product approximation of π, highlighting its slow convergence and offering exportable datasets for plotting error curves.
- **dirichlet_zeros.sh** — computes non‑trivial zeros of Dirichlet L‑functions, enabling plots of zero distributions and spacing histograms.

Together, these scripts provide a gateway into **computational analytic number theory**, letting contributors not only compute values but also **visualize convergence and distribution patterns** using gnuplot, matplotlib, or Excel.

---

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

Approximates **π** using Euler’s product formula truncated at the first `n` primes. Euler showed that ζ(2) = π²/6 = ∏ 1/(1 − 1/p²) over all primes p, so truncating the product at the first `n` primes gives a numerical approximation of π.

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
2. Streams primes via `nextprime(p + 1)` rather than allocating a full vector — avoids PARI stack overflows and reduces memory to O(1) for large `n`.  
3. Computes the truncated Euler product ∏ 1/(1 − 1/pᵢ²) for i = 1 to n on the fly.
4. Approximates π as √(6 · product).
5. Prints the approximation, actual π, absolute error, and runtime via `gettime()`.  

Runs with `--stacksize 1000000000` as a safety margin for large `n`.

**Note on convergence:**  
Euler’s product converges very slowly. With small `n` (like 10), the approximation can be off by a few hundredths. Accuracy improves gradually as more primes are included — by `n = 1000`, the error drops below 2 × 10⁻⁵. Thousands of primes are needed for high‑precision results.

**Plot suggestion:**  
To visualize convergence, run the script for increasing values of `n` (e.g. 10, 50, 100, 500, 1000, …) and redirect results into a TSV file. Plot the approximation error versus `n` using tools like **gnuplot**, **matplotlib**, or **Excel**. This produces a clear curve showing how the approximation approaches π as more primes are included.

---

#### 📈 Plotting Convergence

You can visualize how Euler’s product approximation of π improves as more primes are included:

1. **Export results to TSV**  
   Run the script with increasing values of `n` and provide an output file:
   ```bash
   for n in 10 50 100 500 1000; do ./euler_pi.sh $n results.tsv; done
   ```
   Or use the provided Makefile target:
   ```bash
   make euler_pi
   ```
   Each run appends a line to `results.tsv` containing:
   ```
   n    approx_pi    error
   ```

   **Sample dataset:**
   ```
   n    approx_pi          error
   10   3.13024327217142   0.0113493814183738
   50   3.14054545884760   0.00104719474218927
   100  3.14119266049470   0.000399993095094686
   500  3.14154462309265   4.80304971449098e-5
   1000 3.14157270300053   1.99505892639315e-5
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

**Tip:** The error decreases slowly — with 10 primes the error is ~0.011, but with 1000 primes it drops below 2 × 10⁻⁵. A log‑scale plot makes the convergence curve clearer.

---

### dirichlet_zeros.sh

Computes the non-trivial zeros of a **Dirichlet L-function** for a given modulus and character index within a user-defined height range `[n1, n2]` on the critical line (Re(s) = 1/2).

Dirichlet L-functions generalize the Riemann zeta function by introducing characters modulo `q`. Their zeros are central to analytic number theory and the study of prime distributions in arithmetic progressions.

**Usage:**
```bash
./dirichlet_zeros.sh [modulus] [chi] [n1] [n2] [precision] [zeros.tsv]
```

- `modulus` — the modulus `q` of the Dirichlet character
- `chi` — the Conrey character label
- `n1`, `n2` — lower and upper bounds for the zero search
- `precision` — decimal precision for computations
- `zeros.tsv` — optional export file for computation results

**Example:**
```text
$ ./dirichlet_zeros.sh 5 2 10 30 38

  1: 0.5 +/- 12.674946417011355780482299145083092145*I
  2: 0.5 +/- 14.825025570328428251430252174047964647*I
  3: 0.5 +/- 17.337802106853039690914510142416566988*I
  4: 0.5 +/- 18.998588041686144928724525011929935314*I
  5: 0.5 +/- 22.487584583028750025055672909258486937*I
  6: 0.5 +/- 24.365279775402298056519095757451135569*I
  7: 0.5 +/- 25.531186800433429601457551452466566748*I
  8: 0.5 +/- 27.982756935693594324451001091893735496*I
```

**How it works:**
1. Validates that all inputs are positive integers and that `n1 <= n2`.
2. Passes parameters to a `gp -q` session.
3. Uses `lfuncreate(Mod(chi, modulus))` to construct the Dirichlet L-function from the Conrey character label.
4. Calls `lfunzeros()` to compute imaginary parts of zeros in `[n1, n2]`.
5. Formats each zero as `0.5 +/- t*I` to highlight symmetry about the critical line.

---

#### 📊 Zero Spacing Analysis

Beyond listing zeros, you can study the **distribution of gaps** between consecutive imaginary parts. This reveals how zeros are spaced along the critical line — a central theme in analytic number theory.

1. **Export zeros to TSV**  
   Run the script and provide an output file:
   ```bash
   ./dirichlet_zeros.sh 5 2 10 100 38 zeros.tsv
   ```
   Format:
   ```
   index    imaginary_part
   1        12.674946417011355...
   2        14.825025570328428...
   3        17.337802106853039...
   ...
   ```

2. **Plot with gnuplot**  
   ```gnuplot
   set datafile separator "\t"
   set xlabel "Gap size (Δt)"
   set ylabel "Frequency"
   set title "Spacing Distribution of Dirichlet L-function Zeros"
   set style data histograms
   set style fill solid 0.5
   set boxwidth 0.9
   set grid ytics

   plot "< awk 'NR>1{print $2-prev; prev=$2}' zeros.tsv" \
        using (int($1*10)/10.0):1 \
        smooth freq with boxes lc rgb "blue" title "Zero gaps"
   ```

3. **Plot with matplotlib (Python)**  
   ```python
   import pandas as pd
   import matplotlib.pyplot as plt

   df = pd.read_csv("zeros.tsv", sep="\t", names=["index","imag"])
   df["gap"] = df["imag"].diff()
   gaps = df["gap"].dropna()

   plt.hist(gaps, bins=20, edgecolor="black", alpha=0.7)
   plt.xlabel("Gap size (Δt)")
   plt.ylabel("Frequency")
   plt.title("Spacing Distribution of Dirichlet L-function Zeros")
   plt.grid(axis="y", linestyle="--", alpha=0.6)
   plt.show()
   ```

4. **Interpretation**  
   - Small gaps occur frequently, reflecting local clustering.  
   - Larger gaps are rarer but highlight irregular spacing.  
   - Comparing histograms across different moduli and characters shows how zero spacing varies between Dirichlet L‑functions.

---

### liouville.sh

Computes the **Liouville function** λ(n) = (−1)^Ω(n) for all integers up to N, where Ω(n) is the number of prime factors of n counted with multiplicity. Also tracks the running **Liouville sum** L(N) = Σ λ(k) for k = 1 to N, the analogue of the Mertens function for the Liouville function.

**Usage:**
```bash
./liouville.sh [N] [output.tsv]
```

- `N` — upper bound (must be ≥ 1)
- `output.tsv` — optional export file for λ(n) and L(n) values

**Example:**
```text
$ ./liouville.sh 10

n     λ(n)
------------
1       1
2       -1
3       -1
4       1
5       -1
6       1
7       -1
8       -1
9       1
10      1
Liouville sum L(10) = 0
Calculation Time: 0.001 s
```

**TSV export:**
```text
$ ./liouville.sh 10 output.tsv

Successfully exported 10 values to output.tsv
```

**How it works:**
1. Validates that `N` is a positive integer.
2. Computes λ(n) = (−1)^Ω(n) using PARI/GP's `bigomega(n)` for each n up to N.
3. Tracks the running Liouville sum L(N) = Σ λ(k).
4. In TSV export mode, uses a tagged stream pipeline (`DATA_START` / `DATA_END`) to cleanly separate data rows from diagnostic output, identical to the pattern used in `mobius.sh`.
5. Reports the final Liouville sum and elapsed time via `gettime()`.

---

### von_mangoldt.sh

Computes the **von Mangoldt function** Λ(n) for all integers up to N. Λ(n) = log(p) if n = p^k for some prime p and integer k ≥ 1, and 0 otherwise. Also tracks the running **Chebyshev ψ function** ψ(N) = Σ Λ(k) for k = 1 to N, which is central to the prime number theorem and the explicit formula connecting prime distributions to Riemann zeta zeros.

**Usage:**
```bash
./von_mangoldt.sh [N] [output.tsv]
```

- `N` — upper bound (must be ≥ 1)
- `output.tsv` — optional export file for Λ(n) values

**Example:**
```text
$ ./von_mangoldt.sh 20

n     Λ(n)          note
--------------------------------
1     0
2     0.693147       p=2^1
3     1.098612       p=3^1
4     0.693147       p=2^2
5     1.609438       p=5^1
6     0
7     1.945910       p=7^1
8     0.693147       p=2^3
9     1.098612       p=3^2
10    0
11    2.397895       p=11^1
12    0
13    2.564949       p=13^1
14    0
15    0
16    0.693147       p=2^4
17    2.833213       p=17^1
18    0
19    2.944439       p=19^1
20    0
Chebyshev psi(20) = 19.265658
Calculation Time: 0.001 s
```

**How it works:**
1. Validates that `N` is a positive integer.
2. Factors each integer k up to N using PARI/GP's `factor(k)`.
3. If k has exactly one distinct prime factor p with any exponent, sets Λ(k) = log(p); otherwise Λ(k) = 0.
4. Accumulates the running Chebyshev ψ(N) = Σ Λ(k).
5. Terminal mode shows the prime base and exponent in a note column for prime powers.
6. TSV export uses the tagged stream pipeline (`DATA_START` / `DATA_END`) pattern consistent with `mobius.sh` and `liouville.sh`.
7. Reports ψ(N) and elapsed time via `gettime()`.

---

### euler_totient.sh

Computes **Euler's totient function** φ(n) for all integers up to N. φ(n) counts the number of integers in [1, n] that are coprime to n. Also tracks the running **totient sum** Φ(N) = Σ φ(k) for k = 1 to N.

**Usage:**
```bash
./euler_totient.sh [N] [output.tsv]
```

- `N` — upper bound (must be ≥ 1)
- `output.tsv` — optional export file for φ(n) values

**Example:**
```text
$ ./euler_totient.sh 12

n     φ(n)
------------
1       1
2       1
3       2
4       2
5       4
6       2
7       6
8       4
9       6
10      4
11      10
12      4
Totient sum Φ(12) = 46
Calculation Time: 0.001 s
```

**How it works:**
1. Validates that `N` is a positive integer.
2. Computes φ(n) using PARI/GP's built-in `eulerphi(k)` for each k up to N.
3. Accumulates the running totient sum Φ(N).
4. TSV export uses the tagged stream pipeline (`DATA_START` / `DATA_END`) pattern consistent with `mobius.sh` and `liouville.sh`.
5. Reports Φ(N) and elapsed time via `gettime()`.

---

### carmichael.sh

Computes the **Carmichael function** λ(n) for all integers up to N. λ(n) is the smallest positive integer m such that a^m ≡ 1 (mod n) for all a coprime to n. Displays λ(n) alongside φ(n) with a comparison column showing where they differ.

**Usage:**
```bash
./carmichael.sh [N] [output.tsv]
```

- `N` — upper bound (must be ≥ 1)
- `output.tsv` — optional export file for λ(n) and φ(n) values

**Example:**
```text
$ ./carmichael.sh 12

n     λ(n)   φ(n)   λ=φ?
----------------------------
1       1       1       yes
2       1       1       yes
3       2       2       yes
4       2       2       yes
5       4       4       yes
6       2       2       yes
7       6       6       yes
8       2       4       no
9       6       6       yes
10      4       4       yes
11      10      10      yes
12      2       4       no
Calculation Time: 0.001 s
```

**How it works:**
1. Validates that `N` is a positive integer.
2. Computes λ(n) using `lcm(znstar(k)[2])` — the LCM of the orders of elements in (Z/nZ)*.
3. Computes φ(n) via `eulerphi(k)` for side-by-side comparison.
4. Marks rows where λ(n) = φ(n) — these are exactly n = 1, 2, 4, p^k, and 2p^k for odd primes p.
5. TSV export uses the tagged stream pipeline pattern consistent with the rest of the collection.
6. Reports elapsed time via `gettime()`.

---

### jacobi.sh

Computes the **Jacobi symbol** (a/n) for a given integer a across all odd integers n up to N. The Jacobi symbol generalizes the Legendre symbol (a/p) from prime moduli to arbitrary odd moduli. For prime n, (a/n) = 1 if a is a quadratic residue mod n, −1 if not, and 0 if n divides a.

**Usage:**
```bash
./jacobi.sh [a] [N] [output.tsv]
```

- `a` — the numerator (any integer, including negative)
- `N` — upper bound for odd n (must be ≥ 1)
- `output.tsv` — optional export file for Jacobi symbol values

**Example:**
```text
$ ./jacobi.sh 2 20

n     (2/n)
------------
1       1
3       -1
5       -1
7       1
9       1
11      -1
13      -1
15      1
17      1
19      -1
Calculation Time: 0.000 s
```

**How it works:**
1. Validates that `a` is an integer and `N` is a positive integer.
2. Iterates over odd integers n from 1 to N using `forstep(n=1, N, 2, ...)`.
3. Computes the Jacobi symbol using PARI/GP's `kronecker(a, n)` — which correctly handles the Jacobi symbol for odd n and extends to the Kronecker symbol for even n.
4. TSV export uses the tagged stream pipeline pattern consistent with the rest of the collection.
5. Reports elapsed time via `gettime()`.

---

## 📊 Analytic Visualizations

Several scripts in this collection lend themselves to **visual analysis**. Beyond raw outputs, you can export results to TSV files and plot them to study convergence and distribution patterns.

### Euler Product Convergence (π approximation)

The script **euler_pi.sh** shows how truncating Euler’s product at the first `n` primes approximates π.  
- Export results with increasing `n` into a TSV file (`n`, `approx_pi`, `error`).  
- Plot error versus `n` using **gnuplot**, **matplotlib**, or Excel.  
- A log‑scale x‑axis highlights the slow convergence: with 10 primes the error is ~0.011, while with 1000 primes it drops below 2 × 10⁻⁵.

**Sample gnuplot snippet:**
```gnuplot
set datafile separator "\t"
set logscale x
set xlabel "Number of primes (n)"
set ylabel "Error |approx_pi - π|"
plot "results.tsv" using 1:3 with linespoints title "Euler product convergence"
```

---

### Dirichlet L-function Zero Spacing

The script **dirichlet_zeros.sh** computes non‑trivial zeros of Dirichlet L‑functions.  
- Export zeros into a TSV file (`index`, `imaginary_part`).  
- Plot imaginary parts versus index to visualize zero distribution.  
- Compute consecutive gaps to analyze spacing frequencies.

**Sample gnuplot snippet (histogram of gaps):**
```gnuplot
set datafile separator "\t"
set xlabel "Gap size (Δt)"
set ylabel "Frequency"
set title "Spacing Distribution of Dirichlet L-function Zeros"
plot "< awk 'NR>1{print $2-prev; prev=$2}' zeros.tsv" \
     smooth freq with boxes lc rgb "blue" title "Zero gaps"
```

**Sample matplotlib snippet:**
```python
import pandas as pd
import matplotlib.pyplot as plt

df = pd.read_csv("zeros.tsv", sep="\t", names=["index","imag"])
gaps = df["imag"].diff().dropna()

plt.hist(gaps, bins=20, edgecolor="black", alpha=0.7)
plt.xlabel("Gap size (Δt)")
plt.ylabel("Frequency")
plt.title("Spacing Distribution of Dirichlet L-function Zeros")
plt.grid(axis="y", linestyle="--", alpha=0.6)
plt.show()
```

---

### 🔎 Interpretation
- **Euler product:** Demonstrates slow but steady convergence of analytic formulas.  
- **Dirichlet zeros:** Highlights local clustering and irregular spacing, extending classical zeta zero studies to generalized L‑functions.  
- Together, these visualizations showcase how computational number theory can be explored not just numerically but graphically.

---

## Contributing

Pull requests are welcome. Each script should follow the conventions of the existing ones:

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

