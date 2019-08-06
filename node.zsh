#!/usr/bin/env zsh

if [[ $CLICOLOR = 1 ]]; then
  _pr_cwd_node_icon="%{$c[green]$c_dim%}⬢%{$c_reset%} "
else
  _pr_cwd_node_icon="⬢ "
fi

_pr_cwd_is_node_dir(){
  rpath=${1:P}
  
  if [[ -f "${rpath}/package.json" ]] ; then
    return 0
  fi
  
  return 1
}


_pr_cwd_get_node_package(){
  rpath=${1:P}
  
  package=$(is-recursive-exist package.json)
  
  if command -v jq >/dev/null; then
    package_name=$(jq -r '.name' ${package} 2>/dev/null)
  elif command -v python >/dev/null; then
    package_name=$(python -c "import json; print(json.load(open('"${package}"'))['name'])" 2>/dev/null)
  elif command -v node >/dev/null; then
    package_name=$(node -p "require('"${package}"').name" 2> /dev/null)
  fi
  
  if command -v jq >/dev/null; then
    package_version=$(jq -r '.version' ${package} 2>/dev/null)
  elif command -v python >/dev/null; then
    package_version=$(python -c "import json; print(json.load(open('"${package}"'))['version'])" 2>/dev/null)
  elif command -v node >/dev/null; then
    package_version=$(node -p "require('"${package}"').version" 2> /dev/null)
  fi
  
  if [[ $CLICOLOR = 1 ]]; then
    
    echo -n "%{$c[green]$c_bold%}"
    echo -n "${package_name}@${package_version}"
    echo -n "%{$c[reset]%}"
  else
    
    echo "${package_name}@${package_version}"
    
  fi
  
  if [[ $CLICOLOR = 1 ]]; then
    
    echo -n "%{$c[cyan]$c_bold%}"
    echo -n $(grep "$cwd" "$BOOKMARKS_FILE" | awk -F'|' '{print $2}')
    echo -n "%{$c[reset]%}"
    
  else
    grep "$cwd" "$BOOKMARKS_FILE" | awk -F'|' '{print $2}'
    
  fi
  
}