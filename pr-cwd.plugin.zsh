#!/usr/bin/env zsh

: ${CURRENT_PATH_PREFIX:=" "}
: ${CURRENT_PATH_SUFIX:=""}

DEPENDENCES_DEBIAN+=(jq)
DEPENDENCES_ARCH+=(jq)

typeset -g pr_cwd

if [[ $PMSPEC != *f* ]] {
  fpath+=( "${0:h}/functions" )
}

autoload -Uz pr_cwd_get_bookmark pr_cwd_get_one_dir pr_cwd_is_special pr_cwd_get_regular_dir

function _pr_cwd() {
  local local_cwd=''

  last_part="$(pr_cwd_is_special $PWD)"
  if [[ -n "$last_part" ]]; then
    local_cwd="$last_part"
  else
    last_part="$(pr_cwd_get_regular_dir $PWD)"
    first_part="$(pr_cwd_is_special "${PWD:h}")" 
    if [[ -n "$first_part" ]]; then
      local_cwd="${first_part}%{${c[red]}${c[bold]}%}/%{${c[reset]}%}${last_part}"
    else
      first_part="$(pr_cwd_get_regular_dir ${PWD:h})"

      local is_root=''
      if [[ "${PWD:h}" == '/'* && "${PWD:h}" != '/'*'/'* && -n "${first_part}" ]]; then
        local is_root="%{${c[red]}${c[bold]}%}/%{${c[reset]}%}"
      fi

      local_cwd="${is_root}${first_part}%{${c[red]}${c[bold]}%}/%{${c[reset]}%}${last_part}"
    fi
  fi

  pr_cwd="${CURRENT_PATH_PREFIX}${lock_icon}%{${c[blue]}${c[bold]}%}${local_cwd}${CURRENT_PATH_SUFIX}%{${c[reset]}%}"
}

autoload -Uz add-zsh-hook
add-zsh-hook chpwd _pr_cwd
_pr_cwd
