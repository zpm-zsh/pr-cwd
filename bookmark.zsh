#!/usr/bin/env zsh

_pr_cwd_bookmark_icon="%{$c[blue]$c_dim%}%{$c_reset%} "

_pr_cwd_is_bookmark_dir(){
  
  rpath=$(print -D ${1:P})
   
  if [[ ! -z "$BOOKMARKS_FILE" ]]; then
    if egrep -q "^${rpath}\|" "$BOOKMARKS_FILE" ; then
      return 0
    fi
    
  fi
  
  return 1
}

_pr_cwd_get_bookmark(){
  
  rpath=$(print -D ${1:P})
    
  echo -n "%{$c[cyan]$c_bold%}"
  echo -n $(egrep "^${rpath}\|" "$BOOKMARKS_FILE" | awk -F'|' '{print $2}')
  echo -n "%{$c[reset]%}"
  
}
