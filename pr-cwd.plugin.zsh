CURRENT_PATH_PREFIX=${CURRENT_PATH_PREFIX:-" "}
CURRENT_PATH_SUFIX=${CURRENT_PATH_SUFIX:-""}

DEPENDENCES_DEBIAN+=(jq)
DEPENDENCES_ARCH+=(jq)

if (( $+functions[zpm] )); then
  zpm zpm-zsh/helpers,inline zpm-zsh/colors,inline
fi

_pr_cwd_bookmark_icon="%{$c[blue]$c_dim%}%{$c_reset%} "

_pr_cwd_is_bookmark_dir(){
  rpath=$(print -D ${1:P})
  
  if [[ ! -z "$BOOKMARKS_FILE" ]]; then
    declare -a lines; lines=( "${(@f)"$(<$BOOKMARKS_FILE)"}" )
    declare -a grepped; grepped=( ${(M)lines:#${rpath}\|*} )
    
    if [[ ! -z "$grepped" ]] then
      return 0
    fi
  fi
  
  return 1
}

_pr_cwd_is_home_dir(){
  [[ "$(print -Pn %1~ )" == '~'* ]]
}

_pr_cwd_is_node_dir(){
  rpath=${1:P}
  
  if [[ -f "${rpath}/package.json" ]] ; then
    return 0
  fi
  
  return 1
}

_pr_cwd_is_one_dir(){
  [[ "${PWD:h}" == "/" ]]
}

_pr_cwd_is_rust_dir(){
  rpath=${1:P}
  
  if [[ -f "${rpath}/Cargo.toml" ]] ; then
    return 0
  fi
  
  return 1
}

_pr_cwd_get_bookmark(){
  rpath=$(print -D ${1:P})
  
  declare -a lines; lines=( "${(@f)"$(<$BOOKMARKS_FILE)"}" )
  declare -a grepped; grepped=( ${(M)lines:#${rpath}\|*} )
  
  echo -n "%{$c[cyan]$c_bold%}"
  echo -n ${grepped##*\|}
  echo -n "%{$c[reset]%}"
}

_pr_cwd_get_home_dir(){
  echo -n "%{$c[blue]$c_bold%}"
  echo -n $(print -Pn %~)
  echo -n "%{$c[reset]%}"
}

_pr_cwd_get_one_dir(){
  echo -n "%{$c[red]${c_bold}%}/"
  echo -n "%{$c[blue]${c_bold}%}${PWD:t}"
  echo -n "%{$c[reset]%}"
}

_pr_cwd_get_node_package(){
  rpath=${1:P}
  package="${rpath}/package.json"
  package_str='Unknown name'
  
  if (( $+commands[jq] )); then
    package_str=$(jq -r ".name + \"%{${c[grey]}%}@%{${c[bright_grey]}%}\" + .version" ${package} 2>/dev/null)
  fi
  
  echo -n "%{$c[green]$c_bold%}"
  echo -n "${package_str}"
  echo -n "%{$c[reset]%}"
}

_pr_cwd_get_rust_package(){
  rpath=${1:P}
  package_str='Unknown name'
  
  if (( $+commands[jq] )); then
    package_str=$(cargo metadata --no-deps --format-version 1 --manifest-path=${rpath}/Cargo.toml \
    | jq --raw-output "(.packages[0] | .name) + \"%{${c[grey]}%}#%{${c[bright_grey]}%}\" + (.packages[0] | .version)"  2>/dev/null  )
  fi
  
  echo -n "%{$c[magenta]$c_bold%}${package_str}%{$c[reset]%}"
}

_pr_cwd() {
  pr_cwd=''
  
  # Prepare ----
  if [[ ! -w "$PWD" ]]; then
    lock_icon="%{$c[red]$c[dim]%}%{$c[reset]%} "
  else
    lock_icon=""
  fi
  # /Prepare ----
  
  if _pr_cwd_is_bookmark_dir "$PWD" ; then
    pr_cwd="$CURRENT_PATH_PREFIX${lock_icon}${_pr_cwd_bookmark_icon}$(
      hyperlink-file-pr "$(_pr_cwd_get_bookmark "$PWD")" "$PWD"
    )$CURRENT_PATH_SUFIX"
    return 0
  fi
  
  if (( $+commands[node] )) && _pr_cwd_is_node_dir "$PWD" ; then
    pr_cwd="$CURRENT_PATH_PREFIX${lock_icon}$(
      hyperlink-file-pr "$(_pr_cwd_get_node_package "$PWD")" "$PWD"
    )$CURRENT_PATH_SUFIX"
    return 0
  fi
  
  if (( $+commands[rustc] )) && _pr_cwd_is_rust_dir "$PWD" ; then
    pr_cwd="$CURRENT_PATH_PREFIX${lock_icon}$(
      hyperlink-file-pr "$(_pr_cwd_get_rust_package "$PWD")" "$PWD"
    )$CURRENT_PATH_SUFIX"
    return 0
  fi
  
  if _pr_cwd_is_home_dir ; then
    pr_cwd="$CURRENT_PATH_PREFIX${lock_icon}$(
      hyperlink-file-pr "$(_pr_cwd_get_home_dir)" "$PWD"
    )$CURRENT_PATH_SUFIX"
    return 0
  fi
  
  if _pr_cwd_is_one_dir ; then
    pr_cwd="$CURRENT_PATH_PREFIX${lock_icon}$(
      hyperlink-file-pr "$(_pr_cwd_get_one_dir)" "$PWD"
    )$CURRENT_PATH_SUFIX"
    return 0
  fi
  
  if _pr_cwd_is_bookmark_dir "$PWD/.." ; then
    pr_cwd="$CURRENT_PATH_PREFIX${lock_icon}${_pr_cwd_bookmark_icon}$(
      hyperlink-file-pr "$(_pr_cwd_get_bookmark "$PWD/..")$(_pr_cwd_get_one_dir)" "$PWD"
    )$CURRENT_PATH_SUFIX"
    return 0
  fi
  
  if (( $+commands[node] )) && _pr_cwd_is_node_dir "$PWD/.." ; then
    pr_cwd="$CURRENT_PATH_PREFIX${lock_icon}$(
      hyperlink-file-pr "$(_pr_cwd_get_node_package "$PWD/..")$(_pr_cwd_get_one_dir)" "$PWD"
    )$CURRENT_PATH_SUFIX"
    return 0
  fi
  
  if (( $+commands[rustc] )) && _pr_cwd_is_rust_dir "$PWD/.." ; then
    pr_cwd="$CURRENT_PATH_PREFIX${lock_icon}$(
      hyperlink-file-pr "$(_pr_cwd_get_rust_package "$PWD/..")$(_pr_cwd_get_one_dir
    )" "$PWD" )$CURRENT_PATH_SUFIX"
    return 0
  fi
  
  newPWD=$(print -Pn %2~)
  
  link=${newPWD//\//%{$c[red]$c[bold]%}\/%{$c[blue]$c[bold]%}}
  link=$(hyperlink-file-pr ${link} ${PWD})
  pr_cwd="$CURRENT_PATH_PREFIX${lock_icon}%{$c[blue]$c[bold]%}$link$CURRENT_PATH_SUFIX%{$c[reset]%}"
}

_pr_cwd
autoload -Uz add-zsh-hook
add-zsh-hook chpwd _pr_cwd
