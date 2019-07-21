#!/usr/bin/env zsh

CURRENT_PATH_PREFIX=${CURRENT_PATH_PREFIX:-" "}
CURRENT_PATH_SUFIX=${CURRENT_PATH_SUFIX:-""}

DEPENDENCES_ZSH+=( zpm-zsh/colors )
if command -v zpm >/dev/null; then
  zpm zpm-zsh/colors
fi

_pr_cwd_HOME_=$(echo $HOME | sed 's/\//\\\//g')

_pr_cwd() {
  
  local newPWD=$(print -Pn %2~)
  newPWD=$(echo $newPWD| sed 's/^'$_pr_cwd_HOME_'/~/g')
  
  pr_cwd_plain="$newPWD"

  local lockIcon=""
  if [[ ! -w "$PWD" ]]; then
    lockIcon="%{$c[red]$c[dim]%}%{$c[reset]%} "
  else
	lockIcon="%{$c[green]$c[dim]%}%{$c[reset]%} "
  fi
  
  if [[ $CLICOLOR = 1 ]]; then
    newPWD=${newPWD//\//%{$c[red]$c[bold]%}\/%{$c[blue]$c[bold]%}}
    newPWD=$'%{\033]8;;file://'"$PWD"$'\a%}'$newPWD$'%{\033]8;;\a%}'
    pr_cwd="$CURRENT_PATH_PREFIX$lockIcon%{$c[blue]$c[bold]%}$newPWD$CURRENT_PATH_SUFIX%{$c[reset]%}"
  else
    pr_cwd="$CURRENT_PATH_PREFIX$lockIcon$newPWD$CURRENT_PATH_SUFIX"
  fi

}

_pr_cwd
chpwd_functions+=(_pr_cwd)

