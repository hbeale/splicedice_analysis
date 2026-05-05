FROM python:3.8-slim

WORKDIR /opt

RUN apt-get update && apt-get install -y \
    git build-essential pkg-config libhts-dev samtools=1.16.1-1\
    && rm -rf /var/lib/apt/lists/*

ARG SHA1_splicedice="28875c0e1914b1544780497bf67cff93af69d89c"

RUN git clone --depth 2 https://github.com/BrooksLabUCSC/splicedice.git splicedice \
 && cd splicedice \
 && git reset --hard $SHA1_splicedice \
 && pip install --no-cache-dir . \
 && cd /opt

ARG SHA1_intronProspector="ba9a26fe752175136562b75abc1d293cc7384fd6"
RUN git clone --depth 2 \
      https://github.com/diekhans/intronProspector.git \
 && cd intronProspector \
 && git reset --hard $SHA1_intronProspector \
 && ./configure \
 && make -j$(nproc) \
 && make install \
 && cd /opt \
 && rm -rf intronProspector

RUN apt-get purge -y git build-essential pkg-config \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*
