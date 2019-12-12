FROM ubuntu:19.04

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
  racon \
  && apt-get clean

RUN localedef -i en_US -f UTF-8 en_US.UTF-8 \
 && useradd -m -s /bin/bash unicycler \
 && echo 'unicycler ALL=(ALL) NOPASSWD:ALL' >>/etc/sudoers

# Install SPAdes

RUN wget --quiet "https://github.com/ablab/spades/releases/download/v3.13.1/SPAdes-3.13.1-Linux.tar.gz" \
  && tar -zxf SPAdes-3.13.1-Linux.tar.gz \
  && ls SPAdes-3.13.1-Linux \
  && mv SPAdes-3.13.1-Linux/bin/* /usr/local/bin/ \
  && mv SPAdes-3.13.1-Linux/share/* /usr/local/share/ \
  && rm -rf SPAdes-3.13.1-Linux/

# Install samtools

RUN wget --quiet "https://github.com/samtools/samtools/releases/download/1.10/samtools-1.10.tar.bz2" \
 && tar -xjf samtools-1.10.tar.bz2 \
 && cd /home/unicycler/samtools-1.10 \
 && ./configure --prefix=/usr/local --without-curses \
 && make \
 && make install \
 && cd .. \
 && rm -r samtools-1.10*

# Install bowtie2

RUN wget --quiet "https://github.com/BenLangmead/bowtie2/releases/download/v2.3.5.1/bowtie2-2.3.5.1-linux-x86_64.zip" \
 && unzip bowtie2-2.3.5.1-linux-x86_64.zip \
 && cd /home/unicycler/bowtie2-2.3.5.1-linux-x86_64 \
 && mv bowtie2* /usr/local/bin  \
 && cd .. \
 && rm -r bowtie2*

# Install Unicycler (this actually installs 4.8)
# TODO: switch back to official repo once Racon bug is fixed
RUN git clone https://github.com/onecodex/Unicycler.git \
 && cd /home/unicycler/Unicycler \
 && git checkout audy-ensure-racon-ran-at-least-once \
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