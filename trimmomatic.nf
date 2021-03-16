process trimmomatic_pe {

  container "bschiffthaler/trimmomatic:${params.trimmomatic_version}"
  publishDir "analysis/01-trimmomatic", pattern: "*.fastq.gz"
  publishDir "report/logs/", pattern: "*.log"
  cpus params.trimmomatic_cpus

  input:
    tuple path(read1), path(read2), val(name)
    val trimmers
    val meta

  output:
    tuple val(name), path("${name}_trimmed_{1,2}.fastq.gz"), emit: data
    path "${name}_trimmomatic.log"
    val meta, emit: meta

  script:
    _trimmers = trimmers.join(" ")
    """
    run.sh PE -threads ${params.trimmomatic_cpus} \
      ${read1} ${read2} \
      ${name}_trimmed_1.fastq.gz ${name}_orphans_1.fastq.gz \
      ${name}_trimmed_2.fastq.gz ${name}_orphans_2.fastq.gz \
      ${_trimmers} &> ${name}_trimmomatic.log
    """
}

def map_input_pe(Ch) {
  Ch.map(row -> { 
    ["${baseDir}/" + row.RF, "${baseDir}/" + row.RS, row.Id] 
  })
}