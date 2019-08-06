#!/usr/bin/env zsh

CURRENT_PATH_PREFIX=${CURRENT_PATH_PREFIX:-" "}
CURRENT_PATH_SUFIX=${CURRENT_PATH_SUFIX:-""}

DEPENDENCES_ZSH+=( zpm-zsh/colors )
if command -v zpm >/dev/null; then
  zpm zpm-zsh/colors
fi

is_bookmark_dir(){
  
  rpath=$(readlink -f $1)
  
  if [[ "$rpath" =~ ^"$HOME"(/|$) ]]; then
    cwd="\$HOME${rpath#$HOME}"
  else
    cwd="$rpath"
  fi
  
  if [[ ! -z "$BOOKMARKS_FILE" ]]; then
    if grep -q -e "^$cwd|" "$BOOKMARKS_FILE"; then
      return 0
    fi
    
  fi
  
  return 1
}

get_bookmark(){
  
  rpath=$(readlink -f $1)
  
  if [[ "$rpath" =~ ^"$HOME"(/|$) ]]; then
    cwd="\$HOME${rpath#$HOME}"
  else
    cwd="$rpath"
  fi
  
  grep "$cwd" "$BOOKMARKS_FILE" | awk -F'|' '{print $2}'
  
}

if [[ $CLICOLOR = 1 ]]; then
  bookmark_icon="%{$c[blue]$c_dim%}%{$c_reset%} "
else
  bookmark_icon=" "
fi

_pr_cwd() {
  pr_cwd=''
  
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
  
  
  if is_bookmark_dir "$PWD" ; then
    
    if [[ $CLICOLOR = 1 ]]; then
      
      link=$'%{\033]8;;file://'"$PWD"$'\a%}'$(get_bookmark "$PWD")$'%{\033]8;;\a%}'
      pr_cwd="$CURRENT_PATH_PREFIX${lock_icon}${bookmark_icon}%{$c[cyan]$c_bold%}$link%{$c[reset]%}$CURRENT_PATH_SUFIX"
      
    else
      
      pr_cwd="$CURRENT_PATH_PREFIX${lock_icon}${bookmark_icon}$(get_bookmark "$PWD")$CURRENT_PATH_SUFIX"
      
    fi
    
    return 0
  fi
  
  if is_bookmark_dir "$PWD/.." ; then
    
    if [[ $CLICOLOR = 1 ]]; then
      
      cwd="%{$c[cyan]$c_bold%}$(get_bookmark "$PWD/..")%{$c[red]$c[bold]%}/"
      cwd+="%{$c[blue]$c_bold%}$(print -Pn %1/)%{$c[reset]%}"
      link=$'%{\033]8;;file://'"$PWD"$'\a%}'${cwd}$'%{\033]8;;\a%}'
      pr_cwd="$CURRENT_PATH_PREFIX${lock_icon}${bookmark_icon}$link$CURRENT_PATH_SUFIX"
      
    else
      
      cwd="$(get_bookmark "$PWD/..")/$(print -Pn %1/)"
      pr_cwd="$CURRENT_PATH_PREFIX${lock_icon}${bookmark_icon}${cwd}$CURRENT_PATH_SUFIX"
      
    fi
    
    return 0
  fi
  
  newPWD=$(print -Pn %2~)
  
  if [[ $CLICOLOR = 1 ]]; then
    
    link=${newPWD//\//%{$c[red]$c[bold]%}\/%{$c[blue]$c[bold]%}}
    link=$'%{\033]8;;file://'"$PWD"$'\a%}'$link$'%{\033]8;;\a%}'
    pr_cwd="$CURRENT_PATH_PREFIX${lock_icon}%{$c[blue]$c[bold]%}$link$CURRENT_PATH_SUFIX%{$c[reset]%}"
    
  else
    
    pr_cwd="$CURRENT_PATH_PREFIX${lock_icon}$newPWD$CURRENT_PATH_SUFIX"
    
  fi
  
}

_pr_cwd
autoload -Uz add-zsh-hook
add-zsh-hook chpwd _pr_cwd

