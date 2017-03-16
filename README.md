# ga4gh_directory_singularity

This is a simple [Singularity](http://singularity.lbl.gov) image for starting up a GA4GH server based on a directory of BAMs and VCFs.
Build the image with, on an ubuntu machine:

```
sudo singularity create --size 2048 /tmp/server.img && \
    sudo singularity bootstrap /tmp/server.img ubuntu16-ga4gh-server-0.3.6.def
```

Take for example the [GA4GH example data](https://github.com/ga4gh/server/releases/download/data/ga4gh-example-data_4.6.tar) with
indexes removed:

```
$ ls example-data
GRCh37-subset.fa    chr1.vcf.gz        chr2.vcf.gz        chr3.vcf.gz
```

In the data directory, you can then create the necessary indices and the `registry.db` file as so: (Note: the scripts currently
assume that the mounted data directory is _always_ `/data`)

```
singularity run /tmp/server.img init example-data/GRCh37-subset.fa example-data/
```
```
Verifying ReferenceSet testref @ /home/ubuntu/example-data/GRCh37-subset.fa.gz
    Reading 1000 bases from 1
Verifying Dataset test
    Verifying VariantSet testvars
        Read 10 variants from reference 1 @ /home/ubuntu/example-data/chr1.vcf.gz
        Read 10 variants from reference 3 @ /home/ubuntu/example-data/chr3.vcf.gz
        Read 10 variants from reference 2 @ /home/ubuntu/example-data/chr2.vcf.gz

$ ls example-data/
chr1.vcf.gz  chr1.vcf.gz.tbi  chr2.vcf.gz  chr2.vcf.gz.tbi  chr3.vcf.gz  chr3.vcf.gz.tbi  GRCh37-subset.fa.gz  GRCh37-subset.fa.gz.fai  GRCh37-subset.fa.gz.gzi
```

From this same directory, we can now start up a ga4gh server, as well as serving the files themselves:

```
sudo singularity run --writable /tmp/server.img serve . 8000
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
