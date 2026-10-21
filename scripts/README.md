# SNP Project Scripts

This folder contains notebooks and R Markdown scripts used for SNP processing and analysis in the Dipteryx alata project.

## Contents

### Jupyter notebooks

- [`gatk_baru.ipynb`](./gatk_baru.ipynb) — main workflow for read alignment, variant calling, recalibration, and filtering using GATK.
- [`annotation.ipynb`](./annotation.ipynb) — custom snpEff database preparation and functional annotation of variants.

### R Markdown analyses

- [`tassel_script.Rmd`](./tassel_script.Rmd) — summarizes nucleotide diversity (π), Watterson's theta (θ), Tajima's D, missingness, and mean depth. It generates diversity plots overall and by chromosome, plus a per-individual mean-depth plot. It reads `no_maf/dalata_diversity_slidingwindow1.xlsx` (tab-delimited), `no_maf/analise_exploratoria.lmiss`, `no_maf/analise_exploratoria.ldepth.mean`, and `profundidade_individuo.idepth`. The plots are saved as TIFF, PNG, and PDF files in the working directory.
- [`snp_ann_circle.Rmd`](./snp_ann_circle.Rmd) — parses SnpEff `ANN` annotations from a three-column TSV (`CHROM`, `POS`, `ANN`), summarizes SNP counts in genomic windows, and plots total, CDS, missense, and high-impact SNP density in a circular ideogram. It reads `ann_raw.tsv` and writes `snp_density_by_window.tsv` and `figura_SNPs_circos.pdf`.

## Organization

The notebooks cover the main bioinformatics workflow, while the R Markdown documents provide downstream diversity, depth, and annotation analyses.

## Notes

- Raw data, reference files, and large output files are not stored in this directory.
- The R Markdown analyses require R and their imported packages (`tidyverse`, `dplyr`, `tibble`, `ggh4x`, `readr`, `data.table`, `circlize`, and `ComplexHeatmap`).
- Configure the input paths and make sure the required dependencies and upstream input files are available before running any analysis.
- For general project context, see the [main README](../README.md).
