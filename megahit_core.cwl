cwlVersion: cwl:v1.0
class: CommandLineTool
hints:
 DockerRequirement:
   dockerPull: quay.io/biocontainers/megahit:1.1.1--py36_0

inputs:
 fastq:
   type: File[]
   label: interleaved & gzipped fasta/q paired-end files
   inputBinding:
     prefix: --12
     itemSeparator: ','
baseCommand: megahit

arguments:  # many of these could be turned into configurable inputs
 - prefix: --out-dir
   valueFrom: $(runtime.outdir)/output

outputs:
  megahit_contigs:
    type: File
    format: edam:format_1929  # FASTA
    outputBinding:
      glob: 'output/final.contigs.fa'
  stderr: stderr
