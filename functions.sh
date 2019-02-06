#!/usr/bin/env bash
gh_versions=

get_full_version() {
  local base_version
  base_version="${1}"
  shift
  if [ -z "${gh_versions}" ]; then
    gh_versions="$(curl -s https://api.github.com/repos/pachyderm/pachyderm/tags?per_page=100 \
      | jq -cr '.[] | .name' | sed -e 's/\-/+/g' | sed -e 's/rc/\-rc/g')"
  fi

  IFS=' ' read -ra versions_match <<< "$(printf %"s\n" ${gh_versions} | tac | grep v$base_version | sed -e 's/[vV]//g' | tr '\n' ' ')"
  if [ ${#versions_match[@]} -gt 0 ]; then
    full_version=
    for version in "${versions_match[@]}"; do
      if [ -z "${full_version}" ] || [ $(./semver compare "${version}" "${full_version}" 2> /dev/null || echo -1) -eq 1 ]; then
        full_version="${version}"
      fi
    done

    echo "${full_version}"
  fi
}
