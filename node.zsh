#!/usr/bin/env zsh

_pr_cwd_is_node_dir(){
  rpath=${1:P}
  
  if [[ -f "${rpath}/package.json" ]] ; then
    return 0
  fi
  
  return 1
}

_pr_cwd_get_node_package(){
  rpath=${1:P}
  
  package="${rpath}/package.json"
  
  package_name='Unknown name'
  if command -v jq >/dev/null; then
    package_name=$(jq -r '.name' ${package} 2>/dev/null)
  fi
  
  package_version='Unknown version'
  if command -v jq >/dev/null; then
    package_version=$(jq -r '.version' ${package} 2>/dev/null)
  fi
  
  echo -n "%{$c[green]$c_bold%}"
  echo -n "${package_name}@${package_version}"
  echo -n "%{$c[reset]%}"
  
}
