FROM debian:stretch as build

# Install ProtoBuf and gRPC manually, because grpc/cxx image is not updated.
# https://github.com/grpc/grpc-docker-library/blob/8c0fa91c/1.21.0/cxx/Dockerfile
# https://github.com/grpc/grpc-docker-library/issues/55
ARG GRPC_RELEASE_TAG=v1.24.x
RUN apt-get update && \
    apt-get install -y build-essential autoconf libtool git pkg-config curl automake libtool curl make g++ unzip && \
    apt-get clean && \
    git clone -b ${GRPC_RELEASE_TAG} https://github.com/grpc/grpc /var/local/git/grpc && \
    cd /var/local/git/grpc && \
    git submodule update --init && \
    cd third_party/protobuf && \
    git submodule update --init && \
    ./autogen.sh && ./configure --enable-shared && \
    make -j$(nproc) && make -j$(nproc) check && make install && make clean && ldconfig && \
    cd /var/local/git/grpc && \
    make -j$(nproc) && make install && make clean && ldconfig && \
    rm -rf /var/local/git/grpc

# Install MeCab
RUN apt-get update && \
    apt-get install -y mecab libmecab-dev && \
    apt-get clean

# Install mecab-ipadic-NEologd
RUN apt-get update && \
    apt-get -y install git curl make file sudo && \
    apt-get clean && \
    git clone --depth 1 https://github.com/neologd/mecab-ipadic-neologd.git && \
    echo yes | mecab-ipadic-neologd/bin/install-mecab-ipadic-neologd -n && \
    rm -rf mecab-ipadic-neologd

# Build MeCab Server
ADD . /build
RUN cd /build && make clean && make

FROM debian:stretch as runtime

RUN apt-get update && \
    apt-get install -y libmecab-dev && \
    apt-get clean

COPY --from=build /usr/local/lib/*.so* /usr/local/lib/
COPY --from=build /build/mecab_server /usr/local/bin/
ENV LD_LIBRARY_PATH /usr/local/lib

COPY --from=build /usr/lib/x86_64-linux-gnu/mecab/dic /usr/lib/x86_64-linux-gnu/mecab/dic
ENV MECAB_OPTS '-d /usr/lib/x86_64-linux-gnu/mecab/dic/mecab-ipadic-neologd'

CMD ["sh", "-c", "/usr/local/bin/mecab_server"]