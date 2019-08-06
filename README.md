# Plugin for ZSH who display current directory

Plugin will create a global variable that can be displayed in prompts. 

This plugin has good integration with [jocelynmallon/zshmarks](https://github.com/jocelynmallon/zshmarks).

![Record](record.gif)

### Example

```sh
PROMPT='$pr_cwd ...REST OF PROMPT'
```

This plugin made to be fast. It runs in background and update information only if need.

## Installation

### Please, install [jq](https://stedolan.github.io/jq/).

### This plugin depends on [zsh-helpers](https://github.com/zpm-zsh/helpers) and [zsh-colors](https://github.com/zpm-zsh/colors)

If you don't use [zpm](https://github.com/zpm-zsh/zpm), install it manually and activate it before this plugin. 
If you use zpm you don’t need to do anything

### If you use [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh)

* Clone this repository into `~/.oh-my-zsh/custom/plugins`

```sh
cd ~/.oh-my-zsh/custom/plugins
git clone https://github.com/zpm-zsh/pr-cwd
```
* After that, add `pr-cwd` to your oh-my-zsh plugins array.

### If you use [Zgen](https://github.com/tarjoilija/zgen)

1. Add `zgen load zpm-zsh/pr-cwd` to your `.zshrc` with your other plugin
2. run `zgen save`

### If you use my [ZPM](https://github.com/zpm-zsh/zpm)

* Add `zpm load zpm-zsh/pr-cwd` into your `.zshrc`
