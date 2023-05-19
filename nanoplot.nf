params.reads = 'reads/*.fastq.gz'
params.output_dir = 'output_dir'
params.sequencing_date = 'GYYMMDD'

process NANOPLOT {
    tag "$meta"
    publishDir "${params.output_dir}/${meta}", mode:'copy'
        
    input:
    tuple val(meta), path(ontfile)

    output:
    tuple val(meta), path("*.html")                , emit: html_ch
    tuple val(meta), path("*.png") , optional: true, emit: png_ch
    tuple val(meta), path("*.txt")                 , emit: txt_ch
    tuple val(meta), path("*.log")                 , emit: log_ch
    path  "versions.yml"                           , emit: versions_ch

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def input_file = ("$ontfile".endsWith(".fastq.gz")) ? "--fastq ${ontfile}" :
        ("$ontfile".endsWith(".txt")) ? "--summary ${ontfile}" : ''
    """
    NanoPlot \\
        $args \\
        -t $task.cpus \\
        $input_file
	
    # rename
    mv NanoStats.txt ${meta}.NanoStats.txt
	
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        nanoplot: \$(echo \$(NanoPlot --version 2>&1) | sed 's/^.*NanoPlot //; s/ .*\$//')
    END_VERSIONS
    """
}

process NANOSTATS_TRANSPOSE {
   // publishDir "${params.output_dir}", mode:'copy'
    tag "$sample_id"
    
    
    input:
    tuple val(sample_id), path(txt)
    
    output:
    path("*.transposed.NanoStats.txt"), emit: nanostats_ch

    
    script:
    """ 
    transpose_nanoplot.sh ${sample_id}

    """
}

process COMBINE_NANOSTATS {
    publishDir "${params.output_dir}", mode:'copy'
    tag { 'combine nanostats files'} 
    
    
    input:
    path(nanostats_files)
    val(sequencing_date)

    output:
    path("combined_nanostats_${sequencing_date}.txt"), emit: nanostats_comb_ch

    
    script:
    """ 
    NANOSTATS_FILES=(${nanostats_files})
    
    for index in \${!NANOSTATS_FILES[@]}; do
    NANOSTATS_FILE=\${NANOSTATS_FILES[\$index]}
    
    # add header line if first file
    if [[ \$index -eq 0 ]]; then
      echo "\$(head -1 \${NANOSTATS_FILE})" >> combined_nanostats_${sequencing_date}.txt
    fi
    echo "\$(awk 'FNR==2 {print}' \${NANOSTATS_FILE})" >> combined_nanostats_${sequencing_date}.txt
    done

    """
}

workflow {
         reads_ch = channel
                          .fromPath( params.reads, checkIfExists: true )
                          .map { file -> tuple(file.simpleName, file) }
			  
	 NANOPLOT(reads_ch)
	 
	 NANOSTATS_TRANSPOSE(NANOPLOT.out.txt_ch)


         collected_nanostatistics_ch = NANOSTATS_TRANSPOSE.out.nanostats_ch.collect( sort: {a, b -> a[0].getBaseName() <=> b[0].getBaseName()} )

         COMBINE_NANOSTATS(collected_nanostatistics_ch, params.sequencing_date)
}
