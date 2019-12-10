FROM quay.io/aptible/ubuntu:16.04

MAINTAINER Christopher Smith <christopher@onecodex.com>

ENV TERM=xterm

WORKDIR /home/unicycler/

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
  wget --quiet \
  zlib1g-dev \
  && apt-get clean

RUN localedef -i en_US -f UTF-8 en_US.UTF-8 \
 && useradd -m -s /bin/bash unicycler \
 && echo 'unicycler ALL=(ALL) NOPASSWD:ALL' >>/etc/sudoers

# Install SPAdes

RUN wget --quiet "http://cab.spbu.ru/files/release3.12.0/SPAdes-3.12.0.tar.gz" \
 && tar -xzvf SPAdes-3.12.0.tar.gz \
 && cd SPAdes-3.12.0/ \
 && PREFIX=/usr/local/ ./spades_compile.sh \
 && cd .. \
 && rm -rf SPAdes-3.12.0

# Install racon
# (note: CPU-architecture dependent)
RUN wget --quiet "https://github.com/lbcb-sci/racon/releases/download/1.4.10/racon-v1.4.10.tar.gz" \
 && tar -zxvf racon-v1.4.10 \
 && cd racon-v1.4.10 \
 && mkdir -p build \
 && cd build \
 && cmake \
   -D CMAKE_BUILD_TYPE=Release \
   -D CMAKE_CXX_FLAGS="-march=haswell -mno-avx512pf -mno-avx512er -mno-avx512pf -mno-avx512er -mno-avx512cd -mno-avx512f" \
   .. \
 && make -j \
 && make install \
 && cd ../../ \
 && rm -r racon-v1.4.10

# Install samtools

RUN wget --quiet "https://github.com/samtools/samtools/releases/download/1.7/samtools-1.7.tar.bz2" \
 && tar -xjvf samtools-1.7.tar.bz2 \
 && cd /home/unicycler/samtools-1.7 \
 && ./configure --prefix=/usr/local --without-curses \
 && make \
 && make install \
 && cd .. \
 && rm -r samtools-1.7*

# Install bowtie2

RUN wget --quiet "https://github.com/BenLangmead/bowtie2/releases/download/v2.3.4.1/bowtie2-2.3.4.1-linux-x86_64.zip" \
 && unzip bowtie2-2.3.4.1-linux-x86_64.zip \
 && cd /home/unicycler/bowtie2-2.3.4.1-linux-x86_64 \
 && mv bowtie2* /usr/local/bin  \
 && cd .. \
 && rm -r bowtie2*

# Install Unicycler

RUN git clone https://github.com/rrwick/Unicycler.git \
 && cd /home/unicycler/Unicycler \
 && git checkout v0.4.7 \
 && python3 setup.py install \
 && cd .. \
 && rm -rf /home/unicycler/Unicycler

# Install Pilon

# add custom Pilon executable to $PATH so we can override the memory options
ADD pilon /usr/local/bin/pilon
RUN chmod +x /usr/local/bin/pilon

RUN wget --quiet "https://github.com/broadinstitute/pilon/releases/download/v1.22/pilon-1.22.jar" \
 && mkdir /usr/local/Unicycler \
 && mv pilon-1.22.jar /usr/local/Unicycler/

# Make a runnable container

ENTRYPOINT ["unicycler"]

CMD ["--help"]
