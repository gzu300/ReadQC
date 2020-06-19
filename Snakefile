configfile: 'config.yaml'

rule target:
    input:
        expand('output/qc/{group}_rep{rep}.html',
            group = config['group'],
            rep   = config['rep']
            ),
        expand('output/fastqc/{group}_rep{rep}_read{read}_fastqc.html',
            group = config['group'],
            rep   = config['rep'],
            read  = config['read']
            ),
        'output/multiqc/multiqc_report.html'

rule fastp:
    input: 
        expand('input/{{group}}_Rep{{rep}}_read{read}.fastq.gz', 
            read = config['read']
            )
    output:
        'output/qc/{group}_rep{rep}.html',
        'output/qc/{group}_rep{rep}.json'
    threads: 2
    log:
        'log/fastp/{group}_{rep}.log'
    conda:
        'env/fastp.yaml'
    shell:
        '''
        fastp -i {input[0]} -I {input[1]} -h {output[0]} -j {output[1]}
        '''

rule fastqc:
    input:
        'input/{group}_Rep{rep}_read{read}.fastq.gz' 
    output:
        'output/fastqc/{group}_rep{rep}_read{read}_fastqc.html'
    threads: 2
    params:
        out_path = 'output/fastqc'
    log:
        'log/fastqc/{group}_{rep}_{read}.log'
    conda:
        'env/fastp.yaml'
    shell:
        '''
        fastqc {input} -o {params.out_path}
        '''

rule multiqc:
    input:
        expand('output/fastqc/{group}_rep{rep}_read{read}_fastqc.html',
            group = config['group'],
            rep   = config['rep'],
            read  = config['read']
        )
    output:
        'output/multiqc/multiqc_report.html'
    log:
        'log/multiqc/multiqc.log'
    conda:
        'env/multiqc.yaml'
    params:
        in_dir = 'output/fastqc',
        out_dir = 'output/multiqc'
    shell:
        '''
        multiqc -o {params.out_dir} {params.in_dir}
        '''