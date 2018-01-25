FROM centos:7

# Install dependencies
RUN yum update -y && yum install -y epel-release && yum install -y libaio-devel leveldb-devel snappy-devel gcc-c++ make libcap-devel libseccomp-devel git golang jq which

# Build stenographer
ENV GOPATH=/go
RUN go get github.com/google/stenographer

# Build stenotype
WORKDIR /go/src/github.com/google/stenographer
RUN make -C stenotype

# Create user
RUN adduser --system --no-create-home stenographer

# Configuration directory
RUN mkdir /etc/stenographer

# Install example config
RUN install ./configs/steno.conf /etc/stenographer/config

# Install executables
RUN install -t /usr/bin stenotype/stenotype
RUN install -t /usr/bin stenoread
RUN install -t /usr/bin stenocurl
RUN install -t /usr/bin stenokeys.sh

RUN yum install -y openssl
ENV PATH=$PATH:$GOPATH/bin

CMD stenokeys.sh stenographer stenographer && stenographer -syslog=false
