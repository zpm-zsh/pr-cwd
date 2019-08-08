#!/usr/bin/env zsh

_pr_cwd_is_one_dir(){
  [[ "${PWD:h}" == "/" ]]
}

_pr_cwd_get_one_dir(){
  
  echo -n "%{$c[red]${c_bold}%}/"
  echo -n "%{$c[blue]${c_bold}%}${PWD:t}"
  echo -n "%{$c[reset]%}"
  
}
