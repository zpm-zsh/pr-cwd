#!/usr/bin/env zsh

: ${CURRENT_PATH_PREFIX:=" "}
: ${CURRENT_PATH_SUFIX:=""}

DEPENDENCES_DEBIAN+=(jq)
DEPENDENCES_ARCH+=(jq)

typeset -g pr_cwd

typeset -g _pr_cwd_bookmark_icon="%{${c[blue]}${c[dim]}%}%{${c[reset]}%} "

if [[ $PMSPEC != *f* ]] {
  fpath+=( "${0:h}/functions" )
}

autoload -Uz pr_cwd_get_bookmark pr_cwd_get_one_dir pr_cwd_get_home_dir  

function _pr_cwd() {
  local lock_icon
  local newPWD
  local link

  if [[ ! -w "$PWD" ]]; then
    lock_icon="%{${c[red]}${c[dim]}%}%{${c[reset]}%} "
  else
    lock_icon=""
  fi

  if [[ "$PWD" == "$HOME" ]]; then
    local home_dir="$(pr_cwd_get_home_dir $PWD)"

    pr_cwd="$CURRENT_PATH_PREFIX${lock_icon}$(
      hyperlink-file-pr "${home_dir}" "$PWD"
    )$CURRENT_PATH_SUFIX"
    return 0
  fi

  if [[ -e "${BOOKMARKS_FILE:-"$HOME/.bookmarks"}" ]]; then
    local bookmark_dir=$(pr_cwd_get_bookmark "$PWD")

    if [[ -n "${bookmark_dir}" ]] ; then
      pr_cwd="$CURRENT_PATH_PREFIX${lock_icon}${_pr_cwd_bookmark_icon}$(
        hyperlink-file-pr "${bookmark_dir}" "$PWD"
      )$CURRENT_PATH_SUFIX"
      return 0
    fi
  fi

  if [[ "$(print -Pn %1~ )" == '~'* ]]; then
    local home_dir="$(pr_cwd_get_home_dir $PWD)"

    pr_cwd="$CURRENT_PATH_PREFIX${lock_icon}$(
      hyperlink-file-pr "${home_dir}" "$PWD"
    )$CURRENT_PATH_SUFIX"
    return 0
  fi

  if [[ "${PWD:h}" == "/" ]]; then
    local one_dir="$(pr_cwd_get_one_dir)"

    pr_cwd="$CURRENT_PATH_PREFIX${lock_icon}$(
      hyperlink-file-pr "${one_dir}" "$PWD"
    )$CURRENT_PATH_SUFIX"
    return 0
  fi

  if [[ -e "${BOOKMARKS_FILE:-"$HOME/.bookmarks"}" ]]; then
    local bookmark_dir=$(pr_cwd_get_bookmark "$PWD/..")

    if [[ -n "${bookmark_dir}" ]]; then
      pr_cwd="$CURRENT_PATH_PREFIX${lock_icon}${_pr_cwd_bookmark_icon}$(
        hyperlink-file-pr "${bookmark_dir}$(pr_cwd_get_one_dir)" "$PWD"
      )$CURRENT_PATH_SUFIX"
      return 0
    fi
  fi

  newPWD="$(print -Pn %2~)"

  link=${newPWD//\//%{${c[red]}${c[bold]}%}\/%{${c[blue]}${c[bold]}%}}
  link=$(hyperlink-file-pr "${link}" "${PWD}")
  pr_cwd="${CURRENT_PATH_PREFIX}${lock_icon}%{${c[blue]}${c[bold]}%}${link}${CURRENT_PATH_SUFIX}%{${c[reset]}%}"
}

autoload -Uz add-zsh-hook
add-zsh-hook chpwd _pr_cwd
_pr_cwd
