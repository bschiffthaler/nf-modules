process fastq_screen_pe {

  container "bschiffthaler/fastq_screen:" + params.fastq_screen_version
  publishDir "analysis/fastq_screen", pattern: "*_screen.{png,html,txt}"
  publishDir "report/logs/", pattern: "*_screen.log"
  cpus params.fastq_screen_cpus

  input:
    tuple path(read1), path(read2), val(name)
    path index
    val args
    val meta

  output:
    path "*_screen.{png,html,txt}", emit: data
    path "*_screen.log", emit: log
    val meta, emit: meta

  script:
    _args = args.join(" ")
    """
    fastq_screen --aligner bowtie2 \
      --conf ${index}/fastq_screen.conf \
      --threads ${params.fastq_screen_cpus} ${read1} ${read2} \
      2>&1 > ${name}_screen.log
    """
}