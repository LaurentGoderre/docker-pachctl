# vim:set ft=dockerfile:
FROM debian:stretch-slim

ENV PACHCTL_VERSION 1.8.2

ARG DEPS=" \
	ca-certificates \
	g++ \
	gcc \
	git \
	golang \
	libc6-dev \
	make"

RUN set -eux; \
	groupadd -r pachyderm --gid=1000 ; \
	useradd -r  -g pachyderm --uid 1000 --shell /bin/bash --create-home pachyderm;

RUN set -x \
	&& apt-get update && apt-get install -y --no-install-recommends \
		$DEPS

RUN mkdir /go \
	&& export GOPATH=/go \
	&& export TEMPPATH=$PATH \
	&& export PATH=/go/bin:/usr/local/go/bin:$PATH \
 	&& go get github.com/laher/goxc \
	&& go get -v github.com/pachyderm/pachyderm \
	&& cd /go/src/github.com/pachyderm/pachyderm
	#&& make deps


RUN make goxc-build \
	&& cp /go/src/github.com/pachyderm/pachyderm/build/snapshot/linux_amd64/pachctl /usr/local/bin \
	&& cd / \
	&& apt-get remove \
		$DEPS \
	&& rm -rf /go \
	&& export PATH=$TEMPPATH \
	&& unset TEMPPATH \
	&& unset GOPATH \

USER pachyderm

CMD ["pachctl"]
