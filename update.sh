#!/usr/bin/env bash
set -Eeuo pipefail

cd "$(dirname "$BASH_SOURCE")"

versions=( "$@" )
if [ ${#versions[@]} -eq 0 ]; then
  versions=( */ )
fi
versions=( "${versions[@]%/}" )
variants=(alpine debian)

# sort version numbers with highest last (so it goes first in .travis.yml)
IFS=$'\n'; versions=( $(echo "${versions[*]}" | sort -V) ); unset IFS

defaultDebianSuite='stretch-slim'
declare -A debianSuite=()
defaultAlpineVersion='3.9'
declare -A alpineVersion=()

travisEnv=

for version in "${versions[@]}"; do
  tag="${debianSuite["$version"]:-$defaultDebianSuite}"
  suite="${tag%%-slim}"

  #versionList="$(echo "${suitePackageList["$suite"]}"; curl -fsSL "${packagesBase}/${suite}-pgdg/${version}/binary-amd64/Packages.bz2" | bunzip2)"
	#fullVersion="$(echo "$versionList" | awk -F ': ' '$1 == "Package" { pkg = $2 } $1 == "Version" && pkg == "postgresql-'"$version"'" { print $2; exit }' || true)"
  # TODO: Add logic to find this info
  fullVersion="1.8.2"
	majorVersion="${version%%.*}"

  echo "$version: $fullVersion"

  for variant in "${variants[@]}"; do
		if [ ! -d "$version/$variant" ]; then
			continue
    fi

    sed -e 's/%%PACHCTL_VERSION%%/'"$fullVersion"'/g' \
      -e 's/%%DEBIAN_TAG%%/'"$tag"'/g' \
			-e 's/%%ALPINE-VERSION%%/'"${alpineVersion[$version]:-$defaultAlpineVersion}"'/g' \
      "Dockerfile-$variant.template" > "$version/$variant/Dockerfile"

      travisEnv="\n  - VERSION=$version VARIANT=$variant$travisEnv"
  done
done

travis="$(awk -v 'RS=\n' '!/- VERSION/$1 == "env:" { $0 = "env:'"$travisEnv"'" } { printf "%s%s", $0, RS }' .travis.yml)"
echo "$travis" > .travis.yml
