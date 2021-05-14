process salmon_pe {

  container "bschiffthaler/salmon:" + params.salmon_version
  publishDir "analysis/${prefix}", pattern: "salmon_*"
  publishDir "report/logs/${prefix}", pattern: "*salmon_logs"
  cpus params.salmon_cpus

  input:
    val prefix
    tuple path(read1), path(read2), val(name)
    path index
    val libtype
    val args
    val meta

  output:
    tuple path("salmon_${name}"), val(name), emit: data
    path "${name}_salmon_logs", emit: log
    val meta, emit: meta

  script:
    _args = args.join(" ")
    """
    salmon quant -l${libtype} -i ${index} -1 ${read1} -2 ${read2} \
      -p ${params.salmon_cpus} -o salmon_${name} \
      ${_args}
    mkdir ${name}_salmon_logs
    cp -r salmon_${name}/logs ${name}_salmon_logs/.
    cp -r salmon_${name}/libParams ${name}_salmon_logs/.
    cp -r salmon_${name}/aux_info ${name}_salmon_logs/.
    """
}

process salmon_index_with_decoy {

  container "bschiffthaler/salmon:" + params.salmon_version
  publishDir "analysis/salmon", pattern: "salmon_index"
  publishDir "report/logs/", pattern: "salmon_index.log"
  cpus params.salmon_index_cpus

  input:
    path(transcriptome)
    path(genome)
    val args

  output:
    path salmon_index, emit: data
    path "salmon_index.log", emit: log

  script:
    _args = args.join(" ")
    """
    zcat ${genome} | grep -E '^>' | cut -d ' ' -f 1 > decoys.txt
    sed -i.bak -e 's/>//g' decoys.txt
    cat ${transcriptome} ${genome} > gentrome.fa.gz
    salmon index -t gentrome.fa.gz -d decoys.txt \
      -p ${params.salmon_index_cpus} -i salmon_index ${_args} \
      2>&1 | tee salmon_index.log
    """
}

def map_input_pe(Ch) {
  Ch.map(row -> { 
    ["${baseDir}/" + row.RF, "${baseDir}/" + row.RS, row.Id] 
  })
}

def bibtex() {
  """
  """
}

def citekey() {
  ""
}