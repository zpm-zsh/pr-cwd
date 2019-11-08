#!/usr/bin/env zsh

# Standarized $0 handling, following:
# https://github.com/zdharma/Zsh-100-Commits-Club/blob/master/Zsh-Plugin-Standard.adoc
0="${${ZERO:-${0:#$ZSH_ARGZERO}}:-${(%):-%N}}"
_DIRNAME="${0:h}"

CURRENT_PATH_PREFIX=${CURRENT_PATH_PREFIX:-" "}
CURRENT_PATH_SUFIX=${CURRENT_PATH_SUFIX:-""}

DEPENDENCES_DEBIAN+=(jq)
DEPENDENCES_ARCH+=(jq)

if (( $+functions[zpm] )); then
  zpm zpm-zsh/helpers zpm-zsh/colors
fi

source  "${_DIRNAME}/home.zsh"
source  "${_DIRNAME}/one-dir.zsh"
source  "${_DIRNAME}/bookmark.zsh"
source  "${_DIRNAME}/node.zsh"
source  "${_DIRNAME}/rust.zsh"

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
    pr_cwd="$CURRENT_PATH_PREFIX${lock_icon}$(hyperlink-file-pr "$(
    _pr_cwd_get_home_dir)" "$PWD"
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
