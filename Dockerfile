FROM ubuntu:bionic

# ENV DEBIAN_FRONTEND noninteractive
# RUN apt-get update
# RUN apt-get install --no-install-recommends -y dh-autoreconf
# RUN apt-get install --no-install-recommends -y g++-6 gcc-6 python-pip
# RUN apt-get install --no-install-recommends -y python-setuptools
# RUN apt-get install --no-install-recommends -y python-dev
# RUN pip install pymavlink
# RUN apt-get install --no-install-recommends -y pkg-config
# RUN apt-get install --no-install-recommends -y systemd

RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install --no-install-recommends -y \
      dh-autoreconf pkg-config systemd \
      build-essential g++-6 gcc-6 \
      python-pip python-setuptools python-dev && \
    export CXX='g++-6' && \
    export CC='gcc-6' && \
    pip install wheel pymavlink && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD . /mavlink-router
RUN bash -c "\
        cd /mavlink-router; \
        export CXX='g++-6'; export CC='gcc-6'; \
        ./autogen.sh && ./configure CFLAGS='-g -O2' \
            --disable-systemd \
            --sysconfdir=/etc \
            --localstatedir=/var \
            --libdir=/usr/lib64 \
	          --prefix=/usr && \
        make && \
        make install"

ADD examples/config-docker.sample /etc/mavlink-router/main.conf

CMD ["mavlink-routerd"]