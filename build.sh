#!/usr/bin/env bash
set -Eeuo pipefail

basename="laurentgoderre/pachctl"

version=${1:-}

[ -z "${version}" ] && echo "ERROR: Version to build not specified" >&2 && exit 1

[ "$(ls -d */ | grep -o ${version})" != "${version}" ] && echo "ERROR: Version ${version} not found" >&2 && exit 2

ls -1 -d ${version}/* \
 | while read -r dir; do
   variant="$(basename "${dir}")"
   version=$(cat "${dir}/Dockerfile" | grep "ENV PACHCTL_VERSION" | cut -d ' ' -f3)
   tag="${basename}:${version}-${variant}"
   docker build -t "${tag}" "${dir}" && docker push "${tag}"
   if [ "${variant}" = "alpine" ]; then
     docker tag "${tag}" "${basename}:${version}" && docker push "${basename}:${version}"
   fi
 done
