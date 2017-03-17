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

From somewhere within the home directory of the user that will be running the server, you can create the repository, configure
the server, and then run the server:

```
singularity run /tmp/server.img init ${PWD}/example-data/GRCh37-subset.fa ${PWD}/example-data
sudo singularity run --writable /tmp/server.img config ./ 8000
mkdir -p /tmp/lock /tmp/log /tmp/run /tmp/log/apache2
singularity run /tmp/server.img serve
```

and from another terminal:
```
$ curl http://localhost:8000/ga4gh/ --silent | grep GA4GH
        <title>GA4GH reference server 0.3.7.dev0+ng19955c3.d20170317</title>
        <h2>GA4GH reference server 0.3.7.dev0+ng19955c3.d20170317</h2>
   Welcome to the GA4GH reference server landing page! This page describes
```
