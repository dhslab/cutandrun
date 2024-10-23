process SAMTOOLS_CUSTOMVIEW {
    tag "$meta.id"
    label 'process_medium'

    conda "bioconda::samtools=1.19.2"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/samtools:1.19.2--h50ea8bc_0' :
        'biocontainers/samtools:1.19.2--h50ea8bc_0' }"

    input:
    tuple val(meta), path(bam), path(bai)

    output:
    tuple val(meta), path("*.txt") , emit: tsv
    path  "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args     = task.ext.args ?: ''
    def args2    = task.ext.args2 ?: ''
    def prefix   = task.ext.suffix ? "${meta.id}${task.ext.suffix}" : "${meta.id}"
    """
    if [ \$(stat -Lc%s "$bam") -gt 10737418240 ]; then
        echo "File is larger than 10 GB, downsampling to 0.25..."
        samtools view -b -s 0.25 "$bam" > temp.bam
        input_bam="temp.bam"
    else
        echo "File size is below 10 GB, processing without downsampling..."
        input_bam=$bam
    fi

    samtools view $args -@ $task.cpus \$input_bam | $args2 > ${prefix}.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        samtools: \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//')
    END_VERSIONS
    """
}
