#!/usr/bin/env zsh

CURRENT_PATH_PREFIX=${CURRENT_PATH_PREFIX:-" "}
CURRENT_PATH_SUFIX=${CURRENT_PATH_SUFIX:-""}

DEPENDENCES_DEBIAN+=(jq)
DEPENDENCES_ARCH+=(jq)

if (( $+functions[zpm] )); then
  zpm zpm-zsh/helpers,inline zpm-zsh/colors,inline
fi

_pr_cwd_bookmark_icon="%{${c[blue]}${c_dim}%}%{${c_reset}%} "

_pr_cwd_home(){
  if [[ "$(print -Pn %1~ )" != '~'* ]]; then
    echo
    return 1
  else
    echo -n "%{${c[blue]}${c_bold}%}"
    echo -n "$(print -Pn %~)"
    echo -n "%{${c_reset}%}"
    
    return 0
  fi
}

_pr_cwd_one(){
  if [[ "${PWD:h}" != "/" ]]; then
    echo
    return 1
  else
    
    echo -n "%{${c[red]}${c_bold}%}/"
    echo -n "%{${c[blue]}${c_bold}%}${PWD:t}"
    echo -n "%{${c_reset}%}"
    
    return 0
  fi
}

_pr_cwd_get_bookmark(){
  rpath="$(print -D ${1:P})"
  
  if [[ ! -z "$BOOKMARKS_FILE" ]]; then
    declare -a lines; lines=( "${(@f)"$(<$BOOKMARKS_FILE)"}" )
    declare -a grepped; grepped=( ${(M)lines:#${rpath}\|*} )
    
    if [[ ! -z "${grepped}" ]] then
      echo -n "%{${c[cyan]}${c_bold}%}"
      echo -n ${grepped##*\|}
      echo -n "%{${c_reset}%}"
      
      return 0
    fi
  fi
  
  echo
  return 1
}

_pr_cwd_rust(){
  rpath="${1:P}"
  package_str='Unknown name'
  
  if [[ ! -f "${rpath}/Cargo.toml" ]] ; then
    echo
    return 1
  fi
  
  if (( $+commands[jq] )); then
    package_str="$(
      cargo metadata --no-deps --format-version 1 --manifest-path="${rpath}/Cargo.toml" \
      | jq --raw-output "(.packages[0] | .name) + '%{${c[grey]}%}#%{${c[bright_grey]}%}' + (.packages[0] | .version)"  2>/dev/null
    )"
  fi
  
  echo -n "%{${c[magenta]}${c_bold}%}${package_str}%{${c_reset}%}"
  return 0
}

_pr_cwd_node(){
  rpath="${1:P}"
  package="${rpath}/package.json"
  package_str='Unknown name'
  
  if [[ ! -f "${package}" ]] ; then
    echo
    return 1
  fi
  
  if (( $+commands[jq] )); then
    package_str="$(jq -r ".name + \"%{${c[grey]}%}@%{${c[bright_grey]}%}\" + .version" "${package}" 2>/dev/null)"
  fi
  
  echo -n "%{${c[green]}${c_bold}%}"
  echo -n "${package_str}"
  echo -n "%{${c_reset}%}"
  
  return 0
}

_pr_cwd() {
  pr_cwd=''
  
  # Prepare ----
  if [[ ! -w "$PWD" ]]; then
    lock_icon="%{${c[red]}${c_dim}%}%{${c_reset}%} "
  else
    lock_icon=""
  fi
  # /Prepare ----
  
  local bookmark_dir=$(_pr_cwd_get_bookmark "$PWD")
  if [[ -n "${bookmark_dir}" ]] ; then
    pr_cwd="$CURRENT_PATH_PREFIX${lock_icon}${_pr_cwd_bookmark_icon}$(
      hyperlink-file-pr "${bookmark_dir}" "$PWD"
    )$CURRENT_PATH_SUFIX"
    return 0
  fi
  
  if (( $+commands[node] )); then;
    local node_dir=$(_pr_cwd_node "$PWD")
    
    if [[ -n "${node_dir}" ]] ; then
      pr_cwd="$CURRENT_PATH_PREFIX${lock_icon}$(
        hyperlink-file-pr "${node_dir}" "$PWD"
      )$CURRENT_PATH_SUFIX"
      return 0
    fi
  fi
  
  if (( $+commands[rustc] )) ;then
    local rust_dir=$(_pr_cwd_rust "$PWD")
    
    if [[ -n "${rust_dir}" ]] ; then
      pr_cwd="$CURRENT_PATH_PREFIX${lock_icon}$(
        hyperlink-file-pr "${rust_dir}" "$PWD"
      )$CURRENT_PATH_SUFIX"
      return 0
    fi
  fi
  
  local home_dir="$(_pr_cwd_home $PWD)"
  if [[ -n "${home_dir}" ]]; then
    pr_cwd="$CURRENT_PATH_PREFIX${lock_icon}$(
      hyperlink-file-pr "${home_dir}" "$PWD"
    )$CURRENT_PATH_SUFIX"
    return 0
  fi
  
  local one_dir="$(_pr_cwd_one)"
  if [[ -n "${one_dir}" ]] ; then
    pr_cwd="$CURRENT_PATH_PREFIX${lock_icon}$(
      hyperlink-file-pr "${one_dir}" "$PWD"
    )$CURRENT_PATH_SUFIX"
    return 0
  fi
  
  local bookmark_dir=$(_pr_cwd_get_bookmark "$PWD/..")
  if [[ -n "${bookmark_dir}" ]]; then
    pr_cwd="$CURRENT_PATH_PREFIX${lock_icon}${_pr_cwd_bookmark_icon}$(
      hyperlink-file-pr "${bookmark_dir}$(_pr_cwd_get_one_dir)" "$PWD"
    )$CURRENT_PATH_SUFIX"
    return 0
  fi
  
  if (( $+commands[node] )) ; then
    local node_dir=$(_pr_cwd_node "$PWD/..")
    
    if [[ -n "${node_dir}" ]] ; then
      pr_cwd="$CURRENT_PATH_PREFIX${lock_icon}$(
        hyperlink-file-pr "${node_dir}$(_pr_cwd_get_one_dir)" "$PWD"
      )$CURRENT_PATH_SUFIX"
      return 0
    fi
  fi
  
  if (( $+commands[rustc] )) ; then
    local rust_dir=$(_pr_cwd_rust "$PWD/..")
    
    if [[ -n "${rust_dir}" ]] ; then
      pr_cwd="$CURRENT_PATH_PREFIX${lock_icon}$(
        hyperlink-file-pr "${rust_dir}$(_pr_cwd_get_one_dir)" "$PWD"
      )$CURRENT_PATH_SUFIX"
      return 0
    fi
  fi
  
  newPWD="$(print -Pn %2~)"
  
  link=${newPWD//\//%{${c[red]}${c_bold}%}\/%{${c[blue]}${c_bold}%}}
  link=$(hyperlink-file-pr "${link}" "${PWD}")
  pr_cwd="${CURRENT_PATH_PREFIX}${lock_icon}%{${c[blue]}${c_bold}%}${link}${CURRENT_PATH_SUFIX}%{${c_reset}%}"
}

_pr_cwd
autoload -Uz add-zsh-hook
add-zsh-hook chpwd _pr_cwd
