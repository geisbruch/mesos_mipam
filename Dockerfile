FROM ubuntu:15.04 
#Install Java
RUN \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get install -y build-essential && \
  apt-get install -y software-properties-common && \
  apt-get install -y byobu curl git htop man unzip vim wget && \
  rm -rf /var/lib/apt/lists/*

RUN \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java8-installer && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer

#Install mesos

RUN apt-get update -q --fix-missing
RUN apt-get -qy install software-properties-common # (for add-apt-repository)
RUN add-apt-repository ppa:george-edison55/cmake-3.x
RUN apt-get update -q
RUN apt-cache policy cmake
RUN apt-get -qy --force-yes install \
  g++					  \
  build-essential                         \
  autoconf                                \
  automake                                \
  cmake					  \
  ca-certificates                         \
  gdb                                     \
  wget                                    \
  git-core                                \
  libcurl4-nss-dev                        \
  libsasl2-dev                            \
  libtool                                 \
  libsvn-dev                              \
  libapr1-dev                             \
  libgoogle-glog-dev                      \
  libboost-dev                            \
  protobuf-compiler                       \
  libprotobuf-dev                         \
  make                                    \
  python                                  \
  python2.7                               \
  libpython-dev                           \
  python-dev                              \
  python-protobuf                         \
  python-setuptools                       \
  heimdal-clients                         \
  libsasl2-modules-gssapi-heimdal         \
  unzip                                   

# Install the picojson headers
RUN wget https://raw.githubusercontent.com/kazuho/picojson/v1.3.0/picojson.h -O /usr/local/include/picojson.h

# Prepare to build Mesos
RUN mkdir -p /mesos
RUN mkdir -p /tmp
RUN mkdir -p /usr/share/java/
RUN wget http://search.maven.org/remotecontent?filepath=com/google/protobuf/protobuf-java/2.5.0/protobuf-java-2.5.0.jar -O protobuf.jar
RUN mv protobuf.jar /usr/share/java/

WORKDIR /mesos

RUN git clone git://git.apache.org/mesos.git /mesos
RUN git checkout master
RUN git log -n 1
# Bootstrap
RUN ./bootstrap

# Configure
RUN mkdir build && cd build && ../configure --disable-optimize --without-included-zookeeper --with-glog=/usr/local --with-protobuf=/usr/local --with-boost=/usr/local --prefix=/usr/local
 

# Build Mesos
RUN cd build && make -j 2 install

# Install python eggs
RUN easy_install /mesos/build/src/python/dist/mesos.interface-*.egg
RUN easy_install /mesos/build/src/python/dist/mesos.native-*.egg


WORKDIR /mipam
