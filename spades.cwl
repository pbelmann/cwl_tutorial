cwlVersion: cwl:v1.0
class: Workflow
requirements:
  - class: StepInputExpressionRequirement
inputs:
  fastq:
    type: File[]
outputs:
  result:
    type: File
    outputSource: rename/out
steps:
  spades:
    run: spades_core.cwl
    in:
      fastq: fastq
    out:
      - spades_contigs
  rename:
    run: move.cwl
    in:
      infile: spades/spades_contigs
      outfile:
        valueFrom: "contigs.fa"
    out:
      - out
