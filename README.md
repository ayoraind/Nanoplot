## Workflow to remove Human DNA contaminants from microbial reads.
### Usage

```

=======================================================================
  LONG READ SEQUENCE DATASET STATISTICS: TAPIR Pipeline version 1.0dev
=======================================================================
 The typical command for running the pipeline is as follows:
        nextflow run main.nf --reads "PathToReadFile(s)" --output_dir "PathToOutputDir" --sequencing_date "GYYMMDD" 

        Mandatory arguments:
         --reads                        Query fastq.gz file of sequences you wish to supply as input (e.g., "/MIGE/01_DATA/01_FASTQ/T055-8-*.fastq.gz")
         --sequencing_date              sequencing date (e.g., G230519)
         --output_dir                   Output directory to place output (e.g., "/MIGE/01_DATA/03_ASSEMBLY")
         
        Optional arguments:
         --help                         This usage statement.
         --version                      Version statement

```


## Introduction
This pipeline generates statistic summary and plots of a Long Read Dataset. A certain percentage of this pipeline was adapted from the NF Core's [nanoplot module](https://github.com/nf-core/modules/tree/master/modules/nf-core/nanoplot). We also acknowledge the [original authors](https://github.com/wdecoster/NanoPlot/tree/master).  


## Sample command
An example of a command to run this pipeline is:

```
nextflow run main.nf --reads "Sample_files/*.fastq.gz" --output_dir "test2" --sequencing_date "GYYMMDD"
```

## Word of Note
This is an ongoing project at the Microbial Genome Analysis Group, Institute for Infection Prevention and Hospital Epidemiology, Üniversitätsklinikum, Freiburg. The project is funded by BMBF, Germany, and is led by [Dr. Sandra Reuter](https://www.uniklinik-freiburg.de/iuk-en/infection-prevention-and-hospital-epidemiology/research-group-reuter.html).


## Authors and acknowledgment
The TAPIR (Track Acquisition of Pathogens In Real-time) team.
