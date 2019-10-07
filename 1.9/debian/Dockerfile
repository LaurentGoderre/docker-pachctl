# vim:set ft=dockerfile:
FROM golang:stretch as build

ENV PACHCTL_VERSION 1.9.4-abbd633e9a33877386dafd891971d6abade0ad97

ENV KUBECTL_VERSION v1.16.1

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
  && go get -v -d github.com/pachyderm/pachyderm \
  && cd $GOPATH/src/github.com/pachyderm/pachyderm \
  && git checkout -q v${PACHCTL_VERSION} \
  && make VERSION_ADDITIONAL="" goxc-build \
  && cp $GOPATH/src/github.com/pachyderm/pachyderm/build/snapshot/linux_${ARCH}/pachctl /usr/local/bin \
  && curl -L https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/${ARCH}/kubectl -o /usr/local/bin/kubectl \
  && chmod +x /usr/local/bin/kubectl \
  && cd / \
  && rm -rf $GOPATH/* \
  && rm -r ~/.cache

FROM debian:stretch-slim

RUN groupadd --gid 1000 pachyderm \
  && useradd --uid 1000 --gid pachyderm --shell /bin/bash --create-home pachyderm

COPY --from=build /usr/local/bin/pachctl /usr/local/bin
COPY --from=build /usr/local/bin/kubectl /usr/local/bin

USER pachyderm

CMD ["pachctl"]
