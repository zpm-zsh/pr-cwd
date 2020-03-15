#!/usr/bin/env zsh

typeset -g CURRENT_PATH_PREFIX
CURRENT_PATH_PREFIX=${CURRENT_PATH_PREFIX:-" "}
typeset -g CURRENT_PATH_SUFIX
CURRENT_PATH_SUFIX=${CURRENT_PATH_SUFIX:-""}

DEPENDENCES_DEBIAN+=(jq)
DEPENDENCES_ARCH+=(jq)

typeset -g pr_cwd

if (( $+functions[zpm] )); then
  zpm zpm-zsh/helpers zpm-zsh/colors
fi

_pr_cwd_bookmark_icon="%{${c[blue]}${c_dim}%}%{${c_reset}%} "

function _pr_cwd_get_home_dir() {
  echo -n "%{${c[blue]}${c_bold}%}"
  echo -n "$(print -Pn %~)"
  echo -n "%{${c_reset}%}"
}

function _pr_cwd_get_one_dir() {
  echo -n "%{${c[red]}${c_bold}%}/"
  echo -n "%{${c[blue]}${c_bold}%}${PWD:t}"
  echo -n "%{${c_reset}%}"
}

function _pr_cwd_get_bookmark() {
  local rpath
  rpath="$(print -D ${1:P})"

  declare -a lines; lines=( "${(@f)"$(<${BOOKMARKS_FILE:-"$HOME/.bookmarks"})"}" )
  declare -a grepped; grepped=( ${(M)lines:#${rpath}\|*} )

  if [[ ! -z "${grepped}" ]] then
    echo -n "%{${c[cyan]}${c_bold}%}"
    echo -n ${grepped##*\|}
    echo -n "%{${c_reset}%}"

    return 0
  else
    echo
    return 1
  fi
}

function _pr_cwd_rust() {
  package_str='Unknown name'

  if (( $+commands[jq] )); then
    package_str="$(
      cargo metadata --no-deps --format-version 1 --manifest-path="${1}/Cargo.toml" \
        | jq --raw-output "(.packages[0] | .name) + \"%{${c[grey]}%}#%{${c[bright_grey]}%}\" + (.packages[0] | .version)"  2>/dev/null
    )"
  fi

  echo -n "%{${c[magenta]}${c_bold}%}${package_str}%{${c_reset}%}"
}

function _pr_cwd_node() {
  package="${1}/package.json"
  package_str='Unknown name'

  if (( $+commands[jq] )); then
    package_str="$(jq -r ".name + \"%{${c[grey]}%}@%{${c[bright_grey]}%}\" + .version" "${package}" 2>/dev/null)"
  fi

  echo -n "%{${c[green]}${c_bold}%}"
  echo -n "${package_str}"
  echo -n "%{${c_reset}%}"
}

function _pr_cwd() {
  local lock_icon
  local newPWD
  local link

  pr_cwd=''

  # Prepare ----
  if [[ ! -w "$PWD" ]]; then
    lock_icon="%{${c[red]}${c_dim}%}%{${c_reset}%} "
  else
    lock_icon=""
  fi
  # /Prepare ----

  if [[ -e "${BOOKMARKS_FILE:-"$HOME/.bookmarks"}" ]]; then
    local bookmark_dir=$(_pr_cwd_get_bookmark "$PWD")

    if [[ -n "${bookmark_dir}" ]] ; then
      pr_cwd="$CURRENT_PATH_PREFIX${lock_icon}${_pr_cwd_bookmark_icon}$(
        hyperlink-file-pr "${bookmark_dir}" "$PWD"
      )$CURRENT_PATH_SUFIX"
      return 0
    fi
  fi

  if (( $+commands[node] )); then;
    if [[ -f "${PWD}/package.json" ]] ; then
      local node_dir=$(_pr_cwd_node "$PWD")

      pr_cwd="$CURRENT_PATH_PREFIX${lock_icon}$(
        hyperlink-file-pr "${node_dir}" "$PWD"
      )$CURRENT_PATH_SUFIX"
      return 0
    fi
  fi

  if (( $+commands[rustc] )) ;then
    if [[ -f "${PWD:P}/Cargo.toml" ]]; then
      local rust_dir=$(_pr_cwd_rust "$PWD")

      pr_cwd="$CURRENT_PATH_PREFIX${lock_icon}$(
        hyperlink-file-pr "${rust_dir}" "$PWD"
      )$CURRENT_PATH_SUFIX"
      return 0
    fi
  fi

  if [[ "$(print -Pn %1~ )" == '~'* ]]; then
    local home_dir="$(_pr_cwd_get_home_dir $PWD)"

    pr_cwd="$CURRENT_PATH_PREFIX${lock_icon}$(
      hyperlink-file-pr "${home_dir}" "$PWD"
    )$CURRENT_PATH_SUFIX"
    return 0
  fi

  if [[ "${PWD:h}" == "/" ]]; then
    local one_dir="$(_pr_cwd_get_one_dir)"

    pr_cwd="$CURRENT_PATH_PREFIX${lock_icon}$(
      hyperlink-file-pr "${one_dir}" "$PWD"
    )$CURRENT_PATH_SUFIX"
    return 0
  fi

  if [[ -e "${BOOKMARKS_FILE:-"$HOME/.bookmarks"}" ]]; then
    local bookmark_dir=$(_pr_cwd_get_bookmark "$PWD/..")

    if [[ -n "${bookmark_dir}" ]]; then
      pr_cwd="$CURRENT_PATH_PREFIX${lock_icon}${_pr_cwd_bookmark_icon}$(
        hyperlink-file-pr "${bookmark_dir}$(_pr_cwd_get_one_dir)" "$PWD"
      )$CURRENT_PATH_SUFIX"
      return 0
    fi
  fi

  if (( $+commands[node] )) ; then
    if [[ -f "${PWD}/../package.json"  ]] ; then
      local node_dir=$(_pr_cwd_node "$PWD/..")

      pr_cwd="$CURRENT_PATH_PREFIX${lock_icon}$(
        hyperlink-file-pr "${node_dir}$(_pr_cwd_get_one_dir)" "$PWD"
      )$CURRENT_PATH_SUFIX"
      return 0
    fi
  fi

  if (( $+commands[rustc] )) ; then
    if [[ -f "${PWD:P}/../Cargo.toml" ]]; then
      local rust_dir=$(_pr_cwd_rust "$PWD/..")

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

autoload -Uz add-zsh-hook
add-zsh-hook chpwd _pr_cwd
_pr_cwd
