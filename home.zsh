#!/usr/bin/env zsh

_pr_cwd_is_home_dir(){
  print -Pn %1~ | grep -q '\~'
}

_pr_cwd_get_home_dir(){
  
  echo -n "%{$c[blue]$c_bold%}"
  echo -n $(print -Pn %~)
  echo -n "%{$c[reset]%}"
  
}
