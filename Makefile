# pari-gp-scripts Makefile
# Generates TSV datasets for convergence analysis.
# Plotting is left to the user's preferred tool (gnuplot, matplotlib, Excel).

euler_pi:
	@echo "Generating Euler product convergence dataset..."
	@rm -f results.tsv
	@for n in 10 50 100 500 1000; do ./euler_pi.sh $$n results.tsv; done
	@echo "Done. Dataset written to results.tsv"

clean:
	@rm -f results.tsv
	@echo "Cleaned up generated files."

.PHONY: euler_pi clean
