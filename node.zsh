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
  
  package_str='Unknown name'
  if (( $+commands[jq] )); then
    package_str=$(jq -r '.name + "@" + .version' ${package} 2>/dev/null)
  fi
    
  echo -n "%{$c[green]$c_bold%}"
  echo -n "${package_str}"
  echo -n "%{$c[reset]%}"
}
