### Picard CollectAlignmentSummaryMetrics ######################################

rule CollectAlignmentSummaryMetrics:
    input:
        "filtered_bam/{sample}.filtered.bam"
    output:
        "Picard_qc/AlignmentSummaryMetrics/{sample}.filtered.alignment_summary_metrics.txt"
    params:
        genome = genome_fasta  # reference genome FASTA sequence
    log:
        "Picard_qc/logs/CollectAlignmentSummaryMetrics.{sample}.filtered.log"
    benchmark:
        "Picard_qc/.benchmark/CollectAlignmentSummaryMetrics.{sample}.filtered.benchmark"
    threads: 2 # Java performs parallel garbage collection
    shell:
        "java -Xmx4g -jar "+picard_path+"picard.jar CollectAlignmentSummaryMetrics "
            "REFERENCE_SEQUENCE={params.genome} "
            "INPUT={input} OUTPUT={output} "
            "VALIDATION_STRINGENCY=LENIENT "
            "&> {log}"


### Picard CollectInsertSizeMetrics ############################################

if paired:
    rule CollectInsertSizeMetrics:
        input:
            "filtered_bam/{sample}.filtered.bam"
        output:
            txt = "Picard_qc/InsertSizeMetrics/{sample}.filtered.insert_size_metrics.txt",
            pdf = "Picard_qc/InsertSizeMetrics/{sample}.filtered.insert_size_histogram.pdf"
        log:
            "Picard_qc/logs/CollectInsertSizeMetrics.{sample}.filtered.log"
        benchmark:
            "Picard_qc/.benchmark/CollectInsertSizeMetrics.{sample}.filtered.benchmark"
        threads: 2 # Java performs parallel garbage collection
        shell:
            "export PATH="+R_path+":$PATH && "
            "java -Xmx4g -jar "+picard_path+"picard.jar CollectInsertSizeMetrics "
                "HISTOGRAM_FILE={output.pdf} "
                "INPUT={input} "
                "OUTPUT={output.txt} "
                "VALIDATION_STRINGENCY=LENIENT "
                "&> {log} "
