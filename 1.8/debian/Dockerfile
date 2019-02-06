# vim:set ft=dockerfile:
FROM golang:stretch as build

ENV PACHCTL_VERSION 1.8.3

RUN set -x \
	&& ARCH= && dpkgArch="$(dpkg --print-architecture)" \
  && case "${dpkgArch##*-}" in \
    amd64) ARCH='amd64';; \
    ppc64el) ARCH='ppc64le';; \
    s390x) ARCH='s390x';; \
    arm64) ARCH='arm64';; \
    armhf) ARCH='armv7l';; \
    i386) ARCH='x86';; \
    *) echo "unsupported architecture"; exit 1 ;; \
	esac \
	&& go get -v github.com/laher/goxc \
	&& go get -v github.com/pachyderm/pachyderm \
	&& cd $GOPATH/src/github.com/pachyderm/pachyderm \
	&& make goxc-build \
	&& cp $GOPATH/src/github.com/pachyderm/pachyderm/build/snapshot/linux_${ARCH}/pachctl /usr/local/bin \
	&& cd / \
	&& rm -rf $GOPATH/* \
	&& rm -r ~/.cache

FROM debian:stretch-slim

RUN groupadd --gid 1000 pachyderm \
	&& useradd --uid 1000 --gid pachyderm --shell /bin/bash --create-home pachyderm

COPY --from=build /usr/local/bin/pachctl /usr/local/bin

USER pachyderm

CMD ["pachctl"]
