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
  megahit:
    run: megahit_core.cwl
    in:
      fastq: fastq
    out:
      - megahit_contigs
  rename:
    run: move.cwl
    in:
      infile: megahit/megahit_contigs
      outfile:
        valueFrom: "contigs.fa"
    out:
      - out
