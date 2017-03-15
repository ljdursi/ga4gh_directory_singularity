#!/bin/bash

readonly REPO=${PWD}/registry.db

function usage {
    >&2 echo "$0: create a GA4GH repo given a reference, and directory of BAMs and VCFs"
    >&2 echo "Will index BAMs and VCFs if not already indexed."
    >&2 echo "Usage: $0 /path/to/reference.fa /path/to/data/directory"
}

# given a reference fasta file, bgzip and index if necessary
function faidx {
    local reference=$1
    if [[ ! -f "$reference" ]]
    then
        return 1
    fi

    base=$( basename "$reference" )
    extension="${base##*.}"
    reference_gz="$reference"

    # bgzip if necessary
    if [[ "$extension" == "gz" ]] || [[ -f "$reference.gz" ]]
    then
        :
    else
        bgzip -fi "$reference"
        reference_gz="$reference".gz
    fi
    # faidx if necessary
    if [[ ! -f "$reference_gz".fa ]] 
    then
        samtools faidx "$reference_gz"
    fi
}

# bai-index a directory full of BAMs if nencessary
function bamidx {
    local dir=$1
    if [[ -d ${dir} ]]
    then
        for bam in "${dir}"/*.bam
        do
            if [[ ! -f "$bam" ]]
            then
                continue
            fi
            if [[ ! -f "${bam}.bai" ]]
            then 
                samtools index "${bam}"
            fi
        done
    fi
}

# tabix a directory of VCFs if necessary
function vcfidx {
    local dir=$1
    if [[ -d "$dir" ]]
    then
        for vcf in "${dir}"/*.vcf
        do
            if [[ ! -f "${vcf}" ]]
            then
                continue
            fi
            if [[ ! -f "${vcf}.gz" ]]
            then 
                bgzip "${vcf}"
            fi
        done
        for vcfgz in "${dir}"/*.vcf.gz
        do
            if [[ ! -f "${vcfgz}" ]]
            then
                continue
            fi
            if [[ ! -f "${vcfgz}.tbi" ]]
            then 
                tabix -p vcf "${vcfgz}"
            fi
        done
    fi
}


function create_repo {
    local reference=$1
    local datadir=$2

    if [[ ! -f "$reference" ]]
    then
        >&2 echo "Reference file $reference not found."
        usage
        return 1
    fi
    if [[ ! -d "$datadir" ]]
    then
        >&2 echo "Data directroy $datadir  not found."
        usage
        return 1
    fi

    if [[ -f "$REPO" ]] 
    then
        rm -f "$REPO"
    fi

    readonly DATASETNAME="test"
    readonly REFERENCENAME="testref"
    readonly VARIANTSNAME="testvars"

    ga4gh_repo init "$REPO"
    ga4gh_repo add-dataset "$REPO" "$DATASETNAME" --description "Test dataset"
    ga4gh_repo add-referenceset "$REPO" "$reference" -d "Test set reference" --name "$REFERENCENAME"
    ga4gh_repo add-variantset "$REPO" "$DATASETNAME" "$datadir" --name "$VARIANTSNAME" --referenceSetName "$REFERENCENAME"

    for bamfile in "$datadir"/*.bam
    do
        if [[ ! -f "${bamfile}" ]]
        then
            continue
        fi
        filebase=$( basename "$bamfile" | cut -f 1 -d . )
        ga4gh_repo add-readgroupset "$REPO" "$DATASETNAME" "$bamfile" --name "$filebase" --referenceSetName "$REFERENCENAME" 
    done
}

function main {
    local reference=$1
    local datadir=$2

    if [[ ! -f "$reference" ]] || [[ ! -d "$datadir" ]]
    then
        usage
        echo " reference file $reference not found."
        exit 1
    fi
    if [[ ! -d "$datadir" ]]
    then
        usage
        echo " data directory $datadir  not found."
        exit 1
    fi

    faidx "$reference"
    if [[ ! -f "$reference" ]] && [[ -f "$reference".gz ]]
    then
        reference="$reference".gz
    fi
    bamidx "$datadir"
    vcfidx "$datadir"
    create_repo "$reference" "$datadir"
    ga4gh_repo verify "$REPO"
}

main "$@"
