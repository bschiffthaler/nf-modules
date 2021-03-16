process process_radtags_pe {

  container = "bschiffthaler/stacks:${params.stacks_version}"
  executor = params.executor
  cpus = 1

  input:
    tuple val(name), file(reads)
    val params

  output:
    tuple val(name), file("${name}_trimmed_{1.1,1.rem.1,2.2,2.rem.2}.fq.gz"), emit: data

  script:
    _params = params.join(" ")

    """
    process_radtags -1 ${reads[0]} -2 ${reads[1]} \
      -o . \
      --paired \
      ${_params}
    """
}

process ustacks {
  container = "bschiffthaler/stacks:${params.stacks_version}"
  executor = params.executor
  cpus = params.ustacks_cpus

  input:
    tuple val(id), file(reads)
    val params

  output:
    tuple val(id), file("_tmpout/*"), emit: data

  script:
    _params = params.join(" ")

    """
    mkdir _tmpout
    ustacks -f ${reads[0]} \
      -i 0 \
      -o _tmpout \
      -p ${params.ustacks_cpus} \
      ${_params}
    }
    """
}