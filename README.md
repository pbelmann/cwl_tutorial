# CWL Tutorial Short Read Assembler

This tutorial shows how create a cwl based biobox of your tool. The procedure consists of three steps.

**1.Integrating your Tool into a Docker container**

1. The first step is to integrate your tool into a Docker container. There are multiple tutorials online available for
dockerizing your tool. The most common way is to write a [Dockerfile](https://docs.docker.com/engine/reference/builder/) 
and make it available on [DockerHub](https://hub.docker.com/).

2. In the second step you should write a cwl workflow just for your tool. In the following steps we will use the assembler interface as an example and megahit as a an example assembler (megahist_core.cwl):

~~~YAML
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

arguments:
 - prefix: --out-dir
   valueFrom: $(runtime.outdir)/output

outputs:
  megahit_contigs:
    type: File
    format: edam:format_1929  # FASTA
    outputBinding:
      glob: 'output/final.contigs.fa'
  stderr: stderr
~~~

The megahit assembler accepts a list of fastq as input and produces fasta as output.
In this workflow we are using the megahit [biocontainer](https://biocontainers.pro/registry/#/) which is a collection of containerized bioinformatics software. This workflow can be executed directly with the following command:

~~~BASH
cwltool  megahit_core.cwl --fastq reads.fq.gz
~~~

3. In the next step you will have to look up the input and output definitions for your workflow (https://github.com/bioboxes/rfc)
As mentioned in the previous step will use the assembler interface that needs a fastq file as an input and fasta file as output. The rfc of the short read assembler demands a fasta file as output with the name **contigs.fa**. This means that 
the output file must be renamed. This can be done with the following cwl snippet (move.cwl):

~~~BASH
cwlVersion: v1.0
class: CommandLineTool
baseCommand: mv
inputs:
  infile:
    type: File
    inputBinding:
      position: 1
  outfile:
    type: string
    inputBinding:
      position: 2
outputs:
  out:
    type: File
    outputBinding:
      glob: $(inputs.outfile)
~~~

This is again a cwl snippet which is indepent of other cwl files:

~~~BASH
cwltool move.cwl  --infile test.txt --outfile test2.txt
~~~

4. Now you have to combine this two tool descriptions in the following workflow:

~~~YAML
cwlVersion: cwl:v1.0
class: Workflow
requirements:
  - class: StepInputExpressionRequirement
inputs:
  dataset:
    type: File[]
outputs:
  result:
    type: File
    outputSource: rename/out
steps:
  megahit:
    run: megahit_core.cwl
    in:
      fastq: dataset
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
~~~

This cwl file references megahit cwl description and the cwl version of the move command. For megahit it just passes the fastq input parameter to the workflow and renames the megahit output to **contigs.fa** which is requested by the rfc.

~~~BASH
cwltool  megahit.cwl --fastq reads.fq.gz
~~~
