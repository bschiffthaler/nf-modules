process fastqc_pe {

  container "bschiffthaler/fastqc:" + params.fastqc_version
  publishDir "report/00-qc/${stage}", pattern: "*.{html,zip}"
  publishDir "report/logs/", pattern: "*.log"
  executor params.executor
  cpus 2

  input:
    val stage
    tuple path(read1), path(read2), val(name)
    val meta

  output:
    path "*.{zip,html}"
    path "*.log"
    val meta, emit: meta

  """
  fastqc -t 2 -o . ${read1} ${read2} &> ${name}_fastqc_${stage}.log
  """
}

def map_input_pe(Ch) {
  Ch.map(row -> { 
    ["${baseDir}/" + row.RF, "${baseDir}/" + row.RS, row.Id] 
  })
}