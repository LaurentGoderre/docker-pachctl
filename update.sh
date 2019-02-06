#!/usr/bin/env bash
set -Eeuo pipefail

source functions.sh

if [ ! -f "semver" ]; then
  curl -Os "https://raw.githubusercontent.com/fsaintjacques/semver-tool/2.1.0/src/semver"
  chmod a+x semver
fi

cd "$(dirname "${BASH_SOURCE}")"

versions=( "${@}" )
if [ ${#versions[@]} -eq 0 ]; then
  versions=( */ )
fi
versions=( "${versions[@]%/}" )
variants=(alpine debian)

# sort version numbers with highest last (so it goes first in .travis.yml)
IFS=$'\n'; versions=( $(echo "${versions[*]}" | sort -V) ); unset IFS

defaultDebianSuite='stretch'
declare -A debianSuite=()
defaultAlpineVersion='3.9'
declare -A alpineVersion=()

travisEnv=

for version in "${versions[@]}"; do
  tag="${debianSuite["${version}"]:-${defaultDebianSuite}}"
  suite="${tag%%-slim}"

  fullVersion="$(get_full_version ${version})"
	majorVersion="${version%%.*}"

  echo "${version}: ${fullVersion}"

  for variant in "${variants[@]}"; do
		if [ ! -d "${version}/${variant}" ]; then
			continue
    fi

    sed -e 's/%%PACHCTL_VERSION%%/'"${fullVersion}"'/g' \
      -e 's/%%DEBIAN_TAG%%/'"${tag}"'/g' \
			-e 's/%%ALPINE-VERSION%%/'"${alpineVersion[${version}]:-${defaultAlpineVersion}}"'/g' \
      "Dockerfile-${variant}.template" > "${version}/${variant}/Dockerfile"

      travisEnv="\n  - VERSION=${version} VARIANT=${variant}${travisEnv}"
  done
done

travis="$(awk '!/- VERSION/' .travis.yml | awk -v 'RS=\n' '$1 == "env:" { $0 = "env:'"${travisEnv}"'" } { printf "%s%s", $0, RS }')"
echo "${travis}" > .travis.yml
