#!/bin/bash

SECONDS=0
# Set working directory
cd /mnt/f/variant_calling

echo "Creating a necessary folders"
mkdir -p {raw_fastq,qc,ref,bam,vcf,annotation,logs}

echo "Step 1: Downloading sample data (NA12878) from 1000 genomes project"
wget -P raw_fastq/ ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR622/SRR622457/SRR622457_1.fastq.gz
wget -P raw_fastq/ ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR622/SRR622457/SRR622457_2.fastq.gz


echo "Step 2: Quality control processing on raw reads"
# Run FastQC on raw reads
fastqc raw_fastq/SRR622457_1.fastq.gz raw_fastq/SRR622457_2.fastq.gz -o qc/
# Aggregate FastQC reports
multiqc qc/ -o qc/

# Trimming
# Note: Trimming was skipped because no adapter contamination and severe quality drop
# Also to preserve read length and variant evidence

#fastp \
#  -i raw_fastq/SRR622457_1.fastq.gz \
#  -I raw_fastq/SRR622457_2.fastq.gz \
#  -o raw_fastq/SRR622457_1.trimmed.fastq.gz \
#  -O raw_fastq/SRR622457_2.trimmed.fastq.gz \
#  --detect_adapter_for_pe \
#  --qualified_quality_phred 20 \
#  --length_required 50 \
#  --thread 8 \
#  --html qc/fastp.html \
#  --json qc/fastp.json


echo "Step 3: Downloading GRCh38 chromosome 20 from Ensembl"
wget -P ref/ ftp://ftp.ensembl.org/pub/release-115/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.chromosome.20.fa.gz
# Decompress
gunzip ref/Homo_sapiens.GRCh38.dna.chromosome.20.fa.gz
# Rename the reference genome for simplicity
mv ref/Homo_sapiens.GRCh38.dna.chromosome.20.fa ref/chr20.fa


echo "Step 4: Indexing the reference genome"
# Index for BWA alignment
bwa index ref/chr20.fa
# FASTA index for samtools/GATK
samtools faidx ref/chr20.fa
# Create sequence dictionary for Picard/GATK
picard CreateSequenceDictionary R=ref/chr20.fa O=ref/chr20.dict


echo "Step 5: mapping raw reads to the reference genome (chr20): BWA-MEM"
bwa mem -t 8 ref/chr20.fa raw_fastq/SRR622457_1.fastq.gz raw_fastq/SRR622457_2.fastq.gz \
  | samtools view -bS - > bam/SRR622457_unsorted.bam


echo "Step 6: Indexing BAM files"
# Sort BAM by genomic coordinates
samtools sort -@ 8 -o bam/SRR622457.sorted.bam bam/SRR622457.unsorted.bam
# Index the sorted BAM
samtools index bam/SRR622457.sorted.bam


echo "Step 7: Marking PCR duplicates (Picard)"
picard MarkDuplicates \
  I=bam/SRR622457.sorted.bam \
  O=bam/SRR622457.markdup.bam \
  M=logs/SRR622457.dup_metrics.txt \
  CREATE_INDEX=true


echo "Step 8: Germline variant calling (GATK HaplotypeCaller)"
# Call germline variants on chr20
gatk HaplotypeCaller \
  -R ref/chr20.fa \
  -I bam/SRR622457.markdup.bam \
  -O vcf/SRR622457.raw.vcf.gz

# Perform basic SNP quality filters
gatk VariantFiltration \
  -R ref/chr20.fa \
  -V vcf/SRR622457.raw.vcf.gz \
  -O vcf/SRR622457.filtered.vcf.gz \
  --filter-name "QD2"  --filter-expression "QD < 2.0" \
  --filter-name "FS60" --filter-expression "FS > 60.0" \
  --filter-name "MQ40" --filter-expression "MQ < 40.0"



echo  "Step 9: Downloading GRCh38 annotation database (SnPEFF)"
snpEff download GRCh38.86
# Annotate filtered variants
snpEff GRCh38.86 vcf/SRR622457.filtered.vcf.gz > annotation/SRR622457.annotated.vcf



echo "Step 10: Extracting useful fields into a table"
gatk VariantsToTable \
  -V annotation/SRR622457.annotated.vcf \
  -F CHROM -F POS -F REF -F ALT -F FILTER \
  -GF GT \
  -O annotation/SRR622457.variants.tsv



echo "GERMLINE VARIANT CALLING FINISHED SUCCESSFULLY!"







duration=$SECONDS
echo "$(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."





























