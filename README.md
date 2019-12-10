# docker-unicycler [![Docker Repository on Quay](https://quay.io/repository/refgenomics/docker-unicycler/status "Docker Repository on Quay")](https://quay.io/repository/refgenomics/docker-unicycler)

A Docker image for [rrwick/unicycler](https://github.com/rrwick/Unicycler).
Releases for this repo, and the corresponding image tags, follow official
releases for Unicycler.

**Note**: We purposefully compile Racon without AVX-512 instructions as this
will not run on certain ec2 instances.

## Usage

`docker run --rm unicycler:v0.4.4`
