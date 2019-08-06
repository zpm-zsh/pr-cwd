#!/usr/bin/env zsh

CURRENT_PATH_PREFIX=${CURRENT_PATH_PREFIX:-" "}
CURRENT_PATH_SUFIX=${CURRENT_PATH_SUFIX:-""}

DEPENDENCES_ZSH+=( zpm-zsh/colors )
if command -v zpm >/dev/null; then
  zpm zpm-zsh/colors
fi

_pr_cwd_HOME_=$(echo $HOME | sed 's/\//\\\//g')

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
  
  if [[ "$PWD" =~ ^"$HOME"(/|$) ]]; then
    cwd="\$HOME${PWD#$HOME}"
  else
    cwd="$PWD"
  fi
  
  if [[ ! -z "$BOOKMARKS_FILE" ]]; then
    if grep -q -e "^$cwd|" "$BOOKMARKS_FILE"; then
      bookmark_name=$(grep "$cwd" "$BOOKMARKS_FILE" | awk -F'|' '{print $2}')
      
      if [[ $CLICOLOR = 1 ]]; then
        link=${bookmark_name//\//%{$c[red]$c[bold]%}\/%{$c[cyan]$c[bold]%}}
        link=$'%{\033]8;;file://'"$PWD"$'\a%}'$link$'%{\033]8;;\a%}'
        pr_cwd="$CURRENT_PATH_PREFIX${lock_icon}${bookmark_icon}%{$c[cyan]$c_bold%}$link%{$c[reset]%}$CURRENT_PATH_SUFIX"
      else
        pr_cwd="$CURRENT_PATH_PREFIX${lock_icon}${bookmark_icon}$bookmark_name$CURRENT_PATH_SUFIX"
      fi
      
      return 0
    fi
  fi
  
  newPWD=$(print -Pn %2~| sed 's/^'$_pr_cwd_HOME_'/~/g')
  
  if [[ $CLICOLOR = 1 ]]; then
    link=${newPWD//\//%{$c[red]$c[bold]%}\/%{$c[blue]$c[bold]%}}
    link=$'%{\033]8;;file://'"$PWD"$'\a%}'$link$'%{\033]8;;\a%}'
    pr_cwd="$CURRENT_PATH_PREFIX${lock_icon}%{$c[blue]$c[bold]%}$link$CURRENT_PATH_SUFIX%{$c[reset]%}"
  else
    pr_cwd="$CURRENT_PATH_PREFIX${lock_icon}$newPWD$CURRENT_PATH_SUFIX"
  fi
  
}

_pr_cwd
add-zsh-hook chpwd _pr_cwd

