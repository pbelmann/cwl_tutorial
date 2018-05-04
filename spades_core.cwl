cwlVersion: cwl:v1.0
class: CommandLineTool
hints:
 DockerRequirement:
   dockerImageId: "bioboxes/spades_cwl"
   dockerFile: |
     FROM bioboxes/spades
     ENTRYPOINT []
inputs:
 fastq:
   type: File[]
   label: interleaved & gzipped fasta/q paired-end files
   inputBinding:
     prefix: --12
     itemSeparator: ','
baseCommand: spades.py

arguments:  # many of these could be turned into configurable inputs
 - prefix: -o
   valueFrom: $(runtime.outdir)/output

outputs:
  spades_contigs:
    type: File
    format: edam:format_1929  # FASTA
    outputBinding:
      glob: 'output/contigs.fasta'
  stderr: stderr
