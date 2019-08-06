#!/usr/bin/env zsh

CURRENT_PATH_PREFIX=${CURRENT_PATH_PREFIX:-" "}
CURRENT_PATH_SUFIX=${CURRENT_PATH_SUFIX:-""}

DEPENDENCES_DEBIAN+=(jq)
DEPENDENCES_ARCH+=(jq)
DEPENDENCES_ZSH+=( zpm-zsh/helpers zpm-zsh/colors )

if command -v zpm >/dev/null; then
  zpm zpm-zsh/helpers zpm-zsh/colors
fi

source  ${${(%):-%x}:a:h}/home.zsh
source  ${${(%):-%x}:a:h}/one-dir.zsh
source  ${${(%):-%x}:a:h}/bookmark.zsh
source  ${${(%):-%x}:a:h}/node.zsh
source  ${${(%):-%x}:a:h}/rust.zsh

_pr_cwd() {
  pr_cwd=''
  
  # Prepare ----
  if [[ $CLICOLOR = 1 ]]; then
    
    if [[ ! -w "$PWD" ]]; then
      lock_icon="%{$c[red]$c[dim]%}%{$c[reset]%} "
    else
      lock_icon=""
    fi
    
  else
    
    if [[ ! -w "$PWD" ]]; then
      lock_icon=" "
    else
      lock_icon=""
    fi
    
  fi
  # /Prepare ----
  
  
  if _pr_cwd_is_bookmark_dir "$PWD" ; then
    pr_cwd="$CURRENT_PATH_PREFIX${lock_icon}${_pr_cwd_bookmark_icon}$(
      hyperlink-file-pr "$(_pr_cwd_get_bookmark "$PWD")" "$PWD"
    )$CURRENT_PATH_SUFIX"
    return 0
  fi
  
  if _pr_cwd_is_node_dir "$PWD" ; then
    pr_cwd="$CURRENT_PATH_PREFIX${lock_icon}$(
      hyperlink-file-pr "$(_pr_cwd_get_node_package "$PWD")" "$PWD"
    )$CURRENT_PATH_SUFIX"
    return 0
  fi
  
  if _pr_cwd_is_rust_dir "$PWD" ; then
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

if _pr_cwd_is_node_dir "$PWD/.." ; then
  pr_cwd="$CURRENT_PATH_PREFIX${lock_icon}$(
    hyperlink-file-pr "$(_pr_cwd_get_node_package "$PWD/..")$(_pr_cwd_get_one_dir)" "$PWD"
  )$CURRENT_PATH_SUFIX"
  return 0
fi

if _pr_cwd_is_rust_dir "$PWD/.." ; then
  pr_cwd="$CURRENT_PATH_PREFIX${lock_icon}$(
    hyperlink-file-pr "$(_pr_cwd_get_rust_package "$PWD/..")$(_pr_cwd_get_one_dir
  )" "$PWD" )$CURRENT_PATH_SUFIX"
  return 0
fi

newPWD=$(print -Pn %2~)

if [[ $CLICOLOR = 1 ]]; then
  
  link=${newPWD//\//%{$c[red]$c[bold]%}\/%{$c[blue]$c[bold]%}}
  link=$(hyperlink-file-pr ${link} ${PWD})
  pr_cwd="$CURRENT_PATH_PREFIX${lock_icon}%{$c[blue]$c[bold]%}$link$CURRENT_PATH_SUFIX%{$c[reset]%}"
  
else
  pr_cwd="$CURRENT_PATH_PREFIX${lock_icon}$(hyperlink-file-pr ${newPWD} ${PWD})$CURRENT_PATH_SUFIX"
fi

}

_pr_cwd
autoload -Uz add-zsh-hook
add-zsh-hook chpwd _pr_cwd
