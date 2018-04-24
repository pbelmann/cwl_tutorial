# Cwl Tutorial Short Read Assembler

This tutorial shows how create a cwl based biobox of your tool. The procedure consists of three steps.

**1.Integrating your Tool into a Docker container**
**1.Integrating your Tool into a Docker container**

1. The first step is to integrate your tool into a Docker container. There are multiple tutorials online available for
dockerizing your tool. The most common way is to write a [Dockerfile](https://docs.docker.com/engine/reference/builder/) 
and make it available on [DockerHub](https://hub.docker.com/).

2. In the second step you will have to look up the input and output definitions for your workflow (https://github.com/bioboxes/rfc)
In the following steps we will use the assembler interface that needs a fastq file as an input and fasta file as output.

3. Now you can start writing your cwl workflow file by first describing the input and output of your workflow:

~~~YAML
cwlVersion: cwl:v1.0
class: Workflow
inputs:
  dataset:
    type: File[]
outputs:
  result:
    type: File
    outputSource: megahit/megahit_contigs
steps:
  megahit:
    run:
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
         outputBinding:
           glob: 'output/final.contigs.fa'
       stderr: stderr
    in:
      fastq: dataset
    out:
      - megahit_contigs
~~~

The main part of your workflow is the megahit step which accepts a list of fastq as input and produces fasta as output.
In this workflow we are using the megahit [biocontainer](https://biocontainers.pro/registry/#/) which is a collection of containerized bioinformatics software. 

4. The rfc of the short read assembler demands a fasta file as output with the name **contigs.fa**.
So we have to add a post processing step which simply renames the file.

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
    run:
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
         outputBinding:
           glob: 'output/final.contigs.fa'
       stderr: stderr
    in:
      fastq: dataset
    out:
      - megahit_contigs
  rename:
    run:
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
    in:
      infile: megahit/megahit_contigs
      outfile:
        valueFrom: "contigs.fa"
    out:
      - out
~~~
