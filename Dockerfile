FROM quay.io/aptible/ubuntu:16.04

MAINTAINER Christopher Smith <christopher@onecodex.com>

RUN apt-get update \
  && apt-get install -y curl file g++ git locales make default-jre uuid-runtime python3 python3-dev python3-pip \
  && apt-get clean

RUN localedef -i en_US -f UTF-8 en_US.UTF-8 \
  && useradd -m -s /bin/bash unicycler \
  && echo 'unicycler ALL=(ALL) NOPASSWD:ALL' >>/etc/sudoers

USER unicycler

WORKDIR /home/unicycler

RUN git clone https://github.com/Linuxbrew/brew.git .linuxbrew

ENV PATH=/home/unicycler/.linuxbrew/bin:/home/unicycler/.linuxbrew/sbin:$PATH \
  SHELL=/bin/bash

RUN brew tap brewsci/science

RUN brew tap brewsci/bio

RUN brew install blast bowtie2 pilon racon samtools spades

RUN curl -O -L "https://github.com/rrwick/Unicycler/archive/v0.4.4.tar.gz"

RUN tar -xzvf v0.4.4.tar.gz

USER root

RUN cd Unicycler-0.4.4 && python3 setup.py install

USER unicycler

ENV TERM=xterm

ENTRYPOINT ["unicycler"]

CMD ["--help"]