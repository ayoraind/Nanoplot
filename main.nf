#!/usr/bin/env nextflow

nextflow.enable.dsl=2

// include non-process modules
include { help_message; version_message; complete_message; error_message; pipeline_start_message } from './modules/messages.nf'
include { default_params; check_params } from './modules/params_parser.nf'
include { help_or_version } from './modules/params_utilities.nf'

version = '1.0dev'

// setup default params
default_params = default_params()
// merge defaults with user params
merged_params = default_params + params

// help and version messages
help_or_version(merged_params, version)
final_params = check_params(merged_params)
// starting pipeline
pipeline_start_message(version, final_params)

// include processes
include { NANOPLOT; NANOSTATS_TRANSPOSE; COMBINE_NANOSTATS } from './modules/processes.nf' addParams(final_params)

workflow  {

	   reads_ch = channel
                          .fromPath( final_params.reads, checkIfExists: true )
                          .map { file -> tuple(file.simpleName, file) }

         NANOPLOT(reads_ch)

         NANOSTATS_TRANSPOSE(NANOPLOT.out.txt_ch)


         collected_nanostatistics_ch = NANOSTATS_TRANSPOSE.out.nanostats_ch.collect( sort: {a, b -> a[0].getBaseName() <=> b[0].getBaseName()} )

         COMBINE_NANOSTATS(collected_nanostatistics_ch, final_params.sequencing_date)
}

workflow.onComplete {
    complete_message(final_params, workflow, version)
}

workflow.onError {
    error_message(workflow)
}
