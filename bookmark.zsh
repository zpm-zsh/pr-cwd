#!/usr/bin/env zsh

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

_pr_cwd_get_bookmark(){
  rpath=$(print -D ${1:P})

  declare -a lines; lines=( "${(@f)"$(<$BOOKMARKS_FILE)"}" )
  declare -a grepped; grepped=( ${(M)lines:#${rpath}\|*} )

  echo -n "%{$c[cyan]$c_bold%}"
  echo -n ${grepped##*\|}
  echo -n "%{$c[reset]%}"
}
