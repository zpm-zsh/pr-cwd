#!/usr/bin/env zsh

_pr_cwd_is_rust_dir(){
  rpath=${1:P}
  
  if [[ -f "${rpath}/Cargo.toml" ]] ; then
    return 0
  fi
  
  return 1
}

_pr_cwd_get_rust_package(){
  rpath=${1:P}
  
  
  local name=$(
    cargo metadata --no-deps --format-version 1 --manifest-path=${rpath}/Cargo.toml \
    | jq --raw-output '.packages[0] | [ .name ] | join(" ")'
  )
  
  local version=$(
    cargo metadata --no-deps --format-version 1 --manifest-path=${rpath}/Cargo.toml \
    | jq --raw-output '.packages[0] | [ .version ] | join(" ")'
  )
  
  echo -n "%{$c[magenta]$bold%}"
  echo -n "${name}#${version}"
  echo -n "%{$c[reset]%}"
  
}

