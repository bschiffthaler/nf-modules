process process_radtags_pe {

  container "bschiffthaler/stacks:" + params.stacks_version
  executor params.executor
  publishDir "report/logs/", pattern: "*.log"
  cpus 1

  input:
    tuple path(read1), path(read2), val(name)
    val args
    val meta

  output:
    tuple path("${name}_trimmed_{1.1,1.rem.1,2.2,2.rem.2}.fq.gz"), val(name), emit: data
    path "${name}_process_radtags.log"
    val meta, emit: meta

  script:
    _args = args.join(" ")

    """
    process_radtags -1 ${read1} -2 ${read2} \
      -o . \
      --paired \
      ${_args} &> ${name}_process_radtags.log
    """
}

process ustacks {

  container "bschiffthaler/stacks:" + params.stacks_version
  executor params.executor
  cpus params.ustacks_cpus
  publishDir "report/logs/", pattern: "*.log"

  input:
    tuple path(reads), val(name)
    val args
    val meta

  output:
    tuple path("_tmpout/*"), val(name), emit: data
    path "${name}_ustacks.log"
    val meta, emit: meta

  script:
    _args = args.join(" ")
    _id = meta.NumId
    """
    mkdir _tmpout
    ustacks -f ${reads[0]} \
      -i ${_id} \
      -o _tmpout \
      -p ${params.ustacks_cpus} \
      ${_params} &> ${name}_ustacks.log
    }
    """
}