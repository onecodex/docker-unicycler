FROM quay.io/aptible/ubuntu:16.04

MAINTAINER Christopher Smith <christopher@onecodex.com>

RUN apt-get update \
  && apt-get install -y \
  build-essential \
  cmake \
  curl \
  file \
  g++ \
  git \
  libbz2-dev \
  liblzma-dev \
  locales \
  make \
  ncbi-blast+ \
  default-jre \
  uuid-runtime \
  python3 \
  python3-dev \
  python3-pip \
  unzip \
  wget \
  zlib1g-dev \
  && apt-get clean

RUN localedef -i en_US -f UTF-8 en_US.UTF-8 \
  && useradd -m -s /bin/bash unicycler \
  && echo 'unicycler ALL=(ALL) NOPASSWD:ALL' >>/etc/sudoers

WORKDIR /home/unicycler

# Install SPAdes

RUN wget "http://cab.spbu.ru/files/release3.11.1/SPAdes-3.11.1.tar.gz"

RUN tar -xzvf SPAdes-3.11.1.tar.gz

RUN mkdir -p /home/unicycler/SPAdes-3.11.1-Linux/src/build

WORKDIR /home/unicycler/SPAdes-3.11.1/src/build

RUN cmake ..

RUN make install

WORKDIR /home/unicycler

RUN rm -r SPAdes-3.11.1-Linux*

# Install racon

RUN git clone --recursive https://github.com/isovic/racon.git racon

RUN mkdir -p /home/unicycler/racon/build

WORKDIR /home/unicycler/racon/build

RUN cmake -DCMAKE_BUILD_TYPE=Release ..

RUN make && make install

WORKDIR /home/unicycler

RUN rm -r racon*

# Install samtools

RUN wget "https://github.com/samtools/samtools/releases/download/1.7/samtools-1.7.tar.bz2"

RUN tar -xjvf samtools-1.7.tar.bz2

WORKDIR /home/unicycler/samtools-1.7

RUN ./configure --prefix=/usr/local --without-curses

RUN make && make install

WORKDIR /home/unicycler

RUN rm -r samtools-1.7*

# Install bowtie2

RUN wget "https://github.com/BenLangmead/bowtie2/releases/download/v2.3.4.1/bowtie2-2.3.4.1-linux-x86_64.zip"

RUN unzip bowtie2-2.3.4.1-linux-x86_64.zip

WORKDIR /home/unicycler/bowtie2-2.3.4.1-linux-x86_64

RUN mv bowtie2* /usr/local/bin 

WORKDIR /home/unicycler

RUN rm -r bowtie2*

# Install Unicycler

RUN git clone https://github.com/rrwick/Unicycler.git

WORKDIR /home/unicycler/Unicycler

ENV TERM=xterm

RUN python3 setup.py install

WORKDIR /home/unicycler

RUN rm -r Unicycler

# Install Pilon

RUN wget "https://github.com/broadinstitute/pilon/releases/download/v1.22/pilon-1.22.jar"

RUN mkdir /usr/local/Unicycler

RUN mv pilon-1.22.jar /usr/local/Unicycler/

ADD pilon /usr/local/bin/pilon

RUN chmod +x /usr/local/bin/pilon

# Make a runnable container

ENTRYPOINT ["unicycler"]

CMD ["--help"]