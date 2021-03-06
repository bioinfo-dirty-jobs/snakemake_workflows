
from os.path import join, dirname
import glob

GENOMEDIR = os.path.dirname(genome_fasta)
BASENAME = genome
# define snpgenome_dir
if allele_hybrid == 'dual':
    SNPdir = "snp_genome/" + strains[0] + "_" + \
                    strains[1] + "_dual_hybrid.based_on_" + \
                    BASENAME + "_N-masked"
else:
    SNPdir = "snp_genome/" + strains[0] + "_" + "_N-masked"

def getref_fileList(dir):
    fl = glob.glob(dir + "/*.fa")
    flist = ','.join(fl)
    return(fl)


## Create masked genome
if allele_hybrid == 'dual':
    rule create_snpgenome:
        input:
            genome = GENOMEDIR
        output:
            genome1 = "snp_genome/" + strains[0] + '_SNP_filtering_report.txt',
            genome2 = "snp_genome/" + strains[1] + '_SNP_filtering_report.txt',
            snpgenome_dir = SNPdir,
            snpfile = snp_file
        params:
            strain1 = strains[0],
            strain2 = strains[1],
            SNPpath = os.path.abspath(VCFfile)
        log: "snp_genome/SNPsplit_createSNPgenome.log"
        shell:
            " ( [ -d snp_genome ] || mkdir -p snp_genome ) && cd snp_genome &&"
            " " + SNPsplit_path +"SNPsplit_genome_preparation"
            " --dual_hybrid --genome_build {BASENAME} "
            " --reference_genome {input.genome} --vcf_file {params.SNPpath}"
            " --strain {params.strain1} --strain2 {params.strain2}"
            "&& cd ../"
else:
    rule create_snpgenome:
        input:
            genome = GENOMEDIR
        output:
            genome1 = "snp_genome/" + strains[0] + '_SNP_filtering_report.txt',
            snpgenome_dir = SNPdir,
            snpfile = snp_file
        params:
            strain1 = strains[0]
        log: "snp_genome/SNPsplit_createSNPgenome.log"
        shell:
            " ( [ -d snp_genome ] || mkdir -p snp_genome ) && cd snp_genome &&"
            " " + SNPsplit_path +"SNPsplit_genome_preparation"
            " --genome_build {BASENAME} "
            " --reference_genome {input.genome} --vcf_file {input.snps}"
            " --strain {params.strain1}"
            "&& cd ../"

if mapping_prg == "STAR":
    rule star_index:
        input:
            snpgenome_dir = SNPdir
        output:
            star_index_allelic
        log:
            "snp_genome/star_Nmasked/star.index.log"
        threads:
            10
        params:
            gtf=genes_gtf
        shell:
            "/package/STAR-2.5.2b/bin/STAR"
            " --runThreadN {threads}"
            " --runMode genomeGenerate"
            " --genomeDir " + "snp_genome/star_Nmasked"
            " --genomeFastaFiles {input.snpgenome_dir}/*.fa"
            " --sjdbGTFfile {params.gtf}"
            " > {log} 2>&1"

elif mapping_prg == "Bowtie2":
    rule bowtie2_index:
        input:
            snpgenome_dir = SNPdir
        output:
            bowtie2_index_allelic
        log:
            "snp_genome/bowtie2_Nmasked/bowtie2.index.log"
        threads: 10
        params:
            filelist = getref_fileList(SNPdir),
            idxbase = "snp_genome/bowtie2_Nmasked/Genome"
        shell:
            "/package/bowtie2-2.3.2/bin/bowtie2-build"
            " --threads {threads}"
            " {params.filelist}"
            " {params.idxbase}"
            " > {log} 2>&1"
else:
    print("Only STAR and Bowtie2 are implemented for allele-specific mapping")
