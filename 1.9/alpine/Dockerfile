# vim:set ft=dockerfile:
FROM golang:alpine3.9 as build

ENV PACHCTL_VERSION 1.9.7-55a0b40eb00a5d33122a7f4db2670b48ffba9a94

ENV KUBECTL_VERSION v1.16.1

RUN ARCH="$(arch)" \
  && case "${ARCH##*-}" in \
    x86_64) ARCH='amd64';; \
    ppc64el) ARCH='ppc64le';; \
    s390x) ARCH='s390x';; \
    x86) ARCH='386';; \
    *) echo "unsupported architecture (${ARCH})"; exit 1 ;; \
  esac \
  && apk add --no-cache --virtual .build-deps \
    g++ \
    gcc \
    git \
    make \
  && go get -v github.com/laher/goxc \
  && go get -v -d github.com/pachyderm/pachyderm \
  && cd $GOPATH/src/github.com/pachyderm/pachyderm \
  && git checkout -q v${PACHCTL_VERSION} \
  && make VERSION_ADDITIONAL="" goxc-build \
  && cp $GOPATH/src/github.com/pachyderm/pachyderm/build/snapshot/linux_${ARCH}/pachctl /usr/local/bin \
  && wget https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/${ARCH}/kubectl -O /usr/local/bin/kubectl \
  && chmod +x /usr/local/bin/kubectl \
  && cd / \
  && rm -r $GOPATH/* \
  && rm -r ~/.cache \
  && apk del .build-deps

FROM alpine:3.9

RUN addgroup -g 1000 pachyderm \
  && adduser -u 1000 -G pachyderm -s /bin/sh -D pachyderm

COPY --from=build /usr/local/bin/pachctl /usr/local/bin
COPY --from=build /usr/local/bin/kubectl /usr/local/bin

USER pachyderm

CMD ["pachctl"]
