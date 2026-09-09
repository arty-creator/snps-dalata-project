# SNPs in *Dipteryx alata*

This repository contains the scripts and supporting files used for the identification, filtering, annotation, and characterization of Single Nucleotide Polymorphisms (SNPs) in *Dipteryx alata* (baru tree) using whole-genome sequencing (WGS) data.

The analyses presented in this repository are part of a master's dissertation and the associated manuscript.

## Data

The dataset consists of whole-genome sequencing data from 24 *Dipteryx alata* individuals, with approximately 9–14× sequencing coverage.

Large input and output files, including FASTQ, BAM, and VCF files, are not included in this repository.

## Pipeline

The main steps of the analysis include:

1. SNP calling
2. SNP annotation
3. SNP analysis and characterization of variants

## Tools

* **GATK** — SNP calling and variant processing
* **SAMtools/BCFtools** — manipulation and filtering of genomic variant files
* **snpEff** — functional annotation of SNPs
* **R/Python** — statistical analyses and visualization

## Repository Structure

```text
snp-dalata-project/
├── README.md
├── CITATION.cff
├── .gitignore
├── scripts/
├── figures/
└── environment/
```

## Reproducibility

The scripts used to generate the analyses and figures presented in the manuscript are provided in this repository.

Software and package versions are documented in the `environment/` directory.
