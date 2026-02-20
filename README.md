# Human Germline Variant Calling and Variant Annotation (GRCh38)

[![Snakemake](https://img.shields.io/badge/snakemake-≥7.32.4-brightgreen.svg)](https://snakemake.github.io)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

This repository contains a Snakemake-based workflow for human germline variant calling, demonstrated on chromosome 20 using publicly available sequencing data (NA12878).

## 📁 Workflow steps

- Quality control: FastQC
- Trimming: Fastp (optional)
- Alignment: BWA-MEM
- BAM processing: SAMtools, Picard MarkDuplicates
- Variant calling: GATK HaplotypeCaller
- Variant annotation: SnpEff (GRCh38)

**Key Goals:**
- Identify single nucleotide polymorphisms (SNPs) and small insertions and deletions (indels) from publicly available human DNA-seq data.
- Perform quality control, alignment, duplicate marking, variant calling, filtering, and functional annotation aligned to the GRCh38 reference genome.
- Generate filtered and annotated variant call files (VCF) suitable for downstream interpretation and reporting.
- Implement a reproducible Snakemake-based workflow for human germline variant calling.

## Environment

- Developed in WSL2 Ubuntu
- Conda-managed environment
- Snakemake workflow

## 📁 Project structure
```
germline-variant-calling/
├── config/
│   └── config.yaml
├── data/
│   └── raw/        # FASTQ files here
├── resources/
│   └── reference/  # GRCh38 chr20 FASTA & indexes
├── workflow/
│   └── Snakefile
├── scripts/        # optional - helper scripts
├── logs/
├── .gitignore
├── environment.yml
└── README.md
```

## ⚙️ Installation & Setup

1.  **Clone the repository:**
    ```bash
    git clone git@github.com:Achukwunta/germline-variant-calling.git
    cd germline-variant-calling
    ```

2.  **Download Required Databases:**  
    Download the GRCh38 reference genome (chromosome 20) and sample data (NA12878). Next, place the files and place it in the `resources/reference/` directory. Paths are specified in `config.yaml`.

3.  **Create and activate the Conda environment:**
    ```bash
    conda env create -f environment.yml
    conda activate germline-variant-calling
	```
	
## 🚀 Running the Pipeline

The pipeline is managed with Snakemake. You need to first install Snakemake:
```bash
snakemake --cores all --use-conda
```
Use `--use-conda` to ensure all dependencies are managed in isolated environments

## 🔬 Pipeline Steps

1. **Quality Control:** Raw sequencing reads are assessed using `FastQC`, with summary reporting via `MultiQC`.
2. **Trimming:** Raw sequencing reads undergo trimming to remove low quality bases and adapter contaminatuion using `Fastp`.
3. **Alignment:** Paired-end reads are aligned to the GRCh38 reference genome (chromosome 20) using `BWA-MEM`.
4. **BAM Processing:** Aligned reads are sorted and indexed with `SAMtools`, followed by duplicate marking using `Picard MarkDuplicates`.
5. **Variant Calling:** Germline single nucleotide polymorphisms (SNPs) and small insertions/deletions (indels) are identified using `GATK HaplotypeCaller`.
6. **Variant Filtering:** Raw variant calls are filtered using standard hard-filter criteria to retain high-confidence variants.
7. **Functional Annotation:** Filtered variants are functionally annotated using `SnpEff` with GRCh38 annotations.

## 🔧 Configuration

Project-specific parameters, file paths, and computational resources are defined in the `config/config.yaml`

```text
**Example parameters** include:
- Sample identifiers
- FASTQ file paths
- Reference genome location
- Thread allocation for alignment and variant calling
```

## 📊 Data Sources

- **Human sequencing data**: Publicly available NA12878 whole-genome sequencing data from the 1000 Genomes Project.
- **Reference genome**: Human GRCh38 reference genome from Ensembl(chromosome 20 subset).
- **Annotation database**: SnpEff GRCh38 annotation database.

All data used in this project are publicly available and suitable for workflow development and training purposes.

## ⚠️ Scope & Disclaimer

This workflow is intended for demonstration, training, and pipeline development purposes only. It is not intended for clinical use or medical decision-making.

For local development, analysis is restricted to chromosome 20 to reduce computational requirements. The workflow is designed to scale to whole-genome analyses on HPC systems.

## 👨‍💻 Author

**Augustine Chukwunta**  
MSc Candidate in Biology  
Brandon University, Manitoba, Canada  

Research focus: Bioinformatics pipeline development, genomics data analysis, and multi-omics workflows.
Advisor: Dr. Bryan Cassone  
GitHub: https://github.com/Achukwunta

https://img.shields.io/badge/GitHub-Achukwunta-blue?logo=github

## 🤝 Contributing & Contact
For questions about the analysis, suggestions for improvement, or potential collaboration, please contact Augustine Chukwunta or open an issue on this repository.
Thank you and Happy research!# germline-variant-calling
