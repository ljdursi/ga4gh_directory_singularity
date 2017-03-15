# ga4gh_directory_singularity

This is a simple [Singularity](http://singularity.lbl.gov) image for starting up a GA4GH server based on a directory of BAMs and VCFs.
Build the image with, on an ubuntu machine:

```
sudo singularity create --size 2048 /tmp/server.img
sudo singularity bootstrap /tmp/server.img ubuntu16-ga4gh-server-0.3.6.def
```

Take for example the [GA4GH example data](https://github.com/ga4gh/server/releases/download/data/ga4gh-example-data_4.6.tar) with
indexes removed:

```
$ ls
GRCh37-subset.fa    HG00096.bam        HG00533.bam        HG00534.bam        chr1.vcf.gz        chr2.vcf.gz        chr3.vcf.gz
```


One can build the docker from this repo via `docker build -t ga4gh_directory .` or just pull the 
prebuilt image with `docker pull quay.io/ljdursi/ga4gh_directory`.

In the data directory, you can then create the necessary indices and the `registry.db` file as so: (Note: the scripts currently
assume that the mounted data directory is _always_ `/data`)

```
$ docker run -v ${PWD}:/data ga4gh_directory init /data/GRCh37-subset.fa /data/
[bgzip] No such file or directory: /data//*.vcf
Verifying ReferenceSet testref @ /data/GRCh37-subset.fa.gz
    Reading 1000 bases from 1
Verifying Dataset test
    Verifying ReadGroupSet HG00096 @ /data/HG00096.bam
        Read 10 alignments from SRR062634
        Read 10 alignments from SRR062635
        Read 10 alignments from SRR062641
    Verifying ReadGroupSet HG00533 @ /data/HG00533.bam
        Read 10 alignments from ERR020237
    Verifying ReadGroupSet HG00534 @ /data/HG00534.bam
        Read 10 alignments from ERR020238
    Verifying VariantSet testvars
        Read 10 variants from reference 1 @ /data/chr1.vcf.gz
        Read 10 variants from reference 3 @ /data/chr3.vcf.gz
        Read 10 variants from reference 2 @ /data/chr2.vcf.gz

$ ls
GRCh37-subset.fa.gz     HG00096.bam      HG00533.bam.bai   chr1.vcf.gz        chr2.vcf.gz.tbi     registry.db
GRCh37-subset.fa.gz.fai HG00096.bam.bai  HG00534.bam       chr1.vcf.gz.tbi    chr3.vcf.gz
GRCh37-subset.fa.gz.gzi HG00533.bam      HG00534.bam.bai   chr2.vcf.gz        chr3.vcf.gz.tbi
```

From this same directory, we can now start up a ga4gh server, as well as serving the files themselves:

```
$ docker run -d -v ${PWD}:/data -p 8000:80 ga4gh_directory serve
288fe71273c65d746e506c5a9ef06a29964535043adf3a4fa8550f05556a7c0a

```

and from another terminal in another directory:
```
$ curl http://localhost:8000/ga4gh/ --silent | grep GA4GH
        <title>GA4GH reference server 0.3.5</title>
        <h2>GA4GH reference server 0.3.5</h2>
    Welcome to the GA4GH reference server landing page! This page describes

$ wget -nv http://localhost:8000/chr3.vcf.gz
2017-01-25 00:42:15 URL:http://localhost:8000/chr3.vcf.gz [26967/26967] -> "chr3.vcf.gz" [1]
```
