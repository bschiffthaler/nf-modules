process sortmerna_pe {

  container "bschiffthaler/sortmerna:" + params.sortmerna_version
  publishDir "analysis/sortmerna", pattern: "*.{fastq,fq}.gz"
  publishDir "report/logs/", pattern: "*sortmerna.log"
  cpus params.sortmerna_cpus

  input:
    tuple path(read1), path(read2), val(name)
    path index
    val dbs
    val args
    val meta

  output:
    tuple path("${name}_sortmerna_fwd.{fastq,fq}.gz"), path("${name}_sortmerna_rev.{fastq,fq}.gz"), val(name), emit: data_clean
    tuple path("${name}_rrna_fwd.{fastq,fq}.gz"), path("${name}_rrna_rev.{fastq,fq}.gz"), val(name), emit: data_rrna
    path "${name}_sortmerna.log", emit: log
    val meta, emit: meta

  script:
    _dbs = dbs.join(" --ref ")
    _args = args.join(" ")
    """
    sortmerna --ref ${_dbs} --reads ${read1} --reads ${read2} --idx-dir ${index} \
      --workdir ${name}_sortmerna --threads ${params.sortmerna_cpus} \
      --fastx --aligned ${name}_rrna --other ${name}_sortmerna --paired_in \
      --out2
    find . -mindepth 1 -maxdepth 1 -name "*.f*q" -exec gzip {} \\; || true
    cp ${name}_rrna.log ${name}_sortmerna.log
    """
}